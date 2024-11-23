function f = nb_tAbsMoment(x,r)
% Syntax:
%
% f = nb_tAbsMoment(x,r)
%
% Description:
%
% Absolute moment of the Student-t distribution.
% 
% See Zhu and Galbraith (2009).
%
% Input:
% 
% - x : The number of degrees of freedom.
%
% - r : The absolute moment order to calculate.
% 
% Output:
% 
% - f : The rth order absolute moment
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f1 = sqrt((x.^r)./pi).*gamma(r/2 + 0.5).*gamma((x - r)./2);
    f2 = gamma(x./2);
    f  = f1./f2;
    
end
