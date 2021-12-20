function residualNames = getResidualNames(obj)
% Syntax:
%
% residualNames = getResidualNames(obj)
%
% Description:
%
% Get all the unique residual names of a vector of nb_model_generic object 
% 
% Input:
% 
% - obj           : A vector of nb_model_recursive_detrending objects.
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
        modelT            = solve(obj.modelInit(1));
        sol               = modelT.solution;
        residualNames{ii} = sol.res;
    end
    residualNames = unique(nb_nestedCell2Cell(residualNames));

end
