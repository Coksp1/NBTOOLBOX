function draws = wald_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.wald_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the wald distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the wald distribution
%
% - ncol  : Number of columns of the matrix drawn from the wald 
%           distrubution 
% 
% - m     : The first parameter of the wald distribution. Must be a 1x1 
%           double greater than 0. E[X] = m.
% 
% - k     : The second parameter of the wald distribution. Must be a 1x1 
%           double greater than 0.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the wald 
%           distribution  
%
% See also:
% nb_distribution.wald_pdf, nb_distribution.wald_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to wald_rand']);
    end

    % See https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution
    v      = randn(nrow,ncol);
    y      = v.^2;
    x      = m + (m^2.*y)./(2*k) - m/(2*k).*sqrt(4*m*k.*y + m^2.*y.^2);
    z      = rand(nrow,ncol);
    q      = m./(m + x);
    x(z>q) = m^2./x(z>q);
    draws  = x;
    
end
    

