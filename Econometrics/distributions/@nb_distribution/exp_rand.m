function draws = exp_rand(nrow,ncol,m)
% Syntax:
%
% draws = nb_distribution.exp_rand(nrow,ncol,m)
%
% Description:
%
% Draw random numbers from the exponential distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the exponential 
%           distribution
%
% - ncol  : Number of columns of the matrix drawn from the exponential 
%           distrubution 
% 
% - m : The rate parameter of the distribution. Must be positive 1x1 
%       double.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the exponential 
%           distribution  
%
% See also:
% nb_distribution.exp_pdf, nb_distribution.exp_cdf
%
% Modified by Kenneth S. Paulsen
      
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    p     = rand(nrow,ncol);
    draws = -(1/m).*log(p./m);

end
    

