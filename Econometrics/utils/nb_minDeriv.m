function value = nb_minDeriv(expr1,expr2,deriv1,deriv2)
% Syntax:
%
% value = nb_minDeriv(expr1,expr2,deriv1,deriv2)
%
% Description:
%
% Calculate the derivaive of the min(expr1,expr2) function. The derivative 
% is equal to the deriv1 if expr1 < expr2, equal to the deriv2 if expr1 > 
% expr2, 1 when expr2 lim(+)-> expr1 and 0 when expr2 lim(-)-> expr1.
% 
% Input:
% 
% - expr1  : Value of expression 1. A vector with length N or scalar.
%
% - expr2  : Value of expression 2. A vector with length N or scalar.
% 
% - deriv1 : Value of the derivative of expression 1. A vector with length 
%            N or scalar.
%
% - deriv2 : Value of the derivative of expression 1. A vector with length 
%            N or scalar.
%
% Output:
% 
% - value : Value of the derivative after the min function is applied.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    term       = expr1 - expr2;
    condition1 = term < -eps^0.5;
    condition2 = term > eps^0.5;
    if isscalar(deriv1)
        value(condition1) = deriv1;
    else
        value(condition1) = deriv1(condition1);
    end
    if isscalar(deriv2)
        value(condition2) = deriv2;
    else
        value(condition2) = deriv2(condition2);
    end
    condition3               = not(condition1 | condition2);
    termAtKink               = term(condition3);
    condition4               = termAtKink <= 0;
    valueAtKink              = zeros(size(termAtKink));
    valueAtKink(condition4)  = 1; % Derivative lim+ equal 1, while derivative lim- equal 0 
    value(condition3)        = valueAtKink;
    
end
