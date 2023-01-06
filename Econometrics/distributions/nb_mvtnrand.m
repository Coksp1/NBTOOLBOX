function U = nb_mvtnrand(M,P,mu,sigma,l,u,tol)
% Syntax:
%
% U = nb_mvtnrand(M,P,mu,sigma,l,u,tol)
%
% Description:
%
% Draw random variables from the multivariate truncated normal 
% distribution. 
%
% This function is based on the trandn function written by Zdravko Botev.
% Available here "https://se.mathworks.com/matlabcentral/fileexchange/53180
% -truncated-normal-generator?s_tid=prof_contriblnk". Main modifications:
% 
% 1. Generalized to the non-standardized truncated normal distribution
%    using the Geweke, Hajivassiliou and Keane algorithm. 
%    https://en.wikipedia.org/wiki/GHK_algorithm 
% 2. Allow for simulations of multiple draws from the variables of the
%    distribution.
%
% Reference: 
% Botev, Z. I. (2016). "The normal law under linear restrictions: 
% simulation and estimation via minimax tilting". Journal of the 
% Royal Statistical Society: Series B (Statistical Methodology). 
% doi:10.1111/rssb.12162
%
% Input:
% 
% - M     : The number of simulate observation of each variables.
%
% - P     : The number of simulate observation of each variables. (Added
%           as a page)
%
% - mu    : The mean of the variables. As a N x 1 double.
%
% - sigma : The covariance matrix. As a N x N double. Must be symmetric. 
%
% - l     : Lower bound of the truncated distribution. As a N x 1 double.
%           May include -inf.
%
% - u     : Upper bound of the truncated distribution. As a N x 1 double.
%           May include inf.
%
% - tol   : The tolerance when checking for symmetri of sigma.
% 
% Output:
% 
% - U    : A M x N x P matrix.
%
% See also:
% nb_chol, nb_mvnrand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2016, Zdravko I. Botev
% Copyright (c) 2016, Zdravko Botev
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% * Neither the name of University of New South Wales nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7  
        tol = [];
        if nargin < 6
            u = [];
            if nargin < 5
                l = [];
            end
        end
    end
    if isempty(tol)
        tol = eps(max(diag(sigma)))^(3/4);
    end
    mu = mu(:);
    l  = l(:);
    u  = u(:);
    n  = size(mu,1);
    if n == 1
        mu = mu(ones(size(sigma,1),1),1);
        n  = size(mu,1);
    end
    if isempty(l)
        l = -inf(size(mu));
    elseif n ~= size(l,1)
        error([mfilename ':: The lower bound does not have as many elements as mu!'])
    end
    if isempty(u)
        u = inf(size(mu));
    elseif n ~= size(u,1)
        error([mfilename ':: The upper bound does not have as many elements as mu!'])
    end
    if any(l > u)
        error([mfilename ':: The upper bound must be greater than the lower bound!'])
    end
    sigmaT = sigma';
    if any( abs(sigma(:)-sigmaT(:)) > tol)
        error([mfilename ':: The covariance matrix must be symmetric!'])
    end
    U = ghk(M*P,mu,sigma,l,u);
    if P > 1
        U = reshape(U,[size(mu,1),M,P]);
    end
    U = permute(U,[2,1,3]);
    
end

%==========================================================================
function x = ghk(N,mu,sigma,l,u)

    T  = transpose(cholFix(sigma,true));
    if size(T,1) ~= size(T,2)
        % In this case we must use rejection sampling?
        x = rejectionSampling(N,mu',T',l',u')';
        return
    end
    Q  = size(mu,1);
    x  = nan(Q,N);
    l1 = l - mu;
    u1 = u - mu;
    for q = 1:Q
        xq     = T(q,1:q-1)*x(1:q-1,:);
        low    = (l1(q)*ones(1,N) - xq)/T(q,q);
        high   = (u1(q)*ones(1,N) - xq)/T(q,q);
        x(q,:) = mvtsnrand(low',high');
    end
    x = bsxfun(@plus,T*x,mu);

end

