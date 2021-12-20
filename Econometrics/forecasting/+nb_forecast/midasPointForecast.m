function [Y,evalFcst] = midasPointForecast(y0,restrictions,model,options,~,nSteps,iter,actual,inputs)
% Syntax:
%
% [Y,evalFcst] = nb_forecast.midasPointForecast(y0,restrictions,model,...
%                       options,results,nSteps,index,actual,inputs)
%
% Description:
%
% Produce point forecast of MIDAS models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get model solution
    [A,B] = nb_forecast.getModelMatrices(model,iter);
    B     = B(all(~isnan(B),2),:);
    
    % Produce forecast
    Y      = nan(1,nSteps+1);
    Y(:,1) = y0;
    X      = restrictions.X(restrictions.index,:)';
    E      = zeros(1,nSteps);
    Y      = nb_computeMidasForecast(A,B,Y,X,E);
    Y      = Y(1,2:end)';
    
    % Get the forecast variable
    dep = nb_forecast.getForecastVariables(options,model,inputs,'pointForecast');
    
    % Create reported variables
    if isfield(inputs,'reporting')  
        if ~isempty(inputs.reporting)
            % Here we need to transform the historical data to the
            % frequency of the dependent variable. Here we remove all data
            % before the options.start_low, which means we must use
            % restrictions.index instead of restrictions.start 
            optLow  = nb_forecast.midasPrepareForReporting(options);
            [Y,dep] = nb_forecast.createReportedVariables(optLow,inputs,Y,dep,restrictions.index,iter);
        end
    end
    
    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        [ind,indV] = ismember(vars,dep);
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = dep(indV);
    end
    
    % Evaluate point forecast 
    evalFcst = nb_forecast.evaluatePointForecast(Y,actual,dep,model,inputs);
        
end
