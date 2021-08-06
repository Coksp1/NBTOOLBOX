function draws = ast_rand(nrow,ncol,a,b,c,d,e)
% Syntax:
%
% draws = nb_distribution.ast_rand(nrow,ncol,a,b,c,d,e)
%
% Description:
%
% Draw random numbers from the asymmetric t-distribution of Zhu and 
% Galbraith (2009).
%
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the distribution
%
% - ncol  : Number of columns of the matrix drawn from the distrubution 
% 
% - a     : The location parameter.
% 
% - b     : The scale parameter (>0).
%
% - c     : The skewness parameter (1>c>0).
%
% - d     : The left parameter (>0). 
%
% - e     : The right parameter (>0).
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the distribution  
%
% See also:
% nb_distribution.ast_pdf, nb_distribution.ast_cdf
%
% Modified by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 1
        draws  = nb_distribution.t_rand(nrow,ncol,d);
    elseif cstar == 0
        draws  = nb_distribution.t_rand(nrow,ncol,e);
    else
        U      = rand(nrow,ncol);
        Td     = nb_distribution.t_rand(nrow,ncol,d);
        Te     = nb_distribution.t_rand(nrow,ncol,e);
        signUc = sign(U - c); 
        draws  = cstar.*abs(Td).*(signUc - 1) + (1 - cstar).*abs(Te).*(signUc + 1);
    end
    draws  = draws.*b + a; % Scale and locate
    
end
    

