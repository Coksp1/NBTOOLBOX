function obj = checkReporting(obj)
% Syntax:
%
% obj = checkReporting(obj)
%
% Description:
%
% Check reporting, and store historical observation of reported variables.
% 
% Input:
% 
% - obj : A NxM nb_modelData object with the reporting property set.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_model_vintages')
        error([mfilename ':: Cannot call this method on a nb_model_vintages object. This is done '...
                         'automatically inside the estimate method in this case.'])
    end

    if isempty(obj(1).reporting)
        return;
    end
    
    % Check each expressions
    siz        = size(obj);
    obj        = obj(:);
    modelNames = getModelNames(obj); 
    for ii = 1:length(obj)
        if isempty(obj.options.data)
            error([mfilename ':: No data assign to the model ' modelNames{ii} ', so cannot check the reporting.'])
        else
            obj(ii) = updateOptionsData(obj(ii));
        end
    end 
    obj = reshape(obj,siz);
        
end
