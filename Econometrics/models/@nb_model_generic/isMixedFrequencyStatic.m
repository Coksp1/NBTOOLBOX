function ret = isMixedFrequencyStatic(options)
% Syntax:
% 
% ret = nb_model_generic.isMixedFrequencyStatic(options)
%
% Description:
%
% Does the model support mixed frequency?
% 
% Input:
% 
% - options : The estOptions property of the nb_model_generic object.
%             The object must be estimated!
% 
% Output:
% 
% - ret : True or false.
%
% See also:
% nb_forecast.createReportedVariables
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(options.class,'nb_mfvar')
        ret = true;
    elseif strcmpi(options.class,'nb_fmdyn')
        if any(cellfun(@(x)not(isempty(x)),options.frequency))
            ret = true;
        else
            ret = false;
        end
    else
        ret = false;
    end

end
