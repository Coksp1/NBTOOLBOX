function X = getData(options,variables,description)
% Syntax:
%
% X = nb_manualEstimator.getData(options,variables,optionName)
%
% Description:
%
% Helper function to get data on a set of variables.
% 
% Input:
% 
% - options     : A struct, see nb_manualEstimator.estimate.
%
% - variables   : A 1 x nVar cellstr with the names of the variables to
%                 fetch.
% 
% - description : A one line char with the description of the variables.
%                 Used in error messages. Default is ''.
%
% Output:
% 
% - X : A T x nVar double. The ordering of the variables is perserved.
%
% See also:
% nb_manualEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [testX,indX] = ismember(variables,options.dataVariables);
    if any(~testX)
        description = [description, ' '];
        if length(variables) == 1
            error(['The ' description 'variable is not found to be in the dataset; ',...
                toString(variables(~testX))])
        else
            error(['Some of the ' description 'variables are not found to be in the dataset; ',...
                toString(variables(~testX))])
        end
    end
    X = options.data(:,indX);
    
end
