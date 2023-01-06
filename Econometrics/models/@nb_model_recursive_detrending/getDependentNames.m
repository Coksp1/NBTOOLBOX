function dependentNames = getDependentNames(obj)
% Syntax:
%
% dependentNames = getDependentNames(obj)
%
% Description:
%
% Get all the unique dependent variables names of a vector of 
% nb_model_recursive_detrending objects
% 
% Input:
% 
% - obj           : A vector of nb_model_recursive_detrending objects
% 
% Output:
% 
% - dependentNames : A cellstr with the unique dependent variables names of 
%                    all the models
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj            = obj(:);
    models         = {obj.model};
    nobj           = size(obj,1);
    dependentNames = cell(1,nobj);
    for ii = 1:nobj
        dependentNames{ii} = models{ii}.dependent.name; 
    end
    dependentNames = unique(nb_nestedCell2Cell(dependentNames));

end
