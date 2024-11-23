function f = f_pdf(x,m,k)
% Syntax:
%
% f = nb_distribution.f_pdf(x,m,k)
%
% Description:
%
% PDF of the F(m,k) distribution
% 
% Input:
% 
% - x : The point to evaluate the pdf, as a double
%
% - m : First parameter of the distribution. Must be positive.
% 
% - k : Second parameter of the distribution. A parameter such that the 
%       mean of the F-distribution is equal to k/(k-2) for k > 2. Must be
%       positive.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.f_cdf, nb_distribution.f_rand, 
% nb_distribution.f_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x(x<0) = 0;
    m_2    = m/2;
    k_2    = k/2;
    m_k    = m/k;
    f      = (1/beta(m_2,k_2))*m_k^m_2;
    f      = f*x.^(m_2 - 1);
    f      = f.*(1 + m_k*x).^(-m_2-k_2);
    f(x<0) = zeros;
     
end
