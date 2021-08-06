function residualNames = getResidualNames(obj)
% Syntax:
%
% residualNames = getResidualNames(obj)
%
% Description:
%
% Get all the unique residual names of a vector of nb_model_group object 
% 
% Input:
% 
% - obj           : A vector of nb_model_group objects
% 
% Output:
% 
% - residualNames : A cellstr with the unique residual names of all the
%                   models
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj           = obj(:);
    nobj          = size(obj,1);
    residualNames = cell(1,nobj);
    for ii = 1:nobj 
        models             = obj(ii).models;
        indMGroup          = cellfun(@(x)isa(x,'nb_model_group'),models);
        modelGroups        = models(indMGroup);
        modelsGeneric      = models(~indMGroup);
        res1               = getResidualNames([modelGroups{:}]);
        res2               = getResidualNames([modelsGeneric{:}]);
        residualNames{ii}  = [res1,res2]; 
    end
    residualNames = unique(nb_nestedCell2Cell(residualNames));

end
