function draws = fgamma_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.fgamma_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the flipped gamma distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the gamma distribution
%
% - ncol  : Number of columns of the matrix drawn from the gamma 
%           distrubution 
% 
% - m     : A parameter such that the mean of the flipped gamma = -m*k
% 
% - k     : A parameter such that the variance of the flipped 
%           gamma = m*(k^2)
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the flipped gamma 
%           distribution  
%
% See also:
% nb_distribution.fgamma_pdf, nb_distribution.fgamma_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    if k <= 0
       error([mfilename ':: Parameter k is wrong'])
    end
      
    draws = -gamrnd(m,k,nrow,ncol);
%     draws = reshape(draws,[nrow,ncol]);
    
end
    

