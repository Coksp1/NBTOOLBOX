function residual = getPredicted(obj)
% Syntax:
%
% residual = getPredicted(obj)
%
% Description:
%
% Get predicted variables from a estimated nb_model_recursive_detrending
% object
% 
% Caution: Only returned for the last period of the recursive estimation.
%
% Input:
% 
% - obj : An object of class nb_model_recursive_detrending
% 
% Output:
% 
% - residual : Either a nb_ts or a nb_cs object with predicted variable(s) 
%              stored.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_model_recursive_detrending as input'])
    else
        if isempty(obj.modelIter)
            error([mfilename ':: You must first call the createVariables method on the object.'])
        end
        if isa(obj.modelIter(end),'nb_dsge')
            error([mfilename ':: This method is not supported when the model property is of class nb_dsge. See getFiltered instead.'])
        else
            if nb_isempty(obj.modelIter(end).results)
                error([mfilename ':: The model is not estimated'])
            end
            func     = str2func([obj.modelIter(end).estOptions(end).estimator '.getPredicted']);
            residual = func(obj.modelIter(end).results,obj.modelIter(end).estOptions(end));
        end
    end

end
