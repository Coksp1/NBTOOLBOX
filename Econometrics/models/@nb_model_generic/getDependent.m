function dependent = getDependent(obj)
% Syntax:
%
% dependent = getDependent(obj)
%
% Description:
%
% Get dependent variables from a estimated nb_model_generic object
% 
% Input:
% 
% - obj       : An object of class nb_model_generic
% 
% Output:
% 
% - dependent : Either a nb_ts or a nb_cs object with dependent variable(s) 
%               stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_model_generic as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        func      = str2func([obj.estOptions(end).estimator '.getDependent']);
        dependent = func(obj.results,obj.estOptions(end));
        
    end

end
