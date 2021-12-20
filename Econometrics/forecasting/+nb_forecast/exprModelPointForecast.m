function [Y,evalFcst] = exprModelPointForecast(Z,restrictions,model,options,results,nSteps,iter,actual,inputs)
% Syntax:
%
% [Y,evalFcst] = nb_forecast.exprModelPointForecast(Z,restrictions,...
%                   model,options,results,nSteps,iter,actual,inputs)
%
% Description:
%
% Produce point forecast of a model using expressions.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try options = options(iter); catch; end %#ok<CTCH>
    
    % Check if we are going to extrapolate exogenous variables
    if ~isempty(inputs.exoProj)
        inputs = doExoProj(options,inputs,restrictions,nSteps);
    end
    
    % Produce forecast
    nDep      = length(options.dependentOrig);
    E         = zeros(nDep,nSteps); % No disturbances
    [Y,X,dep] = nb_forecast.exprModelForecast(Z,E,nSteps,options,restrictions,results,inputs,model,iter);
    
    % Merge with exogenous and shocks if wanted
    vars = dep;
    if strcmpi(inputs.output,'all') || strcmpi(inputs.output,'full')
        if isempty(inputs.missing)
            vars = [vars,model.exo,model.res];
            Y    = [Y,X,permute(E(:,1:nSteps),[2,1,3])];
        end
    end
    
    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            varsOI = cellstr(inputs.varOfInterest);
        else
            varsOI = inputs.varOfInterest;
        end
        [ind,indV] = ismember(varsOI,vars);
        if any(~ind)
            error([mfilename ':: The following variables are not forecasted (incl reporting) by the model; ' toString(varsOI(~ind))])
        end
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = varsOI;
    end
    
    % Check for missing data on exogenous
    test = isnan(Y);
    if any(test(:))
        ind = any(test,2);
        warning('nb_forecast:exprModel:missingConditionalInformation',...
              [mfilename ':: Could only forecast ' int2str(nSteps - sum(ind)) ' period(s)',...
              '. This is probably due to missing conditional information on ',...
              'the exogenous. Forecast will be appended by nan values, and graphs will ',...
              'only plot a ' int2str(nSteps - sum(ind)) ' step forecast. Look also for warnings ',...
              'during reporting.'])
    end
    
    % Evaluate point forecast 
    evalFcst = nb_forecast.evaluatePointForecast(Y(:,1:length(dep)),actual,dep,model,inputs);
        
end

%==========================================================================
function inputs = doExoProj(options,inputs,restrictions,nSteps)

    inputs             = nb_defaultField(inputs,'exoProjDiff',{});
    inputs.exoProjHist = true;
    if ~isempty(options.exogenousOrig)
        
        nExoLeft      = length(options.exogenousOrig);
        opt           = options;
        restr         = restrictions;
        opt.exogenous = options.exogenousOrig;
        restr.exo     = options.exogenousOrig;
        restr.indExo  = true(1,nExoLeft);
        restr.X       = nan(nSteps,nExoLeft);
        restr.class   = 'nb_exprModel';
        
        % Add conditional info
        if inputs.condDBStart == 0
            start = 2;
        else 
            start = 1;
        end
        indCondExo            = ismember(inputs.condDBVars,options.exogenousOrig);
        exoCond               = inputs.condDBVars(indCondExo);
        [~,locExoLeft]        = ismember(exoCond,options.exogenousOrig);
        restr.X(:,locExoLeft) = inputs.condDB(start:end,indCondExo);
        
        % Are there some variables in levels?
        eInd = restr.start;
        if isempty(opt.rollingWindow)
            sInd = opt.estim_start_ind;
        else
            sInd = eInd - opt.rollingWindow + 1;
        end
        
        % Correct for potential use of diff operator!
        opt.estim_start_ind = sInd + 1;
        
        % Forecast exogenous variables
        XAR = nb_forecast.estimateAndBootstrapX(opt,restr,1,eInd,inputs,'X')';
        if size(XAR,2) < length(options.exogenousOrig)
            indCovid = nb_contains(options.exogenousOrig,'covidDummy');
            if sum(indCovid) < length(options.exogenousOrig) - size(XAR,2) 
                error([mfilename ':: There are some exogenous variables that has not been projected properly. Contact NB toolbox development team.'])
            end
            XAROld           = XAR;
            XAR              = zeros(size(XAR,1),length(options.exogenousOrig));
            XAR(:,~indCovid) = XAROld;
        end
        
        % Merge with conditional inprmations
        if inputs.condDBStart == 0
            XAR = [nan(1,nExoLeft); XAR];    
        end
        if size(inputs.condDB,1) < size(XAR,1)
            d             = size(XAR,1) - size(inputs.condDB,1);
            inputs.condDB = [inputs.condDB; nan(d,size(inputs.condDB,2))];
        end
        
        indNotExo         = ~ismember(inputs.condDBVars,options.exogenousOrig);
        X                 = [inputs.condDB(:,indNotExo),XAR];
        order             = [inputs.condDBVars(indNotExo),options.exogenousOrig];
        inputs.condDB     = X;
        inputs.condDBVars = order;

    end
        
end
