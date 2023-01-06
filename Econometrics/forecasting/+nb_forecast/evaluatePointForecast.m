function evalFcst = evaluatePointForecast(Y,actual,dep,model,inputs)
% Syntax:
%
% evalFcst = nb_forecast.evaluatePointForecast(Y,actual,dep,model,inputs)
%
% Description:
%
% Evaluate point forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Evaluate point forecast
    evalFcst = struct();
    fcstEval = inputs.fcstEval;
    if ~isempty(fcstEval)
        
        % Keep only the varOfInterest if it is given
        Y = nb_forecast.getEvaluatedVariables(Y,dep,model,inputs);
        for ii = 1:length(fcstEval)

            % Calculate forecast evaluation
            fcsEvalValue = nb_evaluateForecast(fcstEval{ii},actual,Y);

            % Assign output
            evalFcst.(upper(fcstEval{ii})) = fcsEvalValue;

        end

    end
    
end
