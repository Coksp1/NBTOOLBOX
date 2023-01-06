function estimated = checkCalibration(options,parser)
% Syntax:
%
% estimated = nb_statespaceEstimator.checkCalibration(options,parser)
%
% Description:
%
% Check if all parameters has some values before we start the estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(options.prior)
        estimated = {};
        return
    end

    estimated  = options.prior(:,1);
    param      = options.calibration(parser.parametersInUse);
    hasNoValue = isnan(param);
    if any(hasNoValue)
       
        % Identify the parameters solved for in the steady-state
        if ~isempty(options.steady_state_file)
            if ischar(options.steady_state_file)
                ssFile = str2func(options.steady_state_file);
            else
                ssFile = options.steady_state_file;
            end
            paramS          = cell2struct(num2cell(options.calibration),parser.parameters);
            [~,solvedParam] = ssFile(parser,paramS);
            if ~nb_isempty(solvedParam)
                paramSol        = fieldnames(solvedParam);
                ind             = ismember(parser.parameters(parser.parametersInUse),paramSol);
                hasNoValue(ind) = false;
            end
        end
        
        if any(hasNoValue)
        
            % Then some parameters has not been assign and we need to 
            % provide an error
            paramNames             = parser.parameters(parser.parametersInUse);
            paramNamesWithoutValue = paramNames(hasNoValue);
            paramInd               = ismember(paramNamesWithoutValue,estimated);
            paramError             = paramNamesWithoutValue(~paramInd);
            if ~isempty(paramError)
                error([mfilename ':: Some parameters of the model are not calibrated and not assign a prior either; '...
                       toString(paramError)])
            end
            
        end
        
    end
    
end