%==========================================================================
function x = mvtsnrand(l,u)

    limit     = 0.66; % Def of tail
    minWindow = 2;    % Use reject-accept if window is big enough, and not in the tail
    
    % Preallocation
    x = nan(size(l,1),1);
    
    % Lower tail
    indL = l > limit;
    if any(indL)
        x(indL) = mvtnrandTail(l(indL),u(indL));
    end
    
    % Upper tail
    indU = u < -limit;
    if any(indU)
        x(indU) = -mvtnrandTail(-l(indU),-u(indU));
    end
    
    % Not tail
    indNT = not(indL | indU);
    if any(indNT)
        x(indNT) = mvtnrandCenter(l(indNT),u(indNT),minWindow);
    end
    
end

%==========================================================================
function x = mvtnrandTail(l,u)

    c    = l.^2/2; 
    Q    = size(l,1); 
    f    = expm1(c - u.^2/2);
    x    = c - reallog(1 + rand(Q,1).*f); % sample using Rayleigh
    loc  = find(rand(Q,1).^2.*x > c); 
    left = size(loc,1);
    while left > 0
        cy          = c(loc);                              
        y           = cy - reallog(1 + rand(left,1).*f(loc));
        ind         = rand(left,1).^2.*y < cy;               
        x(loc(ind)) = y(ind);                              
        loc         = loc(~ind); 
        left        = size(loc,1); 
    end
    x = sqrt(2*x); % this Rayleigh transform can be delayed till the end
    
end

%==========================================================================
function x = mvtnrandCenter(l,u,minWindow)

    % Preallocation
    x = nan(size(l,1),1);

    indRA = u - l > minWindow;
    if any(indRA)
       x(indRA) = mvtnrandRA(l(indRA),u(indRA));
    end
    if any(~indRA)
        x(~indRA) = mvtnrandPIT(l(~indRA),u(~indRA));
    end

end

%==========================================================================
function x = mvtnrandRA(l,u)
% Uses rejection sampling

    % Simulate stacked problem
    x   = randn(size(l,1),1);
    loc = find(x < l | x > u); 
    while size(loc,1) > 0 
        ll          = l(loc); 
        ul          = u(loc);
        xi          = randn(size(ll,1),1);
        ind         = xi > ll & xi < ul; 
        x(loc(ind)) = xi(ind); 
        loc         = loc(~ind);
    end

end

%==========================================================================
function x = mvtnrandPIT(l,u)
% Uses probability integral transform 

    nu = rand(size(l,1),1);
    pl = erfc(l/sqrt(2))/2;
    pu = erfc(u/sqrt(2))/2; 
    x  = sqrt(2)*erfcinv(2*(pl - (pl - pu).*nu));

end

%==========================================================================
function x = rejectionSampling(N,mu,T,l,u)

    x   = nb_mvnrandChol(N,1,mu,T);
    loc = find(any(bsxfun(@lt,x,l),2) | any(bsxfun(@gt,x,u),2)); 
    while size(loc,1) > 0 
        xi            = nb_mvnrandChol(size(loc,1),1,mu,T);
        ind           = all(bsxfun(@gt,xi,l),2) & all(bsxfun(@lt,xi,u),2); 
        x(loc(ind),:) = xi(ind,:); 
        loc           = loc(~ind);
    end

end

%==========================================================================
function C = cholFix(A,type)

    [r,c] = size(A);
    if r ~= c
        error([mfilename ':: The A matrix must be square to do cholesky decomposition.'])
    end

    [T,D]     = eig((A+A')/2);
    [~,m]     = max(abs(T),[],1);
    nInd      = T(m + (0:r:(c-1)*r)) < 0;
    T(:,nInd) = -T(:,nInd);
    D         = diag(D);
    tol       = eps(max(D))*length(D);
    t         = abs(D) > tol;
    D         = D(t);
    nNeg      = sum(D < 0);
    if nNeg == 0
        C = diag(sqrt(D))*T(:,t)';
    elseif type
        D(D < 0) = 0;
        AT       = T*diag(D)*T';
        C        = cholFix(AT,false);
    else
        error([mfilename ':: Matrix must be positive semi-definite'])
    end

end
