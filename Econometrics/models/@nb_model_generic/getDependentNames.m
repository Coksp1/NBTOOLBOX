function dependentNames = getDependentNames(obj)
% Syntax:
%
% dependentNames = getDependentNames(obj)
%
% Description:
%
% Get all the unique dependent variables names of a vector of 
% nb_model_generic objects
% 
% Input:
% 
% - obj           : A vector of nb_model_generic objects
% 
% Output:
% 
% - dependentNames : A cellstr with the unique dependent variables names of 
%                    all the models
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj            = obj(:);
    dependent      = {obj.dependent};
    nobj           = size(obj,1);
    dependentNames = cell(1,nobj);
    for ii = 1:nobj
        dependentNames{ii} = dependent{ii}.name; 
    end
    dependentNames = unique(nb_nestedCell2Cell(dependentNames));

end
