function [Y,X,dep] = exprModelForecast(Z,E,nSteps,options,restrictions,results,inputs,model,iter)
% Syntax:
%
% [Y,X,dep] = nb_forecast.exprModelForecast(Z,E,nSteps,options,...
%                restrictions,results,inputs,model,iter)
%
% Description:
%
% Core function for producing forecast from a model using expressions.
%
% This function does not handle Markov switching models!
%
% See also:
% nb_forecast.exprModelPointForecast, nb_forecast.exprModelDensityForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Infomration
    dep        = options.dependentOrig;
    [~,indDep] = ismember(dep,options.dataVariables);
    
    % Produce forecast
    t    = restrictions.start;
    beta = results.beta;
    if size(beta{1},3) > 1
        for ii = 1:size(beta,2)
            beta{ii} = beta{ii}(:,:,iter);
        end
    end
    Zhist = Z(1:t,:);
    T     = size(Z,1);
    left  = min(T - t,nSteps);
    if left < 1
        Zcond = nan(nSteps,size(Z,2));
    else
        Zcond           = [Z(t+1:t+left,:);nan(nSteps-left,size(Z,2))];
        Zcond(:,indDep) = nan; % Remove conditional info on dependent
    end
    if ~isempty(inputs.condDB)
        % Fill in conditional information
        [~,locCI] = ismember(inputs.condDBVars,options.dataVariables);
        if inputs.condDBStart == 0
            ZcondTemp = inputs.condDB(2:end,:);
        else
            ZcondTemp = inputs.condDB;
        end
        h                = size(ZcondTemp,1);
        Zcond(1:h,locCI) = ZcondTemp;
    end
    Z = [Zhist;Zcond];
    for ii = 1:nSteps
        Z = model.fcstHandle(Z,t+ii,E,ii,beta);
    end
    Z = Z(t+1:t+nSteps,:);
    
    % Create reported variables
    vars    = options.dataVariables;
    varsRep = vars;
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            indRepRemove = ismember(inputs.reporting(:,1),dep);
            dep          = [dep, inputs.reporting(~indRepRemove,1)'];
            [Z,varsRep]  = nb_forecast.createReportedVariables(options,inputs,Z,vars,restrictions.start,iter);
        end
    end
    
    % Split forecast and reorder
    [~,locDepA]  = ismember(dep,varsRep);
    Y            = Z(:,locDepA);
    [ind,locExo] = ismember(model.exo,options.dataVariables);
    X            = Z(:,locExo(ind));
    if options.time_trend
        X = [(t+1:t+nSteps)',X];
    end
    if options.constant
        X = [ones(size(X,1),1),X];
    end
    
end
