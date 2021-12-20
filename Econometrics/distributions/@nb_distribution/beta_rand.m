function draws = beta_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.beta_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the beta distribution
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the beta distribution
%
% - ncol  : Number of columns of the matrix drawn from the beta 
%           distrubution 
% 
% - m     : First shape parameter of the beta distribution. The mean will
%           be given by m/(m + k)
%      
% - k     : Second shape parameter of the beta distribution
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the beta 
%           distribution  
%
% See also:
% nb_distribution.beta_pdf, nb_distribution.beta_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong number of arguments nb_distribution.to beta_rand']);
    end

    d1    = nb_distribution.gamma_rand(nrow,ncol,m,1); 
    d2    = nb_distribution.gamma_rand(nrow,ncol,k,1); 
    draws = d1./(d1 + d2);  
    draws = reshape(draws,nrow,ncol);
    
end
