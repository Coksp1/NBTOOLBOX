function [beta,exitflag,residual,XX,t,tPerc] = nb_lasso(y,X,t,constant,options,varargin)
% Syntax:
%
% [beta,exitflag,residual,XX,t,tPerc] = nb_lasso(y,X,t,constant,options,
%                                           varargin)
%
% Description:
%
% LASSO estimation using the local linearization and active set method
% proposed in [Osborne et al., 2000], [Osborne et al., 2000b].
%
% If this algorithm fail we try to use constrained optimization suggested
% by [Tibshirani, 1994].
%
% Solves the constrained optimization problem:
%
% min (y - X*beta)^2 
% s.t. sum(abs(beta)) <= 1/t
%
% Forming the lagrangian of the LASSO problem we have; 
%
% min (y - X*beta)^2 + lambda*(sum(abs(beta)) - 1/t)
%
% If you set the 'mode' input to 'lagrangian', the t input will set lambda
% and not t! In this case the Shooting method of [Fu, 1998] is used.
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
% - t        : The value of t in the minimization problem. Default is inf
%              (push all parameters to 0). Must be a scalar number greater
%              or equal to 0. As a double with size 1 x neq, or scalar.
%
%              If 'mode' is set to 'lagrangian', you set lambda of the
%              lagrange problem above instead. Again it must be set to a
%              double with size 1 x neq. Cannot be set to empty or inf in
%              this case.
%
% - constant : If a constant is wanted in the estimation. Will be
%              added first in the right hand side variables. Default is 
%              false. The constant term is first estimated by OLS, and 
%              then y is subtracted by this estimate before doing the 
%              LASSO estimation, if not 'restrictConstant' is set to false.
% 
% - options   : Optimization options. As a struct. See nb_lasso.optimset.
%
% Optional input:
%
% - 'mode'             : Either 'normal' or 'lagrangian'.
%
% - 'tPerc'            : Instead of setting t of the problem, you can use 
%                        this option to set the t as a percentage of 
%                        unrestricted estimation (OLS). Must be set to a 
%                        scalar double in (0,1), or a double vector with 
%                        size 1 x neq. If not empty, the t input is 
%                        ignored! If any element is nan, this input is
%                        ignored.
%
% - 'restrictConstant' : Restrict estimate of constant term to OLS 
%                        estimate. true or false. Default is true.
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
% - XX         : Regressors including constant. If more than one equation 
%                this will be given as kron(I,x).
%
% - t          : When 'tPerc' input is set, this gives the implied value
%                of t, otherwise it will just return t. Returned as a 
%                1 x neq double (i.e. may be expanded from scalar to 
%                vector if neq > 1).
%
% - tPerc      : When 'tPerc' is not provided, this will return the
%                percentage of unrestricted estimation implied by t, 
%                otherwise it will just return the tPerc input. Returned 
%                as a 1 x neq double.
% 
% See also:
% nb_lasso.optimset, nb_ols
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        options = [];
        if nargin < 4
            constant = false;
            if nargin < 3
                t = [];
            end
        end
    end
    if isempty(options)
        options = nb_lasso.optimset();
    end
    if isempty(t)
        t = inf;
    end
    mode = nb_parseOneOptional('mode','normal',varargin{:});
    
    % Do some initial tests
    if strcmpi(mode,'lagrangian')
        lambda = t;
        if isempty(lambda) || any(~isfinite(lambda))
            error(['When ''mode'' is set to ''lagrangian'' the t input ',...
                '(lagrange multiplier) cannot be empty or not fintite'])
        elseif any(lambda <= 0)
            error(['When ''mode'' is set to ''lagrangian'' the t input ',...
                '(lagrange multiplier) cannot be 0 or negative.'])
        end
    else
        tinv = 1./t;
        if any(tinv < 0)
            error('The t input (regularization coefficient) cannot be negativ.')
        end
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
    restrictConstant = nb_parseOneOptional('restrictConstant',true,varargin{:});
    
    % Add constant to X, if the constant term is not restricted
    if constant && ~restrictConstant
        X        = [ones(size(X,1),1), X];
        constant = 0;
    end

    % Check inputs
    [S,numX]  = size(X);
    [T,numEq] = size(y);
    if S ~= T
        error('The number of rows of y and X must be equal.')
    end
    if strcmpi(mode,'lagrangian')
        if isscalar(lambda)
            lambda = lambda(1,ones(1,numEq));
        elseif ~(isvector(lambda) && length(lambda) == numEq)
            error(['The t input (lagrange multiplier) must have as ',...
                'many elements as the number of columns of the y input ',...
                '(dependent variable), i.e. ', int2str(numEq) '.'])
        end
    else
        if isscalar(tinv)
            tinv = tinv(1,ones(1,numEq));
        elseif ~(isvector(tinv) && length(tinv) == numEq)
            error(['The t input (regularization coefficient) must have as ',...
                'many elements as the number of columns of the y input ',...
                '(dependent variable), i.e. ', int2str(numEq) '.'])
        end
    end
    
    % Estimate model by OLS
    dof = 3;
    if numX + constant >= T - dof && strcmpi(mode,'lagrangian')

        % In this we estimate the model as unrestricted as possible
        XOLS = X;
        if constant 
            XOLS = [ones(T,1),XOLS];
        end
        betaOLS = nan(numX + constant,numEq);
        for ii = 1:numEq
            [betaOLS(:,ii),exitflag] = doOneEquationLagrangian(y(:,ii),XOLS,...
                0.0001,verbose,displayer,options.maxIter,...
                options.threshold,zeros(numX + constant,numEq));
            if exitflag < 0
                residual = nan(T,numEq);
                XX       = nan(T*numEq,numX*S);
                t        = nan;
                tPerc    = nan;
                beta     = betaOLS; 
                return
            end
        end

    elseif numX + constant >= T

        error(['You must set the ''mode'' input to ''lagrangian'' to ',...
                'be able to estimate a model with more or equal number ',...
                'of parameters (', int2str(numX), ') as you have ',...
                'observations (' int2str(T) ')'])

    else
        betaOLS = nb_ols(y,X,constant);
    end

    % Is the tPerc input given, in this case we set t as a percentage of 
    % unrestricted estimation instead!
    tPerc = nb_parseOneOptional('tPerc',[],varargin{:});
    if ~isempty(tPerc)
        if isscalar(tPerc)
            tPerc = tPerc(1,ones(1,numEq));
        elseif ~(isvector(tPerc) && length(tPerc) == numEq)
            error(['The tPerc input (regularization as percent of ',...
                'unrestricted estimation) must have as ',...
                'many elements as the number of columns of the y input ',...
                '(dependent variable), i.e. ', int2str(numEq) '.'])
        end
        if strcmpi(mode,'lagrangian') && all(~isnan(tPerc))
            error(['The tPerc input (regularization as percent of ',...
                'unrestricted estimation) cannot be set when ''mode'' ',...
                'is set to ''lagrangian''.'])
        end
        if all(~isnan(tPerc)) && ~strcmpi(mode,'lagrangian')
            tinv_ols = sum(abs(betaOLS(constant+1:end,:)),1);
            tinv     = tinv_ols.*tPerc;
            if constant
                tinv = tinv + abs(betaOLS(1,:));
            end
        end
    end

    % Are we dealing with a constant term?
    yEst = y;
    if strcmpi(mode,'lagrangian')
        if constant
            c    = betaOLS(1,:);
            yEst = bsxfun(@minus,y,c);
        end
    else
        if any(tinv < 0)
            error('The regularization coefficient(s) cannot be negative')
        end
        if constant
            c    = betaOLS(1,:);
            yEst = bsxfun(@minus,y,c);
            tinv = tinv - abs(c); 
            if any(tinv < 0)
                error(['The regularization coefficient(s) cannot be negative ',...
                    'after substracting the constant! The estimated constant(s) ',...
                    'are;' toString(c) '. Implying regularization coefficient(s) ',...
                    'less than; ' toString(1./abs(c))])
            end
        end
    end

    % Intial value of the parameters
    if isempty(options.beta0)
        if numX + constant >= T - dof && strcmpi(mode,'lagrangian')
            options.beta0 = zeros(numX,numEq);
        else
            options.beta0 = nb_ols(yEst,X,false);
        end
    else
        if ~nb_sizeEqual(options.beta0,[numX,numEq])
            error(['The beta0 option does not match the number of estimated ',...
                  'parameter. Must have size ' int2str(numX) 'x' int2str(numEq)])
        end
    end

    % Loop equations
    beta = nan(numX,numEq);
    for ii = 1:numEq
        if strcmpi(mode,'lagrangian')
            [beta(:,ii),exitflag] = doOneEquationLagrangian(yEst(:,ii),X,...
                lambda(ii),verbose,displayer,options.maxIter,...
                options.threshold,options.beta0(:,ii));
        else
            [beta(:,ii),exitflag] = doOneEquation(yEst(:,ii),X,tinv(ii),...
                verbose,displayer,options.mode,options.maxIter,...
                options.threshold,options.beta0(:,ii));
            if exitflag < 0
                % Try without providing initial values
                [beta(:,ii),exitflag2] = doOneEquation(yEst(:,ii),X,tinv(ii),...
                    verbose,displayer,options.mode,options.maxIter,...
                    options.threshold,[]);
                if exitflag2 < 0
                    % Try another algorithm
                    [beta(:,ii),exitflag3] = doOneEquationConstrained(yEst(:,ii),...
                        X,tinv(ii),verbose,displayer,options.mode,...
                        options.maxIter,options.threshold);
                    if exitflag3 >= 0
                        exitflag = 0;
                    end
                else
                    exitflag = 0;
                end
            end
        end
        if exitflag < 0
            residual = nan(T,numEq);
            XX       = nan(T*numEq,numX*S);
            t        = nan;
            tPerc    = nan;
            if constant 
                beta = [c; beta]; %#ok<AGROW>
            end
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
            XX = [ones(T,1), X];
        else
            XX = X;
        end
        residual = y - XX*beta;
        
        if nargout > 2
           XX = kron(eye(numEq),XX); 
        end
        
    end
    if nargout > 4
        if strcmpi(mode,'lagrangian')
            t     = 1./sum(abs(beta),1);
            tPerc = [];
            if constant
                tinv = 1./t - abs(c);
            else
                tinv = 1./t;
            end
        else
            if isempty(tPerc) || all(isnan(tPerc)) 
                if constant
                    t = 1./(tinv + abs(c));
                else
                    t = 1./tinv;
                end
            else
                t = 1./sum(abs(beta),1);
            end
        end
    end
    if nargout > 5
        if isempty(tPerc) || all(isnan(tPerc))
            tinv_ols = sum(abs(betaOLS(constant + 1:end,:)),1);      
            tPerc    = tinv./tinv_ols;
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
    if verbose
        resForDisplay = struct('iteration',iteration,'fval',sum((X*beta-y).^2));
        update(displayer,sum(abs(beta)),resForDisplay,'init');
    end
    
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
                gamma = -beta(k)/h(k);
                if gamma > 0 && gamma < min_gamma
                    min_gamma = gamma;
                    min_gamma_i = k;
                end
            end
            if min_gamma_i == -1
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
    elseif sum(abs(beta)) > t + threshold
        exitFlag = -1;
    end
    if verbose
        resForDisplay = struct('iteration',iteration,'fval',sum((X*beta-y).^2));
        update(displayer,sum(abs(beta_t)),resForDisplay,'done');
        if exitFlag == -1
            notifyError(displayer,['Solution found does not satisfy the ',...
                'constraint. Proably due to numerical breakdown.']);
        elseif j == p || t == 0
            notifyError(displayer,['Maximum number of iteration reached. ',...
                'All components does not satisfy condition.']);
        else
            notifyError(displayer,'All components satisfy condition.');
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

