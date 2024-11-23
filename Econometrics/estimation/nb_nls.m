function [message,beta,stdBeta,tStatBeta,pValBeta,residual,omega] = nb_nls(init,ub,lb,opt,optimizer,covrepair,func,y,x,constant,varargin)
% Syntax:
%
% [message,beta,stdBeta,tStatBeta,pValBeta,residual,omega] = ...
%     nb_nls(init,ub,lb,opt,optimizer,covrepair,func,y,x,constant,...
%             varargin)
%
% Description:
%
% Estimate multiple (unrelated) equations using nls.
%
% y = X*func(beta) + residual, residual ~ N(0,residual'*residual/nobs) (1)
%
% Input:
% 
% - init      : Initial values of the parameters of the model to estimate.
%               As a nParam x nEq double.
%              
% - ub        : Upper bound on the parameters of the model to estimate.
%               As a nParam x nEq or nParam x 1 double. If given as empty  
%               inf is default. Only applies if optimizer is set to 
%               'fmincon'.
%
% - lb        : Lower bound on the parameters of the model to estimate.
%               As a nParam x nEq or nParam x 1 double. If given as empty  
%               -inf is default. Only applies if optimizer is set to 
%               'fmincon'.
%
% - opt       : See the optimset function for more on this input. Default
%               values will be used if it is given as [].
%
% - optimizer : The optimizer to be used; 'fminunc', 'fminsearch' or 
%               'fmincon'. 'fmincon' is default, i.e. if not 'fminunc'
%               or 'fminsearch' is provided.
%
% - covrepair : Give true to repair the covariance matrix of the 
%               estimated parameters if found to not be positive 
%               definite. Default is false, i.e. to throw an error if 
%               the covariance matrix is not positive definite.
%
% - func      : A function handle that takes the inputs in the following 
%               order:
%               > One column from the parameter matrix (i.e. the parameters 
%                 for one equation at the time)
%               > One column from the y input, i.e. a double with size
%                 nobs x 1.
%               > The x input.
%               > The constant input.
%               > The rest of the optional inputs given to this function 
%                 (varargin)
%
%               The output should be a nobs x 1 double with the residuals
%               given the provided parameters.
%
% - y         : A double matrix of size nobs x neq of the dependent 
%               variable of the regression(s).
%
% - x         : A double matrix of size nobs x nxvar of the right  
%               hand side variables of all equations of the 
%               regression.
%
% - constant  : If a constant is wanted in the estimation. Will be
%               added first in the right hand side variables.
% 
% Optional input:
%
% - 'Aeq'     : Aeq*beta  = Beq (linear constraints).
%
% - 'Beq'     : Aeq*beta  = Beq (linear constraints).
%
% - 'NONLCON' : A function handle that return the values of C(beta) and
%               Ceq(beta), where C(beta) <= 0 and Ceq(beta) == 0. E.g.
%               [C,Ceq] = nonlinconstr(beta).
%
% - varargin  : The rest will be given as optional inputs to the func 
%               input.
% 
% Output: 
% 
% - message    : Non-empty if some error are thrown during estimation.
%
% - beta       : A (constant + nxvar) x neq matrix with the estimated 
%                parameters.
%
% - stdBeta    : A (constant + nxvar) x neq matrix with the standard   
%                deviation of the estimated paramteres. 
%
% - tStatBeta  : A (constant + nxvar) x neq matrix with t-statistics  
%                of the estimated paramteres. 
%
% - pValBeta   : A (extra + nxvar) x neq matrix with the p-values  
%                of the estimated paramteres. 
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix. 
%
% - omega      : Covariance matrix of estimated parameters. As (extra + 
%                nxvar) x (extra + nxvar) x neq
%
% See also
% nb_midasFunc
%
% Written by Kenneth S. Paulsen
 
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get linear constraints
    [Aeq,varargin]     = nb_parseOneOptional('Aeq',[],varargin{:});
    [Beq,varargin]     = nb_parseOneOptional('Beq',[],varargin{:});
    [NONLCON,varargin] = nb_parseOneOptional('NONLCON',[],varargin{:});
    if ~isempty(Aeq)
        if ~strcmpi(optimizer,'fmincon')
            error([mfilename ':: You need to use the ''fmincon'' optimizer if you add linear constraints (''Aeq'' and ''Beq'' inputs).'])
        end
        if isempty(Beq)
            error([mfilename ':: If you provide the ''Aeq'' input, you also need to provide the ''Beq'' input.'])
        end
    else
        Beq = [];
    end

    % Preallocate
    message   = '';
    beta      = init;
    stdBeta   = init;
    tStatBeta = init;
    pValBeta  = init;
    residual  = y;
    omega     = nan(size(init,1),size(init,1),size(init,2));

    % Check
    if isempty(x)
        sizeX = size(y,1);
        x     = zeros(sizeX,0);
    else
        sizeX = size(x,1);
    end
    
    % Add constant if wanted
    if constant        
        x = [ones(sizeX,1), x];
    end

    [T, N]     = size(x); 
    [nobs2, E] = size(y);
    if (T ~= nobs2)
        message = [mfilename ':: x and y must have same number of observations.']; 
    end
    if T < 3
        message = [mfilename ':: The estimation sample must be longer than 2 periods.'];
    end
    if T <= N
        message = [mfilename ':: The number of estimated parameters must be less than the number of observations.'];
    end
    if ~isempty(message)
        beta      = [];
        stdBeta   = [];
        tStatBeta = [];
        pValBeta  = [];
        residual  = [];
        omega     = [];
        return
    end
    if isempty(opt)
        opt             = optimset(optimizer);
        opt.Display     = 'off';
        opt.MaxFunEvals = 2000;
        opt.MaxIter     = 500;
        opt.TolFun      = sqrt(eps);
        opt.TolX        = sqrt(eps);
        opt.LargeScale  = 'off';
    end
    
    % Bounds
    if isempty(ub)
        ub = inf(size(init,1),size(init,2));
    else
        if size(ub,2) == 1
            ub = ub(:,ones(1,E));
        end
    end
    if isempty(lb)  
        lb = -inf(size(init,1),size(init,2));
    else
        if size(lb,2) == 1
            lb = lb(:,ones(1,E));
        end    
    end
    if size(init,2) == 1
        init = init(:,ones(1,E));
    end
    
    % Do the estimation for each equation separate
    for ii = 1:E
    
        if strcmpi(optimizer,'fminunc')
            [beta(:,ii),~,flag,~,~,H] = fminunc(@calculateSquares,init(:,ii),opt,func,y(:,ii),x,constant,varargin);
        elseif strcmpi(optimizer,'fminsearch')
            [beta(:,ii),~,flag] = fminsearch(@calculateSquares,init(:,ii),opt,func,y(:,ii),x,constant,varargin);
            H                   = nb_hessian(@(p)calculateSquares(p,func,y(:,ii),x,constant,varargin),beta(:,ii));
        else
            [beta(:,ii),~,flag,~,~,~,H] = fmincon(@calculateSquares,init(:,ii),[],[],Aeq,Beq,lb(:,ii),ub(:,ii),NONLCON,opt,func,y(:,ii),x,constant,varargin);
        end
        
        message = nb_interpretExitFlag(flag,optimizer,[' Estimation of model failed for equation ' int2str(ii) '.']);
        if ~isempty(message)
            message = [mfilename ':: ' message]; %#ok<AGROW>
            return
        end
        
        % Calculate standard deviations
        if nargout > 1
            if rcond(H) < eps^(0.9)
                message = [mfilename ':: Standard error of paramters cannot be calulated. Hessian is badly scaled.'];
                return
            else
                omegaT    = H\eye(size(H,1));
                stdEstPar = sqrt(diag(omegaT));
                if any(~isreal(stdEstPar))
                    if covrepair
                        omegaT    = nb_covrepair(omegaT,false);
                        stdEstPar = sqrt(diag(omegaT));
                    else
                        message = [mfilename ':: Standard error of paramters are not real, something went wrong...'];
                        return
                    end
                end
            end
            stdBeta(:,ii) = stdEstPar(:);
            omega(:,:,ii) = omegaT;
        end
        
    end
    
    % t-statistics
    if nargout > 2 
        tStatBeta = beta./stdBeta;
    end
    
    % p-values
    if nargout > 3
        try
            pValBeta = nb_tStatPValue(tStatBeta,T-N);
        catch %#ok<CTCH>
           message = [mfilename ':: t-statistic not valid. Probably due to colinearity or missing observations?!'];
        end
    end
    
    if nargout > 4
        for ii = 1:E
            residual(:,ii) = func(beta(:,ii),y,x,constant,varargin{:});
        end
    end
    
end

%==========================================================================
function fVal = calculateSquares(p,func,y,x,constant,inputs)
% Calculate the sum of squares

    res  = func(p,y,x,constant,inputs{:});
    res  = res(:);
    fVal = sum(res.^2);
    
end
