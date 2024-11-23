function dependentNames = getDependentNames(obj)
% Syntax:
%
% dependentNames = getDependentNames(obj)
%
% Description:
%
% Get all the unique dependent variables names of a vector of 
% nb_model_group objects
% 
% Input:
% 
% - obj           : A vector of nb_model_group objects
% 
% Output:
% 
% - dependentNames : A cellstr with the unique dependent variables names of 
%                    all the models
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj            = obj(:);
    nobj           = size(obj,1);
    dependentNames = cell(1,nobj);
    for ii = 1:nobj
        
        models             = obj(ii).models;
        indMGroup          = cellfun(@(x)isa(x,'nb_model_group'),models);
        modelGroups        = models(indMGroup);
        modelsGeneric      = models(~indMGroup);
        dep1               = getDependentNames([modelGroups{:}]);
        dep2               = getDependentNames([modelsGeneric{:}]);
        dependentNames{ii} = [dep1,dep2]; 
        
    end
    dependentNames = unique(nb_nestedCell2Cell(dependentNames));

end