%==========================================================================
function [beta,exitFlag] = doOneEquationLagrangian(y,X,lambda,verbose,...
    displayer,maxIter,threshold,beta)
% The Shooting method of [Fu, 1998]

    exitFlag  = 0;
    [~,p]     = size(X);
    iteration = 0;
    XX2       = X'*X*2;
    Xy2       = X'*y*2;
    while iteration < maxIter
        
        beta_old = beta;
        for j = 1:p
            
            % Compute the Shoot and Update the variable
            S0 = sum(XX2(j,:)*beta) - XX2(j,j)*beta(j) - Xy2(j);
            if S0 > lambda
                beta(j,1) = (lambda - S0)/XX2(j,j);
            elseif S0 < -lambda
                beta(j,1) = (-lambda - S0)/XX2(j,j);
            elseif abs(S0) <= lambda
                beta(j,1) = 0;
            end
            
        end
        
        iteration = iteration + 1;
        
        % Update the log
        if verbose
            resForDisplay = struct('iteration',iteration,'fval',...
                sum((X*beta - y).^2) + lambda*sum(abs(beta)));
            update(displayer,sum(abs(beta)),resForDisplay,'iter');
        end

        % Check termination
        if sum(abs(beta - beta_old)) < threshold
            break;
        end
        
        
    end
    if verbose
        resForDisplay = struct('iteration',iteration,'fval',sum((X*beta - y).^2) + lambda*sum(abs(beta)));
        update(displayer,sum(abs(beta)),resForDisplay,'done');
        if iteration == maxIter
            exitFlag = -2;
            notifyError(displayer,['Maximum number of iteration reached. ',...
                'All components does not satisfy condition.']);
        else
            notifyError(displayer,sprintf(['Solution found. Number of ',...
                'iterations: %d. Total Shoots: %d.'],iteration,iteration*p));
        end
    end

