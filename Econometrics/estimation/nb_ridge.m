function [beta,residual,X] = nb_ridge(y,X,k,constant)
% Syntax:
%
% [beta,residual,X] = nb_ridge(y,X,k,constant)
%
% Description:
%
% RIDGE estimation. Solves the constrained optimization problem:
%
% min (y - X*beta)^2 + k*sum(beta(i)^2)
% 
% Input:
% 
% - y        : A double matrix of size nobs x neq of the dependent 
%              variable of the regression(s).
%
% - X        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression.
%
% - k        : The value of k in the minimization problem. Default is 
%              nxvar*sigma_ols^2/(beta_ols'*beta_ols), where sigma_ols is
%              the ols estimator of the residual variance, and beta_ols is
%              the ols estimate of the model parameters. Must be a scalar 
%              number greater or equal to 0.
%
% - constant : If a constant is wanted in the estimation. Will be
%              added first in the right hand side variables. Default is 
%              false. The constant term is first estimate by the mean of
%              y, and then y is demeaned before doing the RIDGE estimation.
% 
% Output:
% 
% - beta     : A (extra + nxvar) x neq matrix with the estimated 
%              parameters. Where extra is 0, 1 or 2 dependent
%              on the constant and/or time trend is included.
%
% - residual : Residual from the estimated equation. As an 
%              nobs x neq matrix. 
%
% - X        : Regressors including constant. If more than one equation 
%              this will be given as kron(I,x).
% 
% See also:
% nb_ols, nb_lasso
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        constant = false;
        if nargin < 3
            k = [];
        end
    end
    
    % Are we dealing with a constant term?
    if constant
        c = mean(y,1);
        y = bsxfun(@minus,y,c);
    end
    
    % Do we need to find k?
    [T,numEq] = size(y);
    if isempty(k)
        k = nan(1,numEq);
        for ii = 1:numEq
            k(ii) = findK(y(:,ii),X);
        end
    elseif any(k < 0)
        error('The k input cannot be negativ.')
    else
        if isscalar(k)
            k = k(1,ones(1,numEq));
        elseif length(k) ~= numEq
            error('The k input must match the second dimension of the y input if it is not scalar.')
        end
    end
    
    % Loop equations
    S = size(X,1);
    if S ~= T
        error('The number of rows of y and X must be equal.')
    end
    beta = nan(size(X,2),numEq);
    for ii = 1:numEq
        beta(:,ii) = doOneEquation(y(:,ii),X,k(ii));
    end
    
    % Add constant to estimated parameters
    if constant 
        beta = [c; beta];
    end
    
    % Calculate residual
    if nargout > 1
        if constant
            X = [ones(T,1), X];
        end
        residual = y - X*beta;
        
        if nargout > 2
           X = kron(eye(numEq),X); 
        end
        
    end
    
end

%==========================================================================
function beta = doOneEquation(y,x,k)

    [T, N] = size(x); 
    if T < 3
        error([mfilename ':: The estimation sample must be longer than 2 periods.']);
    end
    
    xpxi = (x'*x - k*eye(N))\eye(N);
    beta = xpxi*(x'*y);

end

%==========================================================================
function k = findK(y,X)

    [n,p] = size(X);
    alpha = (X'*X)\(X'*y);
    resid = y - X*alpha;
    sigma = (resid'*resid)/(n - p - 1);
    k     = (p*sigma)/(alpha'*alpha);

end
