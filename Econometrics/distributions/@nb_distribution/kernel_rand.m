function draws = kernel_rand(nrow,ncol,domain,density)
% Syntax:
%
% draws = nb_distribution.kernel_rand(nrow,ncol,domain,density)
%
% Description:
%
% Draw random numbers from an estimated kernel density.
% 
% Input:
% 
% - nrow    : Number of rows of the matrix drawn from the normal 
%             distribution
%
% - ncol    : Number of columns of the matrix drawn from the normal 
%             distrubution 
% 
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - draws : A nrow x ncol matrix of random numbers from the estimated  
%           kernel density  
%
% See also:
% nb_distribution.kernel_pdf, nb_distribution.kernel_cdf
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin ~= 4
        error([mfilename ':: Wrong # of arguments to kernel_rand']);
    end

    nDraws     = nrow*ncol;
    randDraws  = rand(nDraws,1);
    binsLength = domain(2) - domain(1); 
    densCdf    = cumsum(density)*binsLength;
    draws      = nan(nDraws,1);
    for ii = 1:nDraws
        diffWithCdf = (densCdf - randDraws(ii)).^2;
        [~, index]  = min(diffWithCdf);   
        draws(ii)   = domain(index);
    end
    draws = reshape(draws,[nrow,ncol]);
                
end
    

