function value = nb_conditionalStatement(condition, trueFunc, falseFunc)
% Syntax:
%
% value = nb_conditional(condition, trueFunc, falseFunc)
%
% Description:
%
% If condition is true return output from trueFunc, or else return output 
% from falseFunc.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if condition
        value = trueFunc();
    else
        value = falseFunc();
    end
    
end
