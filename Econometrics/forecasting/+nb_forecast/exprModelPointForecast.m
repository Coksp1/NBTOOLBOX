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
    exoLeft            = setdiff(options.exogenousOrig,inputs.condDBVars);
    deterministic      = nb_forecast.getDeterministicVariables(exoLeft);
    if ~isempty(exoLeft)
        
        nExoLeft      = length(exoLeft);
        opt           = options;
        restr         = restrictions;
        opt.exogenous = exoLeft;
        restr.exo     = exoLeft;
        restr.indExo  = true(1,nExoLeft);
        restr.X       = nan(nSteps,0);
        restr.class   = 'nb_exprModel';
        
        % Are there some variables in levels?
        eInd = restr.start;
        if isempty(opt.rollingWindow)
            sInd = opt.estim_start_ind;
        else
            sInd = eInd - opt.rollingWindow + 1;
        end
        doUndiff = false(1,nExoLeft);
        varInd   = nan(1,nExoLeft);
        eIndOne  = nan(1,nExoLeft);
        for ii = 1:nExoLeft
            if ~any(strcmpi(exoLeft{ii},deterministic))
                varInd(ii)  = find(strcmp(exoLeft{ii},opt.dataVariables),1);
                dataOne     = opt.data(sInd:end,varInd(ii));
                eIndOne(ii) = find(~isnan(dataOne),1,'last');
                dataOne     = dataOne(1:eIndOne(ii),:);
                if size(dataOne,1)  < 10
                    error([mfilename ':: If you use the expProj options with a model of class ',...
                                     'nb_exprModel you need at least 10 observations for first recursion. ',...
                                     'Has only ' int2tr(size(dataOne,1)) '. You can fix this by setting the ',...
                                     'startDate option during forecast or the recursive start date during estimation.'])
                end
                if ~all(diff(dataOne,1) == 0,1)
                    loc = find(strcmpi(exoLeft{ii},inputs.exoProjDiff),1,'last');
                    if isempty(loc)
                        res = nb_adf(dataOne);
                        if res.rhoPValue > 0.05
                            dataOne      = nb_diff(dataOne,1);
                            doUndiff(ii) = true;
                        end
                    else
                        if inputs.exoProjDiff{loc+1}
                            dataOne      = nb_diff(dataOne,1);
                            doUndiff(ii) = true;
                        end
                    end
                    opt.data(sInd:sInd+eIndOne(ii)-1,varInd(ii)) = dataOne;
                end
            end
        end
        
        % Correct for potential use of diff operator!
        opt.estim_start_ind = sInd + 1;
        
        % Forecast exogenous variables
        %eIndMin = min(eIndOne) + sInd - 1;
        XAR     = nb_forecast.estimateAndBootstrapX(opt,restr,1,eInd,inputs,'X')';
        if size(XAR,2) < length(exoLeft)
            indCovid = nb_contains(exoLeft,'covidDummy');
            if sum(indCovid) < length(exoLeft) - size(XAR,2) 
                error([mfilename ':: There are some exogenous variables that has not been projected properly. Contact NB toolbox development team.'])
            end
            XAROld           = XAR;
            XAR              = zeros(size(XAR,1),length(exoLeft));
            XAR(:,~indCovid) = XAROld;
        end
        
        % Do undiff
        if any(doUndiff)
            XUD             = nb_undiff([nan(1,sum(doUndiff)); XAR(:,doUndiff)],options.data(eInd,varInd(doUndiff)));
            XAR(:,doUndiff) = XUD(2:end,:);
        end
        
        % Merge with conditional inprmations
        if inputs.condDBStart == 0
            XAR = [nan(1,nExoLeft); XAR];    
        end
        if size(inputs.condDB,1) < size(XAR,1)
            d             = size(XAR,1) - size(inputs.condDB,1);
            inputs.condDB = [inputs.condDB; nan(d,size(inputs.condDB,2))];
        end
        inputs.condDB     = [inputs.condDB, XAR];
        inputs.condDBVars = [inputs.condDBVars, exoLeft];

    end
        
end
