function vars = getInputVars(obj)
% Syntax:
%
% vars = getInputVars(obj)
%
% Description:
%
% Get all input variables to the model.
%
% Input:
% 
% - obj  : A scalar nb_calculate_vintages object.
% 
% Output:
% 
% - vars : A cellstr array with the input variables of the model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    vars = obj.options.dataSource.variables;

end
