function z = eq(x,y)
% Syntax:
%
% x = eq(x,y)
%
% Description:
%
% Test for equality of values.
% 
% This only checks if the values are equal. There is no guarantee that the
% derivatives are equal.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if isa(x, 'myAD')
        if isa(y, 'myAD')
            z = (x.values == y.values);
        else
            z = x.values == y;
        end
    else
        z = (x == y.values);
    end

end
