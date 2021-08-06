function residual = getResidual(obj)
% Syntax:
%
% residual = getResidual(obj)
%
% Description:
%
% Get residual from a estimated nb_model_recursive_detrending object
% 
% Input:
% 
% - obj : An object of class nb_model_recursive_detrending
% 
% Output:
% 
% - residual : Either a nb_ts object with residual(s) stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a scalar nb_model_generic as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        
        if isa(obj,'nb_dsge')
            data     = getFiltered(obj,'smoothed',true);
            residual = window(data,'','',obj.solution.res);
        else
            func     = str2func([obj.estOptions(end).estimator '.getResidual']);
            residual = func(obj.results,obj.estOptions(end));
        end
        
    end

end
