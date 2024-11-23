function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen       

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set up the estimators
    %------------------------------------------------------
    obj  = obj(:);
    nobj = size(obj,1);
    if nobj > 1 
        outOpt = cell(1,nobj);
        for ii = 1:nobj
            outOpt(ii) = getEstimationOptions(obj(ii));
        end
    elseif nobj == 1
        outOpt         = getEstimationOptions(obj.model);
        outOpt.convert = true; % Indicate that it is use in nb_model_convert
    end
    
end
