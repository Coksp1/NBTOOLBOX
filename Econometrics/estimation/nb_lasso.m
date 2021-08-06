function [beta,exitflag,residual,X] = nb_lasso(y,X,t,constant,options)
% Syntax:
%
% [beta,exitflag,residual,X] = nb_lasso(y,X,t,constant,options)
%
% Description:
%
% LASSO estimation using the local linearization and active set method
% proposed in [Osborne et al., 2000], [Osborne et al., 2000b].
%
% Solves the constrained optimization problem:
%
% min (y - X*beta)^2 
% s.t. sum(abs(beta)) <= 1/t
%
% The code is an adaption of code written by M. Schmidt. See:
% - https://www.cs.ubc.ca/~schmidtm/Software/lasso.html
% - M. Schmidt. Least Squares Optimization with L1-Norm Regularization. 
%   CS542B Project Report, 2005.
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
% - t        : The value of t in the minimization problem. Default is inf.
%              Must be a scalar number greater or equal to 0.
%
% - constant : If a constant is wanted in the estimation. Will be
%              added first in the right hand side variables. Default is 
%              false. The constant term is first estimate by the mean of
%              y, and then y is demeaned before doing the LASSO estimation.
% 
% - options   : Optimization options. As a struct. See nb_lasso.optimset.
%
% Output:
% 
% - beta       : A (extra + nxvar) x neq matrix with the estimated 
%                parameters. Where extra is 0, 1 or 2 dependent
%                on the constant and/or time trend is included.
%
% - exitflag   : The reason for exiting. One of:
%                > -1 : Numerical breakdown, check for dependent columns.
%                > -2 : Maximum number of iteration reached (maxIter).
%
%                See also: nb_interpretExitFlag. Set type to 'nb_lasso'.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix. 
%
% - X          : Regressors including constant. If more than one equation 
%                this will be given as kron(I,x).
% 
% See also:
% nb_lasso.optimset, nb_ols
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        options = [];
        if nargin < 4
            constant = false;
            if nargin < 3
                t = inf;
            end
        end
    end
    if isempty(options)
        options = nb_lasso.optimset();
    end
    
    % Do some initial tests
    t = 1/t;
    if t < 0
        error('The t input cannot be negativ.')
    end
    
    % Do we display iterations?
    verbose = strcmpi(options.display,'iter');
    if verbose
        if isfield(options,'displayer')
            displayer = options.displayer;
        else
            displayer = [];
        end
    else
        displayer = [];
    end
    
    % Are we dealing with a constant term?
    if constant
        c = mean(y,1);
        y = bsxfun(@minus,y,c);
    end
    
    % Loop equations
    [S,numX]  = size(X);
    [T,numEq] = size(y);
    if S ~= T
        error('The number of rows of y and X must be equal.')
    end
    beta = nan(size(X,2),numEq);
    for ii = 1:numEq
        [beta(:,ii),exitflag] = doOneEquation(y(:,ii),X,t,verbose,displayer,...
            options.mode,options.maxIter,options.threshold,options.beta0);
        if exitflag < 0
            residual = nan(T,numEq);
            X        = nan(T*numEq,numX*S);
            return
        end
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
function [w,exitFlag] = doOneEquation(y,X,t,verbose,displayer,mode,maxIter,threshold,w0)

    [~,p]     = size(X);
    iteration = 0;
    sigma_old = ones(p,1);
    XX        = X'*X;
    Xy        = X'*y;

    % initialize
    if isempty(w0)
        beta = zeros(p,1);
    else
        beta = w0;
    end
    sigma = abs(beta) > threshold;
    theta = sign(beta);
    
    exitFlag = 0;
    while iteration < maxIter
        
        % Get the values associated with the active set
        beta_sigma  = beta(sigma);
        theta_sigma = theta(sigma);
        if sum(sigma-sigma_old) ~= 0 || iteration == 0
            Xy_sigma = Xy(sigma);

            % QR insert
            if sum(sigma) <= 1 || iteration == 0
                if mode == 0
                    [Q,R] = qr(XX(sigma,sigma),0);
                else
                    [Q,R] = qr(X(:,sigma));
                end
            else
                [~, qrPos] = max(abs(sigma(sigma)-sigma_old(sigma)));
                if mode == 0
                    [Q,R] = qrinsert(Q,R,qrPos,XX(s,sigma_old),'row');
                    [Q,R] = qrinsert(Q,R,qrPos,XX(sigma,s),'col');
                else
                    % The below seems to be really slow in matlab
                    [Q,R] = qrinsert(Q,R,qrPos,X(:,s),'col');
                end
            end
        end
        % Solve the local linerization
        if mode == 0
            [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,t,beta);
        else
            [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
        end

        % ============================================================
        % Code below is strictly to deal with the sign infeasible case
        % (doesn't usually get used)
        % ============================================================
        while ~(sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1))
            
            if verbose
                notifyError(displayer,'Not sign feasible');
            end
            
            % A1: Find first zero-crossing
            min_gamma = 1;
            min_gamma_i = -1;
            for k = 1:size(beta,1)
                if (abs(beta(k)) > threshold)
                    gamma = -beta(k)/h(k);
                    if gamma > 0 && gamma < min_gamma
                        min_gamma = gamma;
                        min_gamma_i = k;
                    end
                end
            end
            if min_gamma_i == -1
                exitFlag = -1;
                if verbose
                    notifyError(displayer,'Numerical breakdown, check for dependent columns.');
                end
                break;
            end

            % A1: set beta to h truncated at first zero-crossing
            beta = beta + min_gamma*h;
            
            % A2: reverse sign of first zero-crossing
            theta(min_gamma_i) = -theta(min_gamma_i);
            
            % A2: recompute h
            theta_sigma = theta(sigma);
            beta_sigma  = beta(sigma);
            if mode == 0
                [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,t,beta);
            else
                [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
            end

            if sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1)
                if verbose
                    notifyError(displayer,'Now it is Sign Feasible.');
                end
            else
                if verbose
                    notifyError(displayer,'It is still Sign Infeasible.');
                end
                
                % A3: Remove the first zero-crossing from the active set
                sigma(min_gamma_i) = 0;
                beta(min_gamma_i)  = 0;
                
                % A3: Reset beta(min_gamma) and theta(min_gamma)
                beta(min_gamma_i)  = 0;
                theta(min_gamma_i) = 0;
                beta_sigma         = beta(sigma);
                theta_sigma        = theta(sigma);
                
                % A3: Recompute h
                Xy_sigma = Xy(sigma);
                
                % QR Update
                if mode == 0
                    [Q,R]      = qr(XX(sigma,sigma),0); % Could do a qr delete here instead
                    [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,t,beta);
                else
                    [Q,R]      = qr(X(:,sigma)); % Could do a qr delete here instead
                    [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
                end

                if verbose
                    if sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1)
                        notifyError(displayer,'Finally, it is sign feasible.');
                    else
                        notifyError(displayer,'It is still, STILL, not sign feasible. Going another round.');
                    end
                end
                
            end
            
        end
        
        % =============================================
        % End of Code to deal with sign infeasible case
        % =============================================

        iteration = iteration + 1;
        
        % compute violation
        v_denom = norm(Xy_sigma-X(:,sigma)'*X*beta_t,inf);
        if v_denom > 0
            v_t = (Xy-XX*beta_t)/v_denom;
        else
            v_t = (Xy-XX*beta_t)*inf;
        end
        j = p - sum(abs(beta_t) < threshold & abs(v_t) > 1 + threshold);

        % update log
        if verbose
            resForDisplay = struct('iteration',iteration,'fval',sum((X*beta-y).^2));
            update(displayer,sum(abs(beta_t)),resForDisplay,'iter');
        end
        
        % check for optimality
        if j == p || t == 0
            break;
        end

        % find and add the most violating variable
        % On the first iteration, all variables are equally violating
        % so we're going to use the Shevade/Perkins trick to introduce
        % a good first variable, this often means we may not have to deal with
        % sign feasibility later issues later
        if iteration == 1
            g      = computeSlope(beta,t,XX*beta-Xy,threshold);
            [~, s] = max(abs(g));
        else
            [~, s] = max(abs(sigma-1).*abs(v_t));
        end
        
        % update the active set
        sigma_old = sigma;
        sigma(s)  = 1;
        theta(s)  = sign(v_t(s));
        beta      = beta_t;
        
    end
    if not(j == p || t == 0)
        exitFlag = -2;
    end
    if verbose
        resForDisplay = struct('iteration',iteration,'fval',sum((X*beta-y).^2));
        update(displayer,sum(abs(beta_t)),resForDisplay,'done');
        if j == p || t == 0
            notifyError(displayer,'All components satisfy condition.');
        else
            notifyError(displayer,'Maximum number of iteration reached. All components does not satisfy condition.');
        end
    end
    w = beta_t;

end

%==========================================================================
function [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,t,beta)
% X'X = Q*R
% mu = max(0, theta'(X'X)^-1X'y - t) / theta'(X'X)^-1 theta)
% h = (X'X)^-1 * (X'(Y-Xw) - mu*theta)

    mu_denom = (theta_sigma'*(R \ (Q'*theta_sigma)));
    if mu_denom ~= 0
        mu = max(0,((theta_sigma'*(R \ (Q'*Xy_sigma))) - t)/mu_denom);
    else
        mu = 0;
    end
    h             = zeros(length(beta),1);
    h(sigma == 1) = R \ (Q'*((Xy_sigma-Q*R*beta_sigma)-(mu*theta_sigma)));
    beta_t        = beta+h;
    
end

%==========================================================================
function [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta)
% X = Q*R
% mu = max(0, theta'(X'X)^-1X'y - t) / theta'(X'X)^-1 theta)
% h = (X'X)^-1 * (X'(Y-Xw) - mu*theta)

    mu_denom = (theta_sigma'*(R\(R'\theta_sigma)));
    if mu_denom > 0
        mu = max(0,(theta_sigma'*((R\(Q'*y))) - t) / mu_denom);
    else
        mu = 0;
    end
    h             = zeros(length(beta),1);
    h(sigma == 1) = (R\(R'\(R'*(Q'*y-R*beta_sigma)-mu*theta_sigma)));
    beta_t        = beta+h;
    
end

%==========================================================================
function [slope_j] = computeSlope(w,lambda,g,threshold)
% A function that computes the appropriate derivative for non-zero w
% and points zero-valued w's in the right direction

    slope_j              = zeros(size(w,1),1);
    slope_j(g > lambda)  = g(g > lambda) - lambda;
    slope_j(g < -lambda) = g(g < -lambda) + lambda;
    slope_j(abs(w) > threshold) = g(abs(w) > threshold) + lambda*sign(w(abs(w) > threshold));
    
end
