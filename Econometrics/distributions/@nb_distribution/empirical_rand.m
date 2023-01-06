function draws = empirical_rand(nrow,ncol,domain,CDF)
% Syntax:
%
% draws = nb_distribution.empirical_rand(nrow,ncol,domain,CDF)
%
% Description:
%
% Draw random numbers from an estimated empirical density.
% 
% Input:
% 
% - nrow    : Number of rows of the matrix drawn from the normal 
%             distribution.
%
% - ncol    : Number of columns of the matrix drawn from the normal 
%             distrubution.
% 
% - domain  : The domain of the distribution.
% 
% - CDF     : The empirical CDF.
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the estimated  
%           empirical density.  
%
% See also:
% nb_distribution.empirical_pdf, nb_distribution.empirical_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to kernel_rand']);
    end

    nDraws    = nrow*ncol;
    randDraws = rand(nDraws,1);
    draws     = nan(nDraws,1);
    for ii = 1:nDraws
        diffWithCdf = (CDF - randDraws(ii)).^2;
        [~, index]  = min(diffWithCdf);   
        draws(ii)   = domain(index);
    end
    draws = reshape(draws,[nrow,ncol]);
                
end
    

