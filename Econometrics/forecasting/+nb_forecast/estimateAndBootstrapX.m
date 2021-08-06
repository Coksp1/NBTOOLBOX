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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        type = 'X';
    end
    if strcmpi(type,'Z')
        exo    = restr.exoObs(restr.indExoObs);
        nSteps = size(restr.Z,1);
    else
        exo    = restr.exo(restr.indExo);
        nSteps = size(restr.X,1);
    end
    exoKeep       = exo;
    inputs        = nb_defaultField(inputs,'exoProjHist',false);
    inputs        = nb_defaultField(inputs,'exoProjAR',nan);
    inputs        = nb_defaultField(inputs,'exoProjDummies',{});
    inputs        = nb_defaultField(inputs,'exoProjCalib',{});
    deterministic = nb_forecast.getDeterministicVariables(exoKeep);

    switch lower(inputs.exoProj)
        
        case 'ar'

            % Get the historical data
            indR   = nb_ismemberi(exo,deterministic);
            exo    = exo(~indR);
            if isempty(exo)
               XAR = nan(0,nSteps,draws);
               return
            end
            if strcmpi(restr.class,'nb_ecm')
                % Remove level variables
                indR = cellfun(@isempty,regexp(exo,'diff_'));
                indT = ismember(exo,opt.exogenous);
                indR = ~indT & indR;
                exo  = exo(~indR); 
                exoT = unique(regexprep(opt.exogenous,'_lag[0-9]+$','')); % Remove lags to reduce estimation burden 
                exoT = [exoT,strcat('diff_',opt.endogenous)];
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
                    nStepsT = nSteps;
                    nExtra  = 0;
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
                    if isempty(inputs.exoProjCalib)
                        loc = [];
                    else
                        loc = find(strcmp(exoT{ii},inputs.exoProjCalib{1:2:end}));
                    end
                    if isempty(loc)
                        results = nb_arimaFunc(Xt,inputs.exoProjAR,0,0,0,0,'maxAR',maxAR,'constant',true,...
                                        'test',false,'alpha',0.1,'texo',texo);
                        lambda  = results.beta;
                        reg     = results.X;
                        int     = results.i;
                        calib   = false;
                        numAR   = results.AR;
                    else
                        lambda = inputs.exoProjCalib{loc*2};
                        if ~nb_sizeEqual(lambda,[1,2])
                            error(['The calibrated AR process of the exogenous variable ',... 
                                exoT{ii} ' is not correct. Must be a 1x2 double. Check the exoProjCalib ',...
                                'input.'])
                        end
                        lambda = lambda';
                        reg    = Xt - lambda(1);
                        reg    = [reg,lag(Xt)]; %#ok<AGROW>
                        reg    = reg(~any(isnan(reg),2),:);
                        int    = 0;
                        calib  = true;
                        numAR  = 1;
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
                        Xart    = reg*lambda + E;
                        texo    = texo(size(Xt,1) - size(Xart,1) + 1:end,:);
                        results = nb_arimaFunc(Xart,results.AR,int,0,0,0,'constant',true,'test',false,'texo',texo);
                        lambda  = results.beta;
                    end

                    % Residual std
                    if calib
                        vcv = 0;
                    else
                        resid = results.residual;
                        vcv   = sqrt(resid'*resid/(size(resid,1) - size(lambda,1)));
                    end
                    
                    % Produce density forecast
                    nExoT = size(texo,2);
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
                    %y0       = bsxfun(@minus,y0, B);
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
                
                % Assign final output
                XAR(ii,:,:) = XV; 

            end
            
            exoNames = exoT;
            if any(~ismember(exo,exoT))
               
                % Here we need to construct lagged variables
                indR  = ismember(exo,exoT);
                exoD  = exo(~indR);
                exoDM = regexprep(exoD,'_lag[0-9]+$','');
                XARE  = nan(length(exoD),size(XAR,2),size(XAR,3));
                Xhist = X(:,:,ones(1,draws));
                for ii = 1:length(exoD)
                    nLag = str2double(regexp(exoD{ii},'[0-9]+$','match'));
                    indE = find(strcmpi(exoDM{ii},exoT),1);
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
            
            indR = nb_ismemberi(exoKeep,deterministic);
            exo  = exoKeep(~indR);
            if strcmpi(restr.class,'nb_ecm')
                % Add level variables
                exoD      = strrep(opt.rhs,'diff_','');
                exoD      = regexprep(exoD,'_lag\d{1,2}$','');
                exoD      = unique(exoD);
                exoD      = exoD(~strcmpi(exoD,strrep(opt.dependent,'diff_','')));
                exoD      = strcat(exoD,'_lag1');
                XARE      = nan(length(exoD),size(XAR,2),size(XAR,3));
                endoD     = strcat('diff_',opt.endogenous);
                [~,indX]  = ismember(endoD,opt.dataVariables);
                Xhist     = opt.data(sInd:eInd,indX);
                Xhist     = Xhist(:,:,ones(1,draws));
                [~,indXL] = ismember(exoD,opt.dataVariables);
                XLhist    = opt.data(eInd:eInd,indXL);
                XLhist    = XLhist(:,:,ones(1,draws));
                nLag      = 1; 
                for ii = 1:length(exoD)
                    indE         = find(strcmpi(endoD{ii},exoNames),1);
                    E            = [Xhist(end-nLag+1:end,ii,:);permute(XAR(indE,1:end-1,:),[2,1,3])]; % Lagged diff
                    E            = nb_undiff(E,XLhist(:,ii,:),1);
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
            
            XAR      = var.forecastOutput.data';

        otherwise
            error([mfilename ':: The ''exoProj'' method ' inputs.exoProj ' is not supported.'])
        
    end

end
