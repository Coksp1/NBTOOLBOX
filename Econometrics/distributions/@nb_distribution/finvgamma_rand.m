function draws = finvgamma_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.finvgamma_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the flipped invgamma distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the invgamma distribution
%
% - ncol  : Number of columns of the matrix drawn from the invgamma 
%           distrubution 
% 
% - m     : The shape parameter, as a double >0.
% 
% - k     : The scale parameter, as a double >0.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the flipped  
%           invgamma distribution  
%
% See also:
% nb_distribution.finvgamma_pdf, nb_distribution.finvgamma_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if m <= 0
       error([mfilename ':: Parameter m is wrong'])
    end
    
    if k <= 0
       error([mfilename ':: Parameter k is wrong'])
    end
      
    draws = gamrnd(m,1/k,nrow,ncol);
    draws = -1./draws;
%     draws = reshape(draws,[nrow,ncol]);
    
end
    

