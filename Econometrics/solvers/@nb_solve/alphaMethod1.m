function alpha = alphaMethod1(s,y)
% Syntax:
%
% alpha = nb_solve.alphaMethod1(s,y)
%
% Description:
%
% Implements the spectral step length in equation 3 of Varadhan and 
% Gilbert (2009).
%
% alpha(k) = s(k-1)'*s(k-1)/( s(k-1)'*y(k-1) )
% 
% See also:
% nb_solve.alphaMethod2, nb_solve.alphaMethod3
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    alpha = s'*s/(s'*y);

end
