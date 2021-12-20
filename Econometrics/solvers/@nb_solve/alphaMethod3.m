function alpha = alphaMethod3(s,y)
% Syntax:
%
% alpha = nb_solve.alphaMethod3(s,y)
%
% Description:
%
% Implements the spectral step length in equation 5 of Varadhan and 
% Gilbert (2009).
%
% alpha(k) = sgn(s(k-1)'*y(k-1)) * ||s(k-1)||/||y(k-1)||
% 
% where sqn(x) = x/|x|
%
% See also:
% nb_solve.alphaMethod1, nb_solve.alphaMethod2
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    alpha = sgn(s'*y)*norm(s,2)/norm(y,2);

end
function y = sgn(x)
    y = x/abs(x);
end
