function [beta,stdBeta,tStatBeta,pValBeta,residual,x,betaB] = nb_qreg(q,y,x,constant,timeTrend,method,draws,restr,waitbar,algo)
% Syntax:
%
% beta = nb_qreg(y,x)
% [beta,stdBeta,tStatBeta,pValBeta,residual,x,betaB] = ...
%       nb_qreg(q,y,x,constant,timeTrend,method,draws,restr,waitbar,algo)
%
% Description:
%
% Estimate multiple (unrelated) equations using quantile regression.
%
% y = X*beta + residual
%
% Caution: Statistics package needed.
%
% Input:
% 
% - q        : The quantile(s) of the regression. As a row vector of
%              doubles between 0 and 1. If size(y,2) this input must be
%              a scalar.
%
% - y        : A double matrix of size nobs x neq of the dependent 
%              variable of the regression(s).
%
% - x        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression.
%
% - constant : If a constant is wanted in the estimation. Will be
%              added first in the right hand side variables.
% 
% - timeTrend : If a linear time trend is wanted in the estimation. 
%               Will be added first/second in the right hand side 
%               variables. (First if constant is not given, else 
%               second)
%
% - method    : A string with the method to be used to bootstrap the 
%               standard errors. See nb_bootstrap for the supported 
%               methods or use 'sparsity'. 'sparsity' is default and it
%               uses the asymptotic formulas found in; 
%               https://support.sas.com/documentation/onlinedoc/stat/
%               141/qreg.pdf
%
% - draws     : Number of draws when bootstrapping the standard errors.
%
% - restr     : A 1 x neq cell where each element is a 1 x nxvar + extra   
%               logical. Where extra is 0, 1 or 2 dependent on the constant 
%               and/or time trend is included. Each logical element must be  
%               true to include in the regression of the corresponding 
%               equation. May also be empty, which is default, i.e. no
%               restrictions added.
%
% - waitbar   : Add waitbar during estimation. Default is false. true or
%               false.
%        
% Output: 
% 
% - beta       : A (extra + nxvar) x neq x numQuantiles matrix with the  
%                estimated parameters. Where extra is 0, 1 or 2 dependent
%                on the constant and/or time trend is included.
%
% - stdBeta    : A (extra + nxvar) x neq matrix with the standard   
%                deviation of the estimated paramteres. Where extra 
%                is 0, 1 or 2 dependent on the constant and/or time 
%                trend is included.
%
% - tStatBeta  : A (extra + nxvar) x neq matrix with t-statistics  
%                of the estimated paramteres. Where extra is 0, 1 
%                or 2 dependent on the constant and/or time trend 
%                is included.
%
% - pValBeta   : A (extra + nxvar) x neq matrix with the p-values  
%                of the estimated paramteres. Where extra is 0, 1 
%                or 2 dependent on the constant and/or time trend 
%                is included.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix. 
%
% - x          : Regressors including constant and time-trend.
% 
% - betaB      : Distribution of parameters produced by bootstrapping. A   
%                (extra + nxvar) x neq x numQuantilesx nDraws matrix with  
%                the estimated parameters. Where extra is 0, 1 or 2 
%                dependent on the constant and/or time trend is included.
%
% See also
% nb_quantileEstimator, nb_singleEq, nb_bootstrap, linprog
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 10
        algo = 'qreg';
        if nargin < 9
            waitbar = false;
            if nargin < 8
                restr = [];
                if nargin < 7
                    draws = 1000;
                    if nargin < 6
                        method = 'sparsity';
                        if nargin < 5
                            timeTrend = 0;
                            if nargin < 4
                                constant = 0;
                            end
                        end
                    end
                end
            end
        end
    end
    
    warning('off','optim:linprog:WillRunDiffAlg')
    
    if isempty(x)
        sizeX = size(y,1);
        x     = zeros(sizeX,0);
    else
        sizeX = size(x,1);
    end
    
    % Add constant if wanted
    if timeTrend
        trend = 1:sizeX;
        x     = [trend', x];
    end
    
    % Add constant if wanted
    if constant        
        x = [ones(sizeX,1), x];
    end

    [T, N]     = size(x); 
    [nobs2, E] = size(y);
    if (T ~= nobs2)
        error([mfilename ':: x and y must have same # obs.']); 
    end
    if T < 3
        error([mfilename ':: The estimation sample must be longer than 2 periods.']);
    end
    if T <= N
        error([mfilename ':: The number of estimated parameters must be less than the number of observations.'])
    end
    
%     if E > 1
%         if ~isscalar(q)
%             error([mfilename ':: q must be a scalar if size(y,2)>1'])
%         end
%     end
    
    % Estimate the model by linear programming methods
    numQ = length(q);
    if isempty(restr)
        if strcmpi(algo,'QRboot')
            if constant        
                xt = x(:,2:end);
            else
                xt = x;
            end
            beta = nan(N,E,numQ);
            for ii = 1:E
                Res          = QRboot(xt, y(:,ii), 1, 0, q, 0, 0);
                beta(:,ii,:) = permute(Res.BQ,[1,3,2]);
            end
        else
            beta = qReg(y,x,T,E,N,q,numQ);
        end
    else
        beta = qRegRestr(y,x,T,E,N,q,numQ,restr);
    end
    
    % Standard deviation of the estimated paramteres (beta)
    if nargout > 1
        
        if strcmpi(method,'sparsity')
            
            betaB   = nan(N,E,numQ,draws);
            stdBeta = nan(N,E,numQ);
            resid   = nan(T,E,numQ);
            for qq = 1:numQ
                xBeta           = x*beta(:,:,qq);
                residT          = y - xBeta;
                resid(:,:,qq)   = residT;
                for ee = 1:E
                    [stdBeta(:,ee,qq),betaB(:,ee,qq,:)] = sparsitySTD(x,residT(:,ee),q(qq),draws);
                end
            end
            
        else
        
            % Waitbar
            [h,note,isWaitbar] = nb_quantileEstimator.openWaitbar(waitbar,draws,numQ);

            betaB = nan(N,E,numQ,draws);
            resid = nan(T,E,numQ);
            for qq = 1:numQ

                xBeta         = x*beta(:,:,qq);
                residT        = y - xBeta;
                resid(:,:,qq) = residT;
                EPS           = nb_bootstrap(resid,draws,method);
                EPS           = permute(EPS,[3,1,2]);
                yd            = bsxfun(@plus,xBeta,EPS);
                if isempty(restr)

                    ii = 1;
                    kk = 1;
                    tt = 1;
                    while ii <= draws
                        try
                            betaB(:,:,qq,ii) = qReg(yd(:,:,kk),x,T,E,N,q(qq),1);
                            if isWaitbar % Update waitbar
                                nb_quantileEstimator.notifyWaitbar(h,ii,tt,note);
                            end
                            ii = ii + 1;
                        catch
                            if kk == draws + 1
                                EPS = nb_bootstrap(resid,draws/10,method);
                                EPS = permute(EPS,[3,1,2]);
                                yd  = bsxfun(@plus,xBeta,EPS);
                                kk  = 1;   
                            end
                        end
                        kk = kk + 1;
                        tt = tt + 1;
                    end

                else
                    
                    ii = 1;
                    kk = 1;
                    tt = 1;
                    while ii <= draws
                        try
                            betaB(:,:,qq,ii) = qRegRestr(yd(:,:,kk),x,T,E,N,q(qq),1,restr);
                            if isWaitbar % Update waitbar
                                nb_quantileEstimator.notifyWaitbar(h,ii,tt,note);
                            end
                            ii = ii + 1;
                        catch
                            if kk == draws + 1
                                EPS = nb_bootstrap(resid,draws/10,method);
                                EPS = permute(EPS,[3,1,2]);
                                yd  = bsxfun(@plus,xBeta,EPS);
                                kk  = 1;   
                            end
                        end
                        kk = kk + 1;
                        tt = tt + 1;
                    end

                end

                if isWaitbar % Update waitbar
                    nb_quantileEstimator.notifyWaitbarQuantile(h,qq,note,numQ);
                end

            end
            stdBeta = std(betaB,0,4);
            
            if isWaitbar
                nb_quantileEstimator.closeWaitbar(h);
            end
        
        end

    end
    
    % t-statistics
    if nargout > 2 
        tStatBeta                       = abs(beta)./stdBeta;
        tStatBeta(~isfinite(tStatBeta)) = 0;
    end
    
    % p-values
    if nargout > 3
        try
            pValBetaStacked = nb_tStatPValue(tStatBeta(:),T-N);
        catch %#ok<CTCH>
           error('t-statistic not valid. Probably due to colinearity or missing observations?!') 
        end
        pValBeta = reshape(pValBetaStacked,N,E,numQ);
    end
    
    if nargout > 4
        residual = resid;
    end
    
end

%==========================================================================
function beta = qReg(y,x,T,E,N,q,numQ)
% If meadian regression is done this amount to least-absolute-
% deviations estimation, which means that the problem is symmetric

    opt  = optimset('display','off','maxIter',5000);
    beta = nan(N,E,numQ);
    O    = ones(T,1);
    I    = eye(T);
    A    = [I,-I, x];
    lb   = [zeros(T*2,1);-inf*ones(N,1)];
    ub   = inf*ones(T*2 + N,1);
    for qq = 1:numQ
        
        f = [q(qq)*O;(1-q(qq))*O;zeros(N,1)];
        for ii = 1:E

            B              = y(:,ii);
            [betaT,~,flag] = linprog(f',[],[],A,B,lb,ub,[],opt);
            nb_interpretExitFlag(flag,'linprog',[' Quantile ' num2str(q(qq)) '.']);
            betaT          = betaT(end-N+1:end);
            beta(:,ii,qq)  = betaT;

        end
        
    end

end

%==========================================================================
function beta = qRegRestr(y,x,T,E,N,q,numQ,restr)
% If meadian regression is done this amount to least-absolute-
% deviations estimation, which means that the problem is symmetric

    opt  = optimset('display','off');
    beta = nan(N,E,numQ);
    O    = ones(T,1);
    I    = eye(T);
    lb   = [zeros(T*2,1);-inf*ones(N,1)];
    ub   = inf*ones(T*2 + N,1);
    for qq = 1:numQ
        
        for ii = 1:E

            r              = restr{ii};
            NT             = sum(double(r));
            f              = [q(qq)*O;(1-q(qq))*O;zeros(NT,1)];
            A              = [I,-I, x(:,r)];
            B              = y(:,ii);
            [betaT,~,flag] = linprog(f',[],[],A,B,lb,ub,[],opt);
            nb_interpretExitFlag(flag,'linprog',[' Quantile ' num2str(q(qq)) '.']);
            betaT          = betaT(end-N+1:end);
            beta(:,ii)     = betaT;

        end
        
    end

end

%==========================================================================
function [stdBeta,betaD] = sparsitySTD(x,res,q,draws)
% See https://support.sas.com/documentation/onlinedoc/stat/141/qreg.pdf
% Section Confidence Interval.
    
    n       = size(x,1);
    psi     = @(x)nb_distribution.normal_pdf(x,0,1);
    PSI     = @(x)nb_distribution.normal_icdf(x,0,1);
    h_n     = n^(-1/3)*(PSI(1 - 0.05/2))^(2/3)*((1.5*(psi(PSI(q)))^2)/(2*(PSI(q))^2 + 1))^(1/3);
    k       = median(abs(res));
    d_n     = k*(PSI(min(q + h_n,1-eps)) - PSI(max(q - h_n,eps)));
    I       = res >= -d_n & res <= d_n;
    xt      = x(I,:);
    D       = (1/(2*n*d_n))*(xt'*xt);
    I2      = double(res < 0);
    xI2     = bsxfun(@times,(q - I2).^2,x);
    A       = xI2'*x/n;
    invD    = eye(size(D,1))/D;
    OMG     = invD*A*invD;
    stdBeta = sqrt(diag(OMG)/n);
    betaD   = nb_mvnrand(draws,1,zeros(size(stdBeta')),OMG);
    betaD   = permute(betaD,[2,3,4,1]);
    
end
