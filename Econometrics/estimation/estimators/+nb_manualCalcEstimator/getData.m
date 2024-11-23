function out = getData(options,variables,description)
% Syntax:
%
% X = nb_manualCalcEstimator.getData(options,variables,optionName)
%
% Description:
%
% Helper function to get data on a set of variables.
% 
% Input:
% 
% - options     : A struct, see nb_manualCalcEstimator.estimate.
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
% nb_manualCalcEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen and Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    out = nb_manualEstimator.getData(options,variables,description);

end
