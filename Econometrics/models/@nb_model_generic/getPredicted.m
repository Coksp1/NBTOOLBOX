function residual = getPredicted(obj)
% Syntax:
%
% residual = getPredicted(obj)
%
% Description:
%
% Get predicted variables from a estimated nb_model_generic object
% 
% Input:
% 
% - obj : An object of class nb_model_generic
% 
% Output:
% 
% - residual : Either a nb_ts or a nb_cs object with predicted variable(s) 
%              stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_model_generic as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        func     = str2func([obj.estOptions(end).estimator '.getPredicted']);
        residual = func(obj.results,obj.estOptions(end));
        
    end

end
