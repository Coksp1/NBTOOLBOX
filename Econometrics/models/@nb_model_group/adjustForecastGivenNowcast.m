function [forecastOutput,startFcstObj] = adjustForecastGivenNowcast(nowcast,forecastOutput,startFcstObj,allVars,names)
% Syntax:
%
% [forecastOutput,startFcstObj] = ...
% nb_model_group.adjustForecastGivenNowcast(nowcast,forecastOutput,...
%           startFcstObj,allVars,names)
%
% Description:
%
% Private static method used in combineForecast and aggregateForecast
% methods of the nb_model_group class.
% 
% See also:
% nb_model_group.combineForecast, nb_model_group.aggregateForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

% Remember: Here I only allow for combination of one variable! This means
%           I don't care about the rest of the variable are dated 
%           wrongly!
%
% Caution : Density forecast are being dealt with later!

    nobj = length(forecastOutput);
    for ii = 1:nobj
        
        % Must be part of dependent
        indV = strcmpi(allVars{1},forecastOutput{ii}.dependent);
        if ~any(indV)
            error([mfilename ':: The variable provided by the ''varOfInterest'' input must be part of the dependent variables of model with name ' names{ii}])
        end
        
        if isfield(forecastOutput{ii},'nowcast')
            forecastOutput{ii}.nowcast = 0; 
        end
        
        % For models that include nowcast we must redate the start
        % dates of the forecast
        if nowcast(ii) > 0
            
            missing = sum(forecastOutput{ii}.missing(:,indV),1);
            if missing > 0
            
                sInd   = nowcast(ii) - missing;
                nSteps = forecastOutput{ii}.nSteps;
                start  = forecastOutput{ii}.start;

                % Remove last forecasts so to keep the horizon align with
                % nSteps
                forecastOutput{ii}.data  = forecastOutput{ii}.data(sInd+1:sInd+nSteps,:,:,:);

                % Lag all start forecast periods
                added = cell(1,missing);
                ll    = missing;
                for mm = 1:missing
                    added{ll} = nb_dateplus(start{1},-mm);
                    ll        = ll - 1;
                end
                start = [added, start(1:end-missing)];

                % Store
                forecastOutput{ii}.start = start;
                startFcstObj{ii}         = start;
                if ~isempty(forecastOutput{ii}.evaluation) && sInd > 0
                    forecastOutput{ii} = correctEvaluation(forecastOutput{ii},sInd);
                end
                
            else
                
                % Remove nowcast, which is actually history for the
                % selected variable!
                forecastOutput{ii}.data = forecastOutput{ii}.data(forecastOutput{ii}.nowcast+1:end,:,:,:);  
                if ~isempty(forecastOutput{ii}.evaluation)
                    forecastOutput{ii} = correctEvaluation(forecastOutput{ii},forecastOutput{ii}.nowcast);
                end
                
            end
            
        end
        
    end
    
end

function forecastOutput = correctEvaluation(forecastOutput,per)

    fields = fieldnames(forecastOutput.evaluation(1));
    fields = setdiff(fields,{'int','density','type'});
    num    = size(fields,1);
    for ii = 1:size(forecastOutput.evaluation,2)
        for jj = 1:num
            forecastOutput.evaluation(ii).(fields{jj}) = ...
                forecastOutput.evaluation(ii).(fields{jj})(per+1:end,:);
        end
    end

end
