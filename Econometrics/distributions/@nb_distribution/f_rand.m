function draws = f_rand(nrow,ncol,m,k)
% Syntax:
%
% draws = nb_distribution.f_rand(nrow,ncol,m,k)
%
% Description:
%
% Draw random numbers from the F(m,k) distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the F(m,k) distribution
%
% - ncol  : Number of columns of the matrix drawn from the F(m,k) 
%           distrubution 
% 
% - m     : First parameter of the distribution. Must be positive
%      
% - k     : Second parameter of the distribution. A parameter such that the 
%           mean of the F-distribution is equal to k/(k-2) for k > 2. Must 
%           be positive.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the F(m,k) 
%           distribution  
%
% See also:
% nb_distribution.f_pdf, nb_distribution.f_cdf
%
% Modified by Kenneth S. Paulsen
      
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    draws = nb_distribution.beta_rand(nrow,ncol,m/2,k/2);
    draws = draws.*k./((1-draws).*m);

end
    

