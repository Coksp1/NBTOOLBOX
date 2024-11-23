function XAR = estimateAndBootstrapX(opt,restr,draws,index,inputs,type)
% Syntax:
%
% XAR = nb_forecast.estimateAndBootstrapX(opt,restr,draws,index,...
%                   inputs,type)
%
% Description:
%
% This is the function that project the exogenous variables of the model
% when the 'exoProj' input is not empty.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        type = 'X';
    end
    if strcmpi(type,'Z')
        exo     = restr.exoObs(restr.indExoObs(:,:,restr.index));
        nSteps  = size(restr.Z,1);
    else
        exo     = restr.exo(restr.indExo(:,:,restr.index));
        nSteps  = size(restr.X,1);
    end
    exoKeep       = exo;
    inputs        = nb_defaultField(inputs,'exoProjHist',false);
    inputs        = nb_defaultField(inputs,'exoProjAR',nan);
    inputs        = nb_defaultField(inputs,'exoProjDummies',{});
    inputs        = nb_defaultField(inputs,'exoProjCalib',{});
    inputs        = nb_defaultField(inputs,'exoProjDiff',{});
    deterministic = nb_forecast.getDeterministicVariables(exoKeep);

    switch lower(inputs.exoProj)
        
        case {'ar','rw'}

            % Get the historical data
            indR   = nb_ismemberi(exo,deterministic);
            exo    = exo(~indR);
            if isempty(exo)
               XAR = nan(0,nSteps,draws);
               return
            end
            if strcmpi(restr.class,'nb_ecm')
                % Remove level variables
                [exoT,restr] = ecmCorrections(opt,restr,exo);
            else
                exoT = unique(regexprep(exo,'_lag[0-9]+$','')); % Remove lags to reduce estimation burden 
            end
            [test,indX] = ismember(exoT,opt.dataVariables);
            if any(~test)
                [~,indX] = ismember(exo,opt.dataVariables);
                exoT     = exo;
            end

            eInd = index;
            if isempty(opt.rollingWindow)
                sInd = opt.estim_start_ind;
            else
                sInd = eInd - opt.rollingWindow + 1;
            end

            Xall  = opt.data(sInd:end,indX);
            X     = opt.data(sInd:eInd,indX);
            nExo  = size(X,2);
            T     = size(X,1);
            maxAR = min(10,ceil(T/10));
            if maxAR < 0
                error([mfilename ':: Cannot fit an AR process to the short sample period (' int2str(T) ')'])
            end
            
            XAR = nan(nExo,nSteps,draws);
            for ii = 1:nExo

                % The series of this exogenous
                Xt = X(:,ii);
                if size(Xall,1) > size(X,1) && inputs.exoProjHist 
                    % Do we already have some more data?
                    XtExtra = Xall(size(X,1)+1:end,ii);
                    XtExtra = XtExtra(~isnan(XtExtra));
                    if size(XtExtra,1) > nSteps
                        XtExtra = XtExtra(1:nSteps);
                    end
                    Xt      = [Xt;XtExtra]; %#ok<AGROW>
                    nExtra  = size(XtExtra,1);
                    nStepsT = nSteps - nExtra;
                else
                    % Do we have any conditional info we got from the
                    % condDB input? See nb_forecast.prepareRestrictions
                    if strcmpi(type,'Z')
                        XtExtra = restr.Z(:,strcmpi(exoT{ii},restr.exoObs));
                    else
                        XtExtra = restr.X(:,strcmpi(exoT{ii},restr.exo));
                    end
                    XtExtra = XtExtra(~isnan(XtExtra));
                    Xt      = [Xt;XtExtra]; %#ok<AGROW>
                    nExtra  = size(XtExtra,1);
                    nStepsT = nSteps - nExtra;
                end
                
                % Take differences
                doUndiff = false;
                if ~isempty(inputs.exoProjDiff)
                    loc = find(strcmpi(exoT{ii},inputs.exoProjDiff),1,'last');
                    if ~isempty(loc)
                        if inputs.exoProjDiff{loc+1}
                            xHist    = X(end,ii); % Last observation on historical data
                            Xt       = diff(Xt,1);
                            doUndiff = true;
                        end
                    end
                end
                
                if nStepsT == 0
                    % No more observations to predict.
                    XV = nan(0,1);
                else
                
                    % Are we using dummy variables?
                    if ~isempty(inputs.exoProjDummies)
                        [test,indT] = ismember(inputs.exoProjDummies,opt.dataVariables);
                        if any(~test)
                            error(['The following variables given to the exoProjDummies input is not ',...
                                   'found in the data; ' toString(inputs.exoProjDummies(~test))])
                        end
                        endIndT           = sInd + size(Xt,1) - 1;
                        texo              = opt.data(sInd:endIndT,indT);
                        texo(isnan(texo)) = 0;
                        ind               = ~all(abs(texo) < eps);
                        texo              = texo(:,ind);
                    else
                        texo = nan(size(Xt,1),0);
                    end
                    
                    if all(isnan(Xt) | abs(Xt) < eps)
                        if all(isnan(Xt))
                            XAR(ii,:,:) = nan;
                        else
                            XAR(ii,:,:) = 0;
                        end
                        continue
                    end
                    
                    % Estimate model
                    if strcmpi(inputs.exoProj,'rw')
                        if ~isempty(texo)
                            error('Cannot use the exoProjDummies when exoProj is set to ''rw''.')
                        end
                        lambda = [0;1]; % Random walk
                        reg    = Xt;
                        reg    = reg(~any(isnan(reg),2),:);
                        int    = 0;
                        calib  = true;
                        numAR  = 1;
                        nExoT  = 0;
                    else
                        if isempty(inputs.exoProjCalib)
                            loc = [];
                        else
                            loc = find(strcmp(exoT{ii},inputs.exoProjCalib(1:2:end)));
                        end
                        if isempty(loc)
                            results = nb_arimaFunc(Xt,inputs.exoProjAR,0,0,0,0,'maxAR',maxAR,'constant',true,...
                                            'test',false,'alpha',0.1,'texo',texo);
                            lambda  = results.beta;
                            reg     = Xt - lambda(1);
                            int     = results.i;
                            calib   = false;
                            numAR   = results.AR;
                            nExoT   = size(texo,2);
                        else
                            lambda = inputs.exoProjCalib{loc*2};
                            if ~nb_sizeEqual(lambda,[1,2])
                                error(['The calibrated AR process of the exogenous variable ',... 
                                    exoT{ii} ' is not correct. Must be a 1x2 double. Check the exoProjCalib ',...
                                    'input.'])
                            end
                            lambda = lambda';
                            reg    = Xt - lambda(1);
                            reg    = reg(~any(isnan(reg),2),:);
                            int    = 0;
                            calib  = true;
                            numAR  = 1;
                            nExoT  = 0;
                        end
                        
                    end
                    
                    t   = size(reg,1);
                    reg = [ones(t,1),reg]; %#ok<AGROW>
                    if int > 1
                        error([mfilename ':: The maximum degree of integration for exogenous variables is 1.'])
                    end

                    % Bootstrap model
                    if inputs.parameterDraws > 1 && ~calib
                        E       = nb_bootstrap(results.residual,1,'bootstrap'); % A nEq x 1 x nobs double
                        E       = permute(E,[3,1,2]); % A nobs x nEq x 1 double
                        Xart    = lambda(1) + results.X*lambda(2:end) + E;
                        texo    = texo(size(Xt,1) - size(Xart,1) + 1:end,:);
                        results = nb_arimaFunc(Xart,results.AR,int,0,0,0,'constant',true,'test',false,'texo',texo);
                        lambda  = results.beta;
                    end

                    % Residual std
                    if calib
                        % Calculate the residuals given the calibrated
                        % parameter values. Here we used the demeaned
                        % series for calibrated parameters, and original
                        % series for 'rw'.
                        resid = reg(2:end,2) - reg(1:end-1,2)*lambda(2);
                    else
                        resid = results.residual;
                    end
                    vcv = sqrt(resid'*resid/(size(resid,1) - size(lambda,1)));
                    
                    % Produce density forecast
                    N     = numAR - 1;
                    I     = eye(N);
                    A     = [lambda(2:end-nExoT,:)';I,zeros(N,1)];
                    B     = lambda(1,:); % Assume that texo is forecast by zeros!
                    C     = [vcv;zeros(N,1)];
                    Y     = nan(N+1,nStepsT+1,draws);
                    try
                        y0 = reg(end-N:end,2);
                    catch

                        fInd           = size(reg,1);
                        y0             = nan(N+1,1,1);
                        ind            = fInd-N:fInd;
                        y0(ind(ind>0)) = reg(ind(ind>0),ii);

                        % Set missing initial values to estimated mean
                        y0(isnan(y0)) = lambda(1,:);

                    end
                    y0       = flip(y0,1);
                    Y(:,1,:) = y0(:,:,ones(1,draws));
                    if draws == 1
                        E = zeros(1,nStepsT,draws);
                    else
                        E = randn(1,nStepsT,draws); 
                    end
                    for dd = 1:draws
                        for t = 1:nStepsT
                            Y(:,t+1,dd) = A*Y(:,t,dd) + C*E(:,t,dd);
                        end
                    end
                    XV = bsxfun(@plus,Y(1,2:end,:), B);% Add constant
                    if int > 0
                        XF = permute([reg(end,2,ones(1,draws)),XV],[2,1,3]);
                        XF = nb_undiff(XF,Xt(end),1);
                        XV = permute(XF(2:end,1,:),[2,1,3]);
                    end
                    
                end
                
                if nExtra > 0
                    % Add observations found in the dataset
                    Xhist = Xt(end-nExtra+1:end,1)';
                    XV    = [Xhist(:,:,ones(1,draws)),XV]; %#ok<AGROW>
                end
                
                % Do undiff
                if doUndiff
                    XUD = nb_undiff(permute([nan(1,1,draws), XV],[2,1,3]),xHist);
                    XV  = permute(XUD(2:end,:),[2,1,3]);
                end
                
                % Assign final output
                XAR(ii,:,:) = XV; 

            end
            
            % Do we need to add level variables of nb_ecm model?
            exoNames = exoT;
            indR     = nb_ismemberi(exoKeep,deterministic);
            exo      = exoKeep(~indR);
            if strcmpi(restr.class,'nb_ecm')
                exoD      = strrep(opt.rhs,'diff_','');
                exoD      = regexprep(exoD,'_lag\d{1,2}$','');
                exoD      = unique(exoD);
                exoD      = exoD(~strcmpi(exoD,strrep(opt.dependent,'diff_','')));
                XARE      = nan(length(exoD),size(XAR,2),size(XAR,3));
                endoD     = sort(strcat('diff_',opt.endogenous));
                [~,indXL] = ismember(exoD,opt.dataVariables);
                XLhist    = opt.data(eInd-1:eInd,indXL);
                XLhist    = XLhist(:,:,ones(1,draws));
                nLag      = 1; 
                for ii = 1:length(exoD)
                    indE = find(strcmpi(endoD{ii},exoNames),1);
                    if ~isempty(indE)
                        E            = [nan(1,1,draws);permute(XAR(indE,1:end-1,:),[2,1,3])]; % diff
                        E            = nb_undiff(E,XLhist(end,ii,:),nLag);
                        XARE(ii,:,:) = permute(E,[2,1,3]);
                    end
                end
                XAR      = [XAR;XARE];
                exoNames = [exoNames,strcat(exoD,'_lag1')];
            end
            
            % Do we need to construct lagged variables?
            if any(~ismember(exo,exoNames))
                indR  = ismember(exo,exoNames);
                exoD  = exo(~indR);
                exoDM = regexprep(exoD,'_lag[0-9]+$','');
                XARE  = nan(length(exoD),size(XAR,2),size(XAR,3));
                Xhist = X(:,:,ones(1,draws));
                for ii = 1:length(exoD)
                    nLag = str2double(regexp(exoD{ii},'[0-9]+$','match'));
                    indE = find(strcmpi(exoDM{ii},exoNames),1);
                    if nLag >= nSteps
                        E = Xhist(end-nLag+1:end - (nLag - nSteps),indE,:);
                    else
                        E = [Xhist(end-nLag+1:end,indE,:);permute(XAR(indE,1:end-nLag,:),[2,1,3])];
                    end
                    XARE(ii,:,:) = permute(E,[2,1,3]);
                end
                XAR      = [XAR;XARE];
                exoNames = [exoNames,exoD];
                
            end
            
            % Reorder stuff so it gets correct
            [~,indR] = ismember(exo,exoNames);
            XAR      = XAR(indR,:,:);
        
        case 'var'
            
            if strcmpi(restr.class,'nb_ecm')
                error([mfilename ':: The ''expProj'' cannot be set to ''var'' when dealing with ECM models.'])
            end
            
            indR   = nb_ismemberi(exo,deterministic);
            exo    = exo(~indR);
            if isempty(exo)
               XAR = nan(0,nSteps,draws);
               return
            end
            f = nb_date.getFreq(opt.dataStartDate);
            switch f
                case 1
                    func = @(x)nb_year(x);
                case 2
                    func = @(x)nb_semiAnnual(x);
                case 4
                    func = @(x)nb_quarter(x);
                case 12
                    func = @(x)nb_month(x);
            end
            exoT              = unique(regexprep(exo,'_lag[0-9]+$','')); % Remove lags to reduce estimation burden 
            [ ~, indX]        = ismember(exoT,opt.dataVariables);
            t                 = nb_var.template();
            t.dependent       = opt.dataVariables(indX);
            data              = nb_ts(opt.data(:,indX),'double',opt.dataStartDate,t.dependent);
            t.data            = data;
            t.nLags           = opt.nLags;
            t.constant        = opt.constant;
            t.covrepair       = opt.covrepair;
            if opt.recursive_estim == 1
                t.recursive_estim            = 1;
                t.recursive_estim_start_date = func(opt.dataStartDate)+ ...
                                         opt.recursive_estim_start_ind - 1;
            else
                t.recursive_estim = 0;
            end
            
            var    = nb_var(t);
            var    = estimate(var);
            var    = solve(var);
            nSteps = size(restr.Y,1);
            if inputs.parameterDraws > 1   
                var   = forecast(var,nSteps,'draws',draws,'parameterDraws',...  
                            inputs.parameterDraws,'method',inputs.method);
            else
                var = forecast(var,nSteps,'draws',draws);%,'draws',1000
            end
            
            XAR = var.forecastOutput.data';

        otherwise
            error([mfilename ':: The ''exoProj'' method ' inputs.exoProj ' is not supported.'])
        
    end

end

%==========================================================================
function [exoT,restr] = ecmCorrections(opt,restr,exo)

    % Remove level variables, and only extrapolate one first difference.
    % Level variables are constructed from these later
    indR = cellfun(@isempty,regexp(exo,'diff_'));
    indT = ismember(exo,opt.exogenous);
    indR = ~indT & indR;
    exoR = exo(~indR); 
    exoT = unique(regexprep(exoR,'_lag[0-9]+$','')); % Remove lags to reduce estimation burden 

    % Secure conditional information on non-lagged exogenous
    test = ~ismember(exoT,restr.exo);
    if any(test)
        exoM = exoT(test);
        for ii = 1:length(exoM)
            lags = 1;
            cond = true;
            maxI = 21;
            while cond && lags < maxI
                exoTest = strcat(exoM{ii},'_lag', int2str(lags));
                indTest = strcmp(exoTest,restr.exo);
                if any(indTest)
                    XTest     = lead(restr.X(:,indTest),lags);
                    restr.X   = [restr.X,XTest];
                    restr.exo = [restr.exo,exoM(ii)];
                    cond      = false;
                else
                    lags = lags + 1;
                end
            end
        end
    end
    
end
