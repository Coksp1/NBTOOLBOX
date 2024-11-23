function factors = getFactors(obj)
% Syntax:
%
% factors = getFactors(obj)
%
% Description:
%
% Get factors from a estimated nb_factor_model_generic object
% 
% Input:
% 
% - obj     : An object of class nb_factor_model_generic
% 
% Output:
% 
% - factors : A nb_ts object with the estimated factors of the model 
%             stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_factor_model_generic object as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        func    = str2func([obj.estOptions.estimator '.getFactors']);
        factors = func(obj.results,obj.estOptions);
        if isa(obj,'nb_fmdyn')
           factors = renameMore(factors,'variable',factors.variables,obj.factors.name);
        end
        
    end

end
