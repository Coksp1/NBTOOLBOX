function [data,plotter] = uncertaintyDecomposition(obj,varargin)
% Syntax:
%
% [data,plotter] = uncertaintyDecomposition(obj,varargin)
%
% Description:
%
% Decompose the density forecast into shocks uncertainty.
%
% Caution : Parameter uncertainty is not yet supported!
% 
% Input:
% 
% - obj         : A vector of nb_model_generic objects
%
% - 'compare2'  : An object of class nb_model_generic. If this option is
%                 given the decomposition will be done of the difference in
%                 the uncertianty between the models. Only an options for
%                 'method' set to 'percentiles'.
%
% - 'method'    : One of:
%
%                 > 'percentiles' : This method simulate forecast based on
%                                   each shock alone, and then calculate
%                                   the percentile of the variables of
%                                   interest based on these simulations.
%                                   Percentiles are not a linear consept,
%                                   so when aggregating the percentiles of
%                                   each shock will not add up to the 
%                                   percentile of the distribution of the
%                                   variable of interest. Therefore the 
%                                   contributions of each residual/shock 
%                                   is scaled with a factor to sum to the 
%                                   the percentiles of this distribution
%                                   (default).
%
%                 > 'fev'         : Calculate the forecast error variances
%                                   contributed by each shock based on the 
%                                   simulated densities of the 
%                                   residuals/shocks of models forecast.
%
%                 > 'fes'         : Calculate the forecast error skewness
%                                   contributed by each shock based on the 
%                                   simulated densities of the 
%                                   residuals/shocks of models forecast.
%
% - 'perc'      : At which percentile you want to decompose. Must
%                 be scalar double. Default is 0.9. Only an options for
%                 'method' set to 'percentiles'.
%
% - 'packages'  : Cell structure with groups of shocks and 
%                 the names of the groups. If you have not
%                 listed a shock it will be grouped in a    
%                 group called 'Rest' 
%         
%                 Must be given in the following format:
%         
%                 {'shock_group_name_1',...,'shock_group_name_N';
%                  'shock_name_1'      ,...,'shock_name_N'}
%        
%                 Where 'shock_name_x' must be a string with 
%                 a shock name or a cellstr array with the 
%                 shock names. E.g 'E_X_NW' or {'E_X_NW','E_Y_NW'}.
%
%                 If empty no packing will be done.
%
%                 Caution : Not yet supported!
% 
% - 'startDate' : Start date of the decomposition. As a string. If
%                 different models has different frequency this date will
%                 be converted.
%
% - 'variables' : The variables to decompose. Default is the 
%                 dependent variables defined by the first model.
%
% Output:
% 
% - data    : Depend on the 'method' input:
%
%             > 'percentiles'   : A nHor x (nExo + nRes)*2 x nVars nb_ts  
%                                 object storing the uncertainty 
%                                 decomposition.
%
%             > {'fevd','fesd'} : A nHor x nRes x nVars nb_ts object 
%                                 storing the numerically calculated 
%                                 forecast error variances/skewnesses.
%             
% - plotter : A nb_graph_ts object which the method graph can be used to 
%             produce graphs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: This method only supports scalar nb_model_generic objects as input.'])
    end

    if ~issolved(obj)
        error([mfilename ':: The model must be solved to do uncertainty decomposition'])
    end

    % Parse the arguments
    %--------------------------------------------------------------
    default = {'method',                'percentiles',  {{@isa,'nb_model_generic'}};...
               'startDate',             '',             {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'packages',              {},             {@iscell,'||',@isempty};...
               'perc',                  0.9,            {@isscalar,'&&',@isnumeric};...
               'compare2',              [],             {{@isa,'nb_model_generic'}};...
               'variables',             {},             {@iscellstr}};...
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    switch lower(inputs.method)
        case 'percentiles'
            [data,plotter] = percentilesDecomposition(obj,inputs,nargout);
        case 'fev'
            [data,plotter] = fevd(obj,inputs,numOutArgs); 
        otherwise
            error([mfilename ':: Unsupported input given to the ''method'' option; ' inputs.method])
    end
    
end

%==========================================================================
function [data,plotter] = percentilesDecomposition(obj,inputs,numOutArgs)

    % Interpret perc option
    inputs.perc = nb_interpretPerc(inputs.perc,false);
    
    % Check some other inputs
    if ~isempty(inputs.compare2)
       if ~isscalar(inputs.variables)
           error([mfilename ':: When the ''compare2'' option is used the ''variables'' input can only contain on variable.'])
       end
    end
    
    % Do the uncertainty decomposition
    [fcstDL,fcstDU,exoAndRes,ind,indVD] = uncertaintyDecompEngine(obj,inputs);
    if ~isempty(inputs.compare2)
        [fcstDL2,fcstDU2,exoAndRes2,ind2,indVD2] = uncertaintyDecompEngine(inputs.compare2,inputs);
        
        [indT,loc] = ismember(exoAndRes2,exoAndRes);
        if any(~indT) || ~all(loc==1:size(loc,2))
            error([mfilename ':: The compare2 model must have the same exogenous and residuals as the main model, and they need to ordered in the same way.'])
        end
        
    end
    
    % Scale to the percentile of the endogenous variables
    forecastOutput    = obj.forecastOutput;
    fcst              = forecastOutput.data(:, :, 1:end-1, ind);
    dataEndo          = fcst(:,indVD,:); % nSteps x nexo x ndraws
    dataEndo          = bsxfun(@minus,dataEndo,mean(dataEndo,3));
    fcstDLE           = permute(prctile(dataEndo,inputs.perc(1),3),[1,3,2]);
    fcstDUE           = permute(prctile(dataEndo,inputs.perc(2),3),[1,3,2]);
    fcstDLS           = sum(fcstDL(2:end,:,:),2);
    fcstDUS           = sum(fcstDU(2:end,:,:),2);
    scaleDL           = fcstDLS./fcstDLE;
    scaleDU           = fcstDUS./fcstDUE;
    fcstDL(2:end,:,:) = bsxfun(@rdivide,fcstDL(2:end,:,:),scaleDL);
    fcstDU(2:end,:,:) = bsxfun(@rdivide,fcstDU(2:end,:,:),scaleDU);

    if isempty(inputs.compare2)
    
        dataNames = inputs.variables;
        
    else
        
        % Scale compare2 model as well
        forecastOutput2    = inputs.compare2.forecastOutput;
        fcst2              = forecastOutput2.data(:, :, 1:end-1, ind2);
        dataEndo2          = fcst2(:,indVD2,:); % nSteps x nexo x ndraws
        dataEndo2          = bsxfun(@minus,dataEndo2,mean(dataEndo2,3));
        fcstDLE2           = permute(prctile(dataEndo2,inputs.perc(1),3),[1,3,2]);
        fcstDUE2           = permute(prctile(dataEndo2,inputs.perc(2),3),[1,3,2]);
        fcstDLS2           = sum(fcstDL2(2:end,:,:),2);
        fcstDUS2           = sum(fcstDU2(2:end,:,:),2);
        scaleDL2           = fcstDLS2./fcstDLE2;
        scaleDU2           = fcstDUS2./fcstDUE2;
        fcstDL2(2:end,:,:) = bsxfun(@rdivide,fcstDL2(2:end,:,:),scaleDL2);
        fcstDU2(2:end,:,:) = bsxfun(@rdivide,fcstDU2(2:end,:,:),scaleDU2);
        
        % Preallocate
        fcstDLDN = zeros(size(fcstDL));
        fcstDLDP = zeros(size(fcstDL));
        fcstDUDN = zeros(size(fcstDL));
        fcstDUDP = zeros(size(fcstDL));
        
        % Get diff
        fcstDLD           = fcstDL - fcstDL2;
        indNeg            = fcstDLD < 0;
        fcstDLDN(indNeg)  = fcstDLD(indNeg);
        fcstDLDP(~indNeg) = fcstDLD(~indNeg);
        fcstDUD           = fcstDU - fcstDU2;
        indNeg            = fcstDUD < 0;
        fcstDUDN(indNeg)  = fcstDUD(indNeg);
        fcstDUDP(~indNeg) = fcstDUD(~indNeg);
        
        % Add
        fcstDL        = fcstDL(:,:,ones(1,2));
        fcstDU        = fcstDU(:,:,ones(1,2));
        fcstDL(:,:,1) = fcstDLDN;
        fcstDL(:,:,2) = -fcstDLDP;
        fcstDU(:,:,1) = fcstDUDP;
        fcstDU(:,:,2) = -fcstDUDN;
        
        dataNames     = {'Negativ','Positiv'};
         
    end
    
    % Check for error, or append parameter uncertianty
    if forecastOutput.parameterDraws > 1 
        error([mfilename ':: Parameter uncertainty is not yet supported!'])
    end
    
    % Construct output data
    allERP         = exoAndRes;%,'Parameters'
    varsOut        = [strcat('Lower_',allERP),strcat('Upper_',allERP)];
    data           = nb_ts([fcstDL,fcstDU],'',0,varsOut,false);
    data.dataNames = dataNames;
    
    % Construct graph
    if numOutArgs > 1
       
        fcstDL = cumsum(fcstDL,2);
        fcstDU = cumsum(fcstDU,2);
        
        % Construct graph data
        allERP         = exoAndRes;
        varsOut        = [strcat('Lower_',allERP),strcat('Upper_',allERP),'zero'];
        zeroVar        = zeros(size(fcstDU,1),1,size(fcstDU,3));
        data           = nb_ts([fcstDL,fcstDU,zeroVar],'',0,varsOut,false);
        data.dataNames = dataNames;
        
        cData = nb_defaultColors(length(allERP));
        patch = {};
        leg   = {};
        for ii = length(allERP):-1:1
            patchT = {[allERP{ii}],['Lower_',allERP{ii}],['Upper_',allERP{ii}],cData(ii,:)};
%             if ii == 1
%                 patchTL = {[allERP{ii},'_L'],['Lower_',allERP{ii}],'zero',cData(ii,:)};
%                 patchTU = {allERP{ii},'zero',['Upper_',allERP{ii}],cData(ii,:)};
%             else
%                 patchTL = {[allERP{ii},'_L'],['Lower_',allERP{ii}],['Lower_',allERP{ii-1}],cData(ii,:)};
%                 patchTU = {allERP{ii},['Upper_',allERP{ii-1}],['Upper_',allERP{ii}],cData(ii,:)};
%             end
            patch = [patch,patchT]; %#ok<AGROW>
            leg   = [leg,allERP(ii)]; %#ok<AGROW>
        end
        
        varD    = inputs.variables;
        plotter = nb_graph_ts(data);
        plotter.set('variablesToPlot',{'zero'},'lineWidths',{'zero',0.5},...
                    'patch',patch,'legends',leg,'title',varD);
        
    end
    
end

%==========================================================================
function [fcstDL,fcstDU,exoAndRes,ind,indVD] = uncertaintyDecompEngine(obj,inputs)

    % Get the density forecast
    forecastOutput = obj.forecastOutput;   
    assert(forecastOutput.draws > 1, 'No density forecast produced.');
    assert(isempty(forecastOutput.perc), 'All simulations were not returned.');
    
    startDate = inputs.startDate;
    if isempty(startDate)
        fcst      = forecastOutput.data(:, :, 1:end-1, end); % nSteps x nvar x ndraws
        startDate = forecastOutput.start{end};
        ind       = length(forecastOutput.start);
    else
        ind = strcmpi(toString(startDate),forecastOutput.start);
        if ~any(ind)
            error([mfilename ':: The ''date'' input provided is not found in forecastOutput.start'])
        end
        fcst = forecastOutput.data(:, :, 1:end-1, ind); % nSteps x nvar x ndraws
    end
    vars = forecastOutput.variables; 
    
    % Get the solution index
    if size(obj.solution.A,3) > 1
        endEst    = obj.estOptions.estim_end_ind;
        dataStart = nb_date.date2freq(obj.estOptions.dataStartDate);
        endEst    = dataStart + (endEst - 1);
        startD    = nb_date.date2freq(startDate);
        solInd    = size(obj.solution.A,3) - (startD - endEst);
    else
        solInd    = 1;
    end
    
    % Check that the shocks of the model are uncorrelated with 
    % variance 1
    vcv = obj.solution.vcv - eye(size(obj.solution.vcv,1));
    if any(vcv(:)~=0)
        error([mfilename ':: The shocks of the model must be uncorrelated and have unit variance.'])
    end
    
    % For VARs the shocks uncertainty is resampled given that the residual
    % are not identified, so we need to identify the structural shocks
    % later. Not yet supported for underidentified VARs though...
    inputs.transform = false;
    if isa(obj,'nb_var')
        if strcmpi(obj.solution.identification.type,'cholesky')
            inputs.transform = true;
        else
            error([mfilename ':: This method is not yet supported for underidentified VARs.'])
        end
    end
    
    % Variables to decompose
    model        = obj.solution;
    varD         = inputs.variables;
    [test,indVD] = ismember(varD,model.endo);
    if any(~test)
        error([mfilename ':: Some of the selected variables is not part of the model; ' toString(varD(~test))])
    end
    nVarD = length(varD);
    
    % Get the model solution
    A = model.A(:,:,solInd);
    B = model.B(:,:,solInd);
    if size(model.A,3) == 1 && size(model.C,3) > 1
        C = model.C(:,:,solInd);
    else
        C = model.C(:,:,solInd);
    end
    
    % Get the exo and shocks of the model
    [exo,indExo,res,indRes] = getExo(model,vars);
    exoAndRes               = [exo,res];
    dataExo                 = fcst(:,indExo,:); % nSteps x nexo x ndraws
    dataExo                 = bsxfun(@minus,dataExo,mean(dataExo,3));
    dataRes                 = fcst(:,indRes,:); % nSteps x nres x ndraws
    dataRes                 = bsxfun(@minus,dataRes,mean(dataRes,3));
    draws                   = size(fcst,3);
    nRes                    = size(dataRes,2);
    if inputs.transform
        dataRes = randn(size(dataRes));
    end
    
    % We here use as simulation approach as the shock uncertainty need
    % not be symmetric or normal
    hor      = size(fcst,1);
    nExo     = size(dataExo,2);
    nEndo    = size(A,1);
    fcstDL   = zeros(hor+1,nExo + nRes,nVarD);
    fcstDU   = zeros(hor+1,nExo + nRes,nVarD);
    dataER   = [dataExo,dataRes];
    Y        = zeros(nEndo,hor+1,draws);
    X        = zeros(nExo,hor,draws);
    E        = zeros(nRes,hor,draws);
    for ii = 1:nExo
        
        Yt         = Y;
        Xt         = X;
        Xt(ii,:,:) = permute(dataER(:,ii,:),[2,1,3]);
        for dd = 1:draws
            Yt(:,:,dd) = nb_computeForecastAnticipated(A,B,C,Yt(:,:,dd),Xt(:,:,dd),E(:,:,dd));
        end
        
        % Calculate the max and min impact
        fcstDL(:,ii,:) = permute(prctile(Yt(indVD,:,:),inputs.perc(1),3),[2,3,1]);
        fcstDU(:,ii,:) = permute(prctile(Yt(indVD,:,:),inputs.perc(2),3),[2,3,1]);
        
    end
    
    for ii = nExo+1:nExo+nRes
        
        Yt              = Y;
        Et              = E;
        Et(ii-nExo,:,:) = permute(dataER(:,ii,:),[2,1,3]);
        for dd = 1:draws
            Yt(:,:,dd) = nb_computeForecastAnticipated(A,B,C,Yt(:,:,dd),X(:,:,dd),Et(:,:,dd));
        end
        
        % Calculate the max and min impact
        fcstDL(:,ii,:) = permute(prctile(Yt(indVD,:,:),inputs.perc(1),3),[2,3,1]);
        fcstDU(:,ii,:) = permute(prctile(Yt(indVD,:,:),inputs.perc(2),3),[2,3,1]);
        
    end
       
end

%==========================================================================
function [exo,indExo,res,indRes] = getExo(model,variables)

    exo  = model.exo;
    indR = nb_ismemberi(exo,{'constant','time_trend'});
    exo  = exo(~indR);
    ind  = cellfun(@isempty,regexp(exo,'Seasonal_','start'));
    exo  = exo(ind);
    res  = model.res;
    
    [test,indExo] = ismember(exo,variables);
    if any(~test)
        error([mfilename ':: When producing the forecast you need to return the exogenous variables. '...
                         'See the option ''output'' of the forecast method.'])
    end
    
    [test,indRes] = ismember(res,variables);
    if any(~test)
        error([mfilename ':: When producing the forecast you need to return the residuals/shocks. '...
                         'See the option ''output'' of the forecast method.'])
    end

end

%==========================================================================
function [data,plotter] = fevd(obj,inputs,numOutArgs)

    % Get the density forecast
    forecastOutput = obj.forecastOutput;   
    assert(forecastOutput.draws > 1, 'No density forecast produced.');
    assert(isempty(forecastOutput.perc), 'All simulations were not returned.');
    
    if forecastOutput.parameterDraws > 1 
        error([mfilename ':: Parameter uncertainty is not yet supported for the when ''method'' is set to ''fevd''!'])
    end
    
    [test,indRes] = ismember(obj.solution.res,forecastOutput.variables);
    if any(~test)
        error([mfilename ':: When producing the forecast you need to return the residuals/shocks. '...
                         'See the option ''output'' of the forecast method.'])
    end
    
    startDate = inputs.startDate;
    if isempty(startDate)
        fcst      = forecastOutput.data(:, :, 1:end-1, end); % nSteps x nvar x ndraws
        startDate = forecastOutput.start{end};
    else
        ind = strcmpi(toString(startDate),forecastOutput.start);
        if ~any(ind)
            error([mfilename ':: The ''date'' input provided is not found in forecastOutput.start'])
        end
        fcst = forecastOutput.data(:, :, 1:end-1, ind); % nSteps x nvar x ndraws
    end
    
    % Get the solution index
    if size(obj.solution.A,3) > 1
        endEst    = obj.estOptions.estim_end_ind;
        dataStart = nb_date.date2freq(obj.estOptions.dataStartDate);
        endEst    = dataStart + (endEst - 1);
        startD    = nb_date.date2freq(startDate);
        solInd    = size(obj.solution.A,3) - (startD - endEst);
    else
        solInd    = 1;
    end

    % Variables to decompose
    model    = obj.solution;
    varD     = inputs.variables;
    [test,~] = ismember(varD,model.endo);
    if any(~test)
        error([mfilename ':: Some of the selected variables is not part of the model; ' toString(varD(~test))])
    end
    
    % Get the model solution
    if isfield(model,'Q')
        
        % If we are dealing with a MS model we need to integrate over different
        % regimes
        A = model.A;
        C = model.C;
        if isempty(inputs.regime)
            [A,C] = ms.integrateOverRegime(model.Q,A,C);
        else
            A = A{inputs.regime};
            C = C{inputs.regime};
        end
    else
        
        A = model.A(:,:,solInd);
        if size(model.A,3) == 1 && size(model.C,3) > 1
            C = model.C(:,:,solInd);
        else
            C = model.C(:,:,solInd);
        end
        
    end

    % Do the FEV
    data = decompEngine(fcst,A,C,model.res,indRes,obj.estOptions(end),inputs,startDate);
    if numOutArgs > 1   
        plotter = nb_graph_ts(data);
        plotter.set('plotType','stacked','noTitle',2,'figureName','Mean'); 
    end

end

%==========================================================================
function decomp = decompEngine(fcst,A,C,shocks,indRes,options,inputs,startDate) 
    
    vars = inputs.variables;

    dataRes = permute(fcst(:,indRes,:),[3,2,1]); % nSteps x nres x ndraws
    nSteps  = size(fcst,1);
    nRes    = length(shocks);
    if strcmpi(model.class,'nb_dsge')
        nEq = size(C,1);
    else
        nEq = size(C,2);
        C   = C(1:nEq,1:nEq);
    end
    sigma = zeros(nEq,nEq,nSteps);
    MSE   = zeros(nEq,nEq,nSteps);
    MSE_j = zeros(nEq,nEq,nSteps);
    FEV   = zeros(nSteps,nEq,nEq);
    for jj = 1:nSteps
        sigma(:,:,jj) = C*cov(dataRes(:,:,jj))*C';
    end
    
    % Construct the multipliers
    RHO = A(:,:,ones(1,nSteps-1));
    for kk = 2:nSteps-1
        RHO(:,:,kk) = RHO(:,:,kk-1)*A;
    end
    RHO = RHO(1:nEq,1:nEq,:);
    
    % Calculate Total Mean Squared Error
    MSE(:,:,1) = sigma(:,:,1);
    for kk = 1:nSteps-1
       MSE(:,:,kk+1) = MSE(:,:,kk) + RHO(:,:,kk)*sigma(:,:,kk+1)*RHO(:,:,kk)';
    end
    
    % Total forecast error variance
    FEVT = zeros(nSteps,1,nEq);
    for nn = 1:nSteps
        FEVT(nn,1,:) = permute(diag(MSE(:,:,nn)),[2,3,1]);
    end
    
    % Calculate the MSE error of each residual shock
    for mm = 1:nRes 
    
        % Get the column of C corresponding to the mm_th shock
        sigma_j          = zeros(nRes,nRes,nSteps);
        sigma_j(mm,mm,:) = sigma(mm,mm,:);

        % Compute the mean square error
        MSE_j(:,:,1) = sigma_j;
        for kk = 1:nSteps-1
            MSE_j(:,:,kk+1) = MSE_j(:,:,kk) + RHO(:,:,kk)*sigma_j*RHO(:,:,kk)';   
        end

        % Select only the variance terms
        for nn = 1:nSteps
            FEV(nn,mm,:) = permute(diag(MSE_j(:,:,nn)),[2,3,1]);
        end
        
    end
    
    % Get dependent variables
    if isfield(options,'dependent')
        dep = options.dependent;
    else
        dep = model.endo; % DSGE models
    end
    if isfield(options,'block_exogenous')
        dep = [dep, options.block_exogenous];
    end
    
    % Reorder stuff
    nVars            = length(vars);
    [fV,indV]        = ismember(dep,vars);
    indV             = indV(fV);
    decomp           = nan(nSteps,nRes+1,nVars);
    decomp(:,:,indV) = FEV(:,:,fV);
    
    % Make a rest variable
    decomp(:,end,:) = FEVT - sum(decomp(:,1:end-1,:),2);
    
    % Merge output and reorder things
    shocks = obj.solution.res;
    vars   = inputs.variables;

    % Get the the primary output
    %---------------------------------------------
    shocks         = [shocks,'Rest'];
    data           = nb_ts(decomp,'',startDate,shocks);
    data.dataNames = vars;
    decomp         = data; 
    
end

