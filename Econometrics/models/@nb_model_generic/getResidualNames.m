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
% - obj           : A vector of nb_model_generic objects
% 
% Output:
% 
% - residualNames : A cellstr with the unique residual names of all the
%                   models
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj           = obj(:);
    sol           = {obj.solution};
    nobj          = size(obj,1);
    residualNames = cell(1,nobj);
    for ii = 1:nobj
        try
            residualNames{ii} = sol{ii}.res;
        catch %#ok<CTCH>
            error([mfilename ':: The model (' int2str(ii) ') is not solved'])
        end
    end
    residualNames = unique(nb_nestedCell2Cell(residualNames));

end
