function dependentNames = getDependentNames(obj)
% Syntax:
%
% dependentNames = getDependentNames(obj)
%
% Description:
%
% Get all the unique dependent variables names of a vector of 
% nb_model_convert objects
% 
% Input:
% 
% - obj           : A vector of nb_model_convert objects
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
        dependentNames{ii} = getDependentNames(obj(ii).model); 
    end
    dependentNames = unique(nb_nestedCell2Cell(dependentNames));

end
