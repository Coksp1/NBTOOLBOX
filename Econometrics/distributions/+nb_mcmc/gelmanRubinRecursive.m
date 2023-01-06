function R = gelmanRubinRecursive(varargin)
% Syntax:
%
% R = nb_mcmc.gelmanRubinRecursive(varargin)
%
% Description:
%
% Calculates the recursive Gelman-Rubin diagnostic of multiple M-H chains.
% 
% Input:
% 
% - varargin : Each input must be 2*n x q double with the M-H draws of 
%              a set of q variables/parameters and length 2*n. The
%              test discard the first n draws.
% 
% Output:
% 
% - R        : A n x q test statistics. If any element is >> 1 run the
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
    mBeta  = nan(n,q,m);
    vBeta  = nan(n,q,m);
    for ii = 1:m
        for nn = 1:n
            % Discard the first n draws
            ind            = n+1:n+nn;
            mBeta(nn,:,ii) = mean(varargin{ii}(ind,:));
            vBeta(nn,:,ii) = var(varargin{ii}(ind,:));
        end
    end
    N = 1:n;
    N = N';
    N = N(:,ones(1,q));
    W = mean(vBeta,3);
    B = N.*var(mBeta,0,3);
    R = sqrt( ((1 - 1./N).*W + B./N)./W );
    
end
