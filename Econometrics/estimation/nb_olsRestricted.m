function [beta,stdBeta,tStatBeta,pValBeta,residual,x] = nb_olsRestricted(y,x,restr,constant,timeTrend,stdType)
% Syntax:
%
% beta = nb_ols(y,x)
% [beta,stdBeta,tStatBeta,pValBeta,residual,x] = ...
%            nb_olsRestricted(y,x,restrictions,constant,timeTrend)
%
% Description:
%
% Estimate multiple (unrelated) equations using ols.
%
% y = X*beta + residual, residual ~ N(0,residual'*residual/nobs) (1)
%
% Input:
% 
% - y        : A double matrix of size nobs x neq of the dependent 
%              variable of the regression(s).
%
% - x        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression.
%
% - restr    : A 1 x neq cell where each element is a 1 x nxvar + extra   
%              logical. Where extra is 0, 1 or 2 dependent on the constant 
%              and/or time trend is included. Each logical element must be  
%              true to include in the regressor in the corresponding 
%              equation.
%              
% - constant : If a constant is wanted in the estimation. Will be
%              added first in the right hand side variables. Default is
%              false.
% 
% - timeTrend : If a linear time trend is wanted in the estimation. 
%               Will be added first/second in the right hand side 
%               variables. (First if constant is not given, else 
%               second). Default is false.
%
% - stdType   : - 'w'    : Will return White heteroskedasticity
%                          robust standard errors. 
%               - 'nw'   : Will return Newey-West heteroskedasticity
%                          and autocorrelation robust standard errors.
%                          
%                          To estimate the covariance matrix of the
%                          estimated parameters the bartlett kernel is 
%                          used with the bandwidth set to 
%                          floor(4(T/100)^(2/9)) as Eviews also uses.
%
%               - 'h'    : Will return homoskedasticity only
%                          robust standard errors. Default.
%
% Output: 
% 
% - beta       : A (extra + nxvar) x neq matrix with the estimated 
%                parameters. Where extra is 0, 1 or 2 dependent
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
% - x          : Regressors including constant and time-trend. If more 
%                than one equation this will be given as kron(I,x), and
%                then the block restrictions is applied to this matrix.
% 
% See also
% nb_olsEstimator, nb_singleEq 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        stdType = 'h';
        if nargin < 5
            timeTrend = 0;
            if nargin < 4
                constant = 0;
            end
        end
    end
    
    % Concatenate restrictions
    restrC = [restr{:}];
    
    if isempty(x)
        sizeX = size(y,1);
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
    
    % Stack the equations (if needed)
    if E > 1
        y = y(:);
        x = kron(eye(E),x);
    end
    
    % Remove the variables restricted to be zero
    x = x(:,restrC);
    
    % Estimate the model by OLS
    if T < 10000
        [~, r] = qr(x,0);
        xpxi   = (r'*r)\eye(size(r,1));
    else % use Cholesky for very large problems
        xpxi = (x'*x)\eye(size(x,2));
    end
    betaStacked = xpxi*(x'*y);
    beta        = expandToFull(betaStacked,restrC,N,E);
    
    % Standard deviation of the estimated paramteres (beta)
    if nargout > 1
        
        resid = y - x*betaStacked;
        resid = reshape(resid,T,E);
        switch lower(stdType)
            
            case 'nw'
            
                % Newey-West heteroskedasticity and autocorrelation robust 
                % standard errors
                stdBetaStacked = nb_neweyWestRobustSTD(x,resid,xpxi,restr);
                
            case 'w'
                
                % White heteroskedasticity robust standard errors
                stdBetaStacked = nb_whiteRobustSTD(x,resid,xpxi,restr);

            otherwise
                
                % Standard OLS estimator
                stdBetaStacked = nb_homoOnlySTD(x,resid,xpxi,restr);
               
        end
        stdBeta = expandToFull(stdBetaStacked,restrC,N,E);
        
    end
    
    % t-statistics
    if nargout > 2 
        tStatBetaStacked = betaStacked./stdBetaStacked;
        tStatBeta        = expandToFull(tStatBetaStacked,restrC,N,E);
    end
    
    % p-values
    if nargout > 3
        try
            pValBetaStacked = nb_tStatPValue(tStatBetaStacked,T-N);
        catch %#ok<CTCH>
           error('t-statistic not valid. Probably due to colinearity or missing observations?!') 
        end
        pValBeta = expandToFull(pValBetaStacked,restrC,N,E);
    end
    
    if nargout > 4
        residual = resid;
    end
    
end

%==========================================================================
function x = expandToFull(xStacked,restr,N,E)

    x        = zeros(N*E,1);
    x(restr) = xStacked;
    x        = reshape(x,N,E);

end
