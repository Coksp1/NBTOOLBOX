function obj = power(obj1,obj2)
% Syntax:
%
% obj = power(obj1,obj2)
%
% Description:
%
% The * operator for nb_macro objects. This allows for;
% > numeric = numeric .^ numeric
% > numeric = logical .^ logical
% > numeric = logical .^ numeric
%
% Caution : The above type is refer to as the type property of the 
%           nb_macro variable.
%
% Caution : This operator is also supported for if one nb_macro object
%           represent one of the above type but the other input is of the
%           MATLAB basic type. E.g. nb_macro('a',2) .^ 4 will
%           result in a nb_macro object representing the double 16.
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
% plus, minus, times, rdivide
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check if we are going to loop the operator
    [looped,obj] = loopOperator(obj1,obj2,@power);
    if looped 
        return
    end

    % Get info from the inputs.
    [obj,name1,name2,value1,value2] = getInfo(obj1,obj2);

    % Do the calculations
    op = '.^';
    if isnumeric(value1)
        
        if isnumeric(value2) || islogical(value2)
            val = value1 ^ value2;
        else
            error(nb_macro.getError(value1,value2,op));
        end
        
    elseif islogical(value1)
        
        if isnumeric(value2) || islogical(value2)
            val = value1 ^ value2;
        else
            error(nb_macro.getError(value1,value2,op));
        end
        
    else
        error(nb_macro.getError(value1,value2,op));
    end
    
    % Assign value
    obj.value = val;

    % Update the name
    obj.name  = [name1,op,name2];
    
end
