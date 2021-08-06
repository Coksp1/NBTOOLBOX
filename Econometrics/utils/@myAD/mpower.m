function x = mpower(x,y)
% Syntax:
%
% x = plus(x,y)
%
% Description:
%
% Redirect to power (.^) if x is a scalar.
% 
% In Package myAD - Automatic Differentiation
% by Martin Fink, June 2006
% martinfink 'at' gmx.at

    if numel(x)==1
        x=x.^y;
    else
        error('Matrix power is not implemented. If elementwise exponentiation was intended use .^ ');
    end
    
end
