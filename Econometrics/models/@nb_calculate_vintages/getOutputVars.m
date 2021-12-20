function vars = getOutputVars(obj)
% Syntax:
%
% vars = getOutputVars(obj)
%
% Description:
%
% Get all output variables from the model. I.e. the variables that are 
% forecasted by the model. See the 'varOfInterest' option.
%
% Input:
% 
% - obj  : A scalar nb_calculate_vintages object.
% 
% Output:
% 
% - vars : A cellstr array with the output variables of the model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(obj.model)
        vars = {};
        return
    end
    vars = obj.options.varOfInterest;

end
