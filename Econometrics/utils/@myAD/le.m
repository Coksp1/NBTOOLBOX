function z = le(x, y)
% Syntax:
%
% x = le(x,y)
%
% Description:
%
% Less than or equal. Only tests the values not derivatives.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if isa(x, 'myAD')
        if isa(y, 'myAD')
            z = x.values <= y.values;
        else
            z = x.values <= y;
        end
    else
        z = x <= y.values;
    end
    
end
