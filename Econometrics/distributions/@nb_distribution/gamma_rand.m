function draws = gamma_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.gamma_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the Gamma distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the gamma distribution
%
% - ncol  : Number of columns of the matrix drawn from the gamma 
%           distrubution 
% 
% - m     : A parameter such that the mean of the gamma = m*k
%      
% - k     : A parameter such that the variance of the gamma = m*(k^2)
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the gamma 
%           distribution  
%
% See also:
% nb_distribution.gamma_pdf, nb_distribution.gamma_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    if k <= 0
       error([mfilename ':: Parameter k is wrong'])
    end
      
    draws = gamrnd(m,k,nrow,ncol);
%     draws = reshape(draws,[nrow,ncol]);
    
end
    

