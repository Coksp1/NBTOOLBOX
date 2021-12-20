function draws = t_rand(nrow,ncol,m,a,b)
% Syntax:
%
% draws = nb_distribution.t_rand(nrow,ncol,m)
% draws = nb_distribution.t_rand(nrow,ncol,m,a,b)
%
% Description:
%
% Draw random numbers from the student-t distribution
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the student-t 
%           distribution
%
% - ncol  : Number of columns of the matrix drawn from the student-t 
%           distrubution 
% 
% - m     : The number of degrees of freedom. Must be positive.
%
% - a     : The location parameter. Optional. Default is 0.
%
% - b     : The scale parameter. Must be > 0. Optional. Default is 1.
% 
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the student-t 
%           distribution  
%
% See also:
% nb_distribution.t_pdf, nb_distribution.t_cdf
%
% Written by Kenneth S. Paulsen
      
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        b = 1;
        if nargin < 4
            a = 0;
        end
    end

    n     = nrow*ncol;
    z     = randn(n,1);
    x     = nb_distribution.chis_rand(n,1,m);
    draws = (z*sqrt(m))./sqrt(x);
    draws = reshape(draws,[nrow,ncol]);
    draws = a + b.*draws;
    
end
    

