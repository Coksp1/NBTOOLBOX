function ret = isMixedFrequency(obj)
% Syntax:
% 
% ret = isMixedFrequency(obj)
%
% Description:
%
% Does the model support mixed frequency?
% 
% Input:
% 
% - obj : An object of class nb_model_generic.
% 
% Output:
% 
% - ret : True or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_model_generic object.'])
    end
    if isa(obj,'nb_mfvar')
        ret = true;
    else
        ret = false;
    end

end
