function obj = not(obj)
% Syntax:
%
% obj = not(obj)
%
% Description:
%
% The ~ operator for nb_macro objects. This allows for;
% > logical = ~numeric
% > logical = ~logical
%
% Caution : The above type is refer to as the type property of the 
%           nb_macro variable.
%
% Caution : This operator is also supported for if one nb_macro object
%           represent one of the above type but the other input is of the
%           MATLAB basic type. E.g. ~nb_macro('a',2) will result
%            in a nb_macro object representing the logical false.
%
% Caution : This operator supports nb_macro object, numeric and logical
%           matrices, as long as one is a scalar or their sizes matches.
%
% Input:
% 
% - obj1 : An object of any class.
%
% - obj2 : An object of any class.
% 
% Output:
% 
% - obj  : An object of class nb_macro.
%
% See also:
% ne, lt, le, gt, ge, eq
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check if we are going to loop the operator
    [looped,obj] = loopOperator1(obj,@not);
    if looped 
        return
    end

    % Get info from the inputs.
    value1 = obj.value;
    name1  = obj.name;

    % Do the calculations
    op = '~';
    if isnumeric(value1) || islogical(value1)
        val = ~value1;
    else
        error(nb_macro.getError1(value1,op));
    end
    
    % Assign value
    obj.value = val;

    % Update the name
    obj.name  = [op,name1];
    
end
