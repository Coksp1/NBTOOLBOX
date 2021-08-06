function observables = getObservables(obj)
% Syntax:
%
% observables = getObservables(obj)
%
% Description:
%
% Get observables from a estimated nb_factor_model_generic object
% 
% Input:
% 
% - obj         : An object of class nb_factor_model_generic
% 
% Output:
% 
% - observables : A nb_ts object with observables of the factor model 
%                 stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_factor_model_generic as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        func        = str2func([obj.estOptions.estimator '.getObservables']);
        observables = func(obj.results,obj.estOptions);
        
    end

end
