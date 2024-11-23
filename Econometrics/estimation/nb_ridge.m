function [beta,residual,X,c,cPerc,k] = nb_ridge(y,X,k,constant,varargin)
% Syntax:
%
% [beta,residual,X,c,cPerc,k] = nb_ridge(y,X,k,constant,varargin)
%
% Description:
%
% RIDGE estimation. Solves the constrained optimization problem:
%
% min (y - X*beta)^2 
% s.t. beta'*beta = c
%
% Practically we set up a Lagrangian to solve this problem;
%
% min (y - X*beta)^2 + k*(beta'*beta - c)
%
% Caution: Each equation is estimated separately.
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
%              false. The constant term is first estimated by OLS, and 
%              then y is subtracted by this estimate before doing the 
%              RIDGE estimation, if not 'restrictConstant' is set to false.
%
% Optional input:
%
% - 'cPerc'            : Instead of setting k of the problem, you can use 
%                        this option to set the k, so c in the above 
%                        problem is as a percentage of unrestricted 
%                        estimation (OLS). Must be set to a scalar double
%                        in (0,1), or a double vector with size 
%                        1 x neq. If not empty, the k input is ignored!
%                        If any element is nan, this input is ignored.
%                        
%
% - 'restrictConstant' : Restrict estimate of constant term to OLS 
%                        estimate. true or false. Default is true.
%
% - 'optimset'         : A struct with optimization options. See for
%                        example nb_getDefaultOptimset('fminsearch').
%                        Only need when 'cPerc' is provided. fminsearch
%                        is then utilized to find the k that matches this
%                        input.
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
% - c        : The implied c = beta'*beta, from the choosen value of k or 
%              cPerc. As a 1 x neq double.
%
% - cPerc    : The implied c as percentage of unrestricted estimation (OLS)
%              (beta'*beta)/(beta_ols'*beta_ols). As a 1 x neq double.
%
% - k        : The value of k in the minimization problem above. As a 1 x
%              neq double.
% 
% See also:
% nb_ols, nb_lasso
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        constant = false;
        if nargin < 3
            k = [];
        end
    end
    
    % Are we dealing with a constant term?
    restrictConstant = nb_parseOneOptional('restrictConstant',true,varargin{:});
    cPerc            = nb_parseOneOptional('cPerc',[],varargin{:});
    optimset         = nb_parseOneOptional('optimset',[],varargin{:});

    % Add constant to X, if the constant term is not restricted
    if constant && ~restrictConstant
        X        = [ones(size(X,1),1), X];
        constant = 0;
    end
    
    [T,numEq] = size(y);
    S = size(X,1);
    if S ~= T
        error('The number of rows of y and X must be equal.')
    end

    % Estimate model by OLS
    betaOLS = nb_ols(y,X,constant);
    if constant
        yRidge = bsxfun(@minus,y,betaOLS(1,:));
    else
        yRidge = y;
    end

    % Do we need to find k?
    if isempty(cPerc) || any(isnan(cPerc))
        if isempty(k) || any(~isfinite(k)) 
            if isempty(k)
                k = nan(1,numEq);
            elseif isscalar(k)
                k = k(1,ones(1,numEq));
            elseif length(k) ~= numEq
                error('The k input must match the second dimension of the y input if it is not scalar.')
            end 
            for ii = 1:numEq
                if ~isfinite(k(ii))
                    k(ii) = findK(yRidge(:,ii),X);
                end
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
    end

    % Is the tPerc input given, in this case we set t as a percentage of 
    % unrestricted estimation instead!
    if ~isempty(cPerc)
        if isscalar(cPerc)
            cPerc = cPerc(1,ones(1,numEq));
        elseif ~(isvector(cPerc) && length(cPerc) == numEq)
            error(['The kPerc input (regularization as percent of ',...
                'unrestricted estimation) must have as ',...
                'many elements as the number of columns of the y input ',...
                '(dependent variable), i.e. ', int2str(numEq) '.'])
        end
        if all(~isnan(cPerc))
            k = nan(1,numEq);
            for ii = 1:numEq
                k(ii) = findKFromCPerc(yRidge(:,ii),X,betaOLS(:,ii),...
                    cPerc(ii),constant,ii,optimset);
            end
        end
    end

    % Are we dealing with a constant term?
    if any(k < 0)
        error('The regularization coefficient(s) cannot be negative')
    end
    
    % Loop equations
    beta = nan(size(X,2),numEq);
    for ii = 1:numEq
        beta(:,ii) = doOneEquation(yRidge(:,ii),X,k(ii));
    end
    
    if constant 
        beta = [betaOLS(1,:); beta];
    end
    
    % Calculate residual
    if nargout > 1
        if constant
            XX = [ones(T,1), X];
        else
            XX = X;
        end
        residual = y - XX*beta;
        
        if nargout > 2
           X = kron(eye(numEq),X); 
        end
        
    end
    if nargout > 3
        c = sum(beta.^2,1);
    end
    if nargout > 4
        if isempty(cPerc) || any(isnan(cPerc))
            c_rest     = sum(beta(constant + 1:end,:).^2,1);
            c_ols_rest = sum(betaOLS(constant + 1:end,:).^2,1);   
            cPerc      = c_rest./c_ols_rest;
        end
    end
    
end

%==========================================================================
function beta = doOneEquation(y,X,k)

    [T, N] = size(X); 
    if T < 3
        error('The estimation sample must be longer than 2 periods.');
    end
    beta = (X'*X + k*eye(N))\(X'*y);

end

%==========================================================================
function k = findKFromCPerc(y,X,betaOLS,cPerc,constant,ii,optimset)

    if isempty(optimset)
        optimset = getOpt();
    end

    constant       = double(constant);
    c_ols_rest     = sum(betaOLS(constant + 1:end).^2,1);
    c2Match        = c_ols_rest.*cPerc;
    func           = @(x)finder(x,c2Match,y,X);
    [k,~,exitflag] = fminsearch(func,1,optimset);
    if exitflag < 0
        nb_interpretExitFlag(exitflag,'fminsearch',[' Failed during ',...
            'RIDGE estimation for equation ' int2str(ii)])
    end

end

%==========================================================================
function f = finder(k,c2Match,y,X)

    beta = doOneEquation(y,X,k);
    c    = beta'*beta;
    f    = (c - c2Match).^2;     

end

%==========================================================================
function opt = getOpt()

    tol = eps^(0.5);
    opt = optimset('Display','off','MaxFunEvals',10000,...
                   'MaxIter',10000,'TolFun',tol,'TolX',tol);

end

%==========================================================================
function k = findK(y,X)

    [n,p] = size(X);
    alpha = (X'*X)\(X'*y);
    resid = y - X*alpha;
    sigma = (resid'*resid)/(n - p - 1);
    k     = (p*sigma)/(alpha'*alpha);

end
