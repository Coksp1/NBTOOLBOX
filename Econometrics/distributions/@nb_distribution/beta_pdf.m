function f = beta_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.beta_pdf(x,m,k)
%
% Description:
%
% PDF of the beta distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : First shape parameter of the beta distribution. The mean will
%       be given by m/(m + k)
% 
% - k : Second shape parameter of the beta distribution
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.beta_cdf, nb_distribution.beta_rand, 
% nb_distribution.beta_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f      = (x.^(m-1)).*((1-x).^(k-1));
    div    = beta(m,k);
    f      = f./div;
    f(x<0) = zeros;
    f(x>1) = zeros; 
    
end
