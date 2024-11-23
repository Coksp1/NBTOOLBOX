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
           
        tempOpt = obj.options;
        if ~any(strcmpi(tempOpt.estim_method,{'synthesizer'}))
            error([mfilename ':: The estimation method ' estim_method ' is not supported.'])
        end
        
        % Get estimation options
        tempOpt.name = obj.name; 

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.class        = class(obj);
        outOpt               = {tempOpt};
        
    end
    
end
