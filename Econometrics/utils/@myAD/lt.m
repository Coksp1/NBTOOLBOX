function z = lt(x, y)
% Syntax:
%
% x = ge(x,y)
%
% Description:
%
% Less than. Only tests the values not derivatives.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if isa(x, 'myAD')
        if isa(y, 'myAD')
            z = x.values < y.values;
        else
            z = x.values < y;
        end
    else
        z = x < y.values;
    end
    
end
