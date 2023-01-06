function R = gelmanRubin(varargin)
% Syntax:
%
% R = nb_mcmc.gelmanRubin(varargin)
%
% Description:
%
% Calculates the Gelman-Rubin diagnostic of multiple M-H chains.
% 
% Input:
% 
% - varargin : Each input must be 2*n x q double with the M-H draws of 
%              a set of q variables/parameters and length 2*n. The
%              test discard the first n draws.
% 
% Output:
% 
% - R        : A 1 x q test statistics. If any element is >> 1 run the
%              M-H for a longer period, as it has not converged to the
%              stationary distribution.
%
% See also:
% nb_mcmc.mhSampler
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    m = nargin;
    if m < 2
        error([mfilename ':: You must at least provide the results of 2 independent M-H chains to do this test!'])
    end
    [n2,q] = size(varargin{1});
    n      = n2/2;
    mBeta  = nan(m,q);
    vBeta  = nan(m,q);
    for ii = 1:m
        % Discard the first n draws
        mBeta(ii,:) = mean(varargin{ii}(end-n+1:end,:));
        vBeta(ii,:) = var(varargin{ii}(end-n+1:end,:));
    end
    W = mean(vBeta,1);
    B = n.*var(mBeta,1);
    R = sqrt( ((1 - 1/n).*W + B./n)./W );
    
end