end

function [w,exitflag] = doOneEquationConstrained(y,X,t,verbose,...
    displayer,mode,maxIter,threshold)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Constrained Optimization with linear constraints,
%
%   min ([X -X]w-y).^2 s.t. w >= 0, sum(w) <= t
%   (suggested in [Tibshirani, 1994])
%
% Mode (solve function):
%   0 - Use Matlab's quadprog (Quadratic Program solver)
%   1 - Use Matlab's lsqlin (Least Squares w/ Linear Constraints solver)
%       (only for mode==0 or mode==2)
%   2 - Use Matlab's fmincon (General Constrained solver)

    [~, p]   = size(X);
    exitflag = 0;
    options  = optimset('Display','off','MaxIter',maxIter,...
        'LargeScale','off','MaxFunEvals',maxIter,'TolX',threshold);
    
    % Form Parameters
    w_init = X\y;
    if sum(abs(w_init)) < t
        if verbose
            notifyError(displayer,'Solution is the Least Squares Solution.');
        end
        w = w_init;
        return;
    end
    X      = [X -X];
    A      = ones(1,2*p);
    b      = t;
    LB     = zeros(2*p,1);
    UB     = t*ones(2*p,1);
    w_init = [w_init.*(w_init>=0);-w_init.*(w_init<0)];
    if mode == 0
        H = X'*X;
        f = -y'*X;
    elseif mode == 2
        gradFunc = @LSobj;
        gradArgs = {X'*X,X'*y*2,y'*y};
    end

    if verbose
        options.Display = 'iter';
        resForDisplay   = struct('iteration',0,'fval',sum((X*w_init-y).^2));
        update(displayer,sum(abs(w_init)),resForDisplay,'init');
    end

    % Solve Problem
    if mode == 0
        [w, ~, exitflag, output] = quadprog(H,f,A,b,[],[],LB,UB,w_init,options);
    elseif mode == 1
        [w, ~, ~, exitflag, output] = lsqlin(X,y,A,b,[],[],LB,UB,w_init,options);
    else
        [w, ~, exitflag, output] = fmincon(gradFunc,w_init,A,b,[],[],LB,UB,...
            [],options,gradArgs{:});
    end
    
    % Form the final weight vector
    w = w(1:p) - w(p+1:2*p);
        
    % Output Log
    if mode < 2
        X = X(:,1:p);
    end
    if verbose
        resForDisplay = struct('iteration',output.iterations,'fval',sum((X*w - y).^2));
        update(displayer,sum(abs(w)),resForDisplay,'done');
        if output.iterations >= maxIter
            exitflag = -2;
            notifyError(displayer,['Maximum number of iteration reached. ',...
                'All components does not satisfy condition.']);
        elseif exitflag < 0
            notifyError(displayer,'All components does not satisfy condition.');
        else
            notifyError(displayer,sprintf(['Solution found. Number of ',...
                'iterations: %d.'],output.iterations));
        end

    end
    w(abs(w) <= threshold) = 0;

end

%==========================================================================
function [f,g] = LSobj(w,XX,Xy2,yy)
    f = sum(w'*XX*w - w'*Xy2 + yy);
    if nargout > 1
       g = 2*XX*w - Xy2; 
    end
end
