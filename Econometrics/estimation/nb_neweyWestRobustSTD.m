function stdBeta = nb_neweyWestRobustSTD(x,u,xpxi,restr)
% Syntax:
%
% stdBeta = nb_neweyWestRobustSTD(x,residual)
%
% Description:
%
% Estimation of Newey-West heteroscedasticity and autocorrelation robust 
% standard errors.
%
% See page 36 of Eviews User's Guide 2.
% 
% Input:
%
% - x        : The regressors of the equation, as a nobs x nvar
%                    double.
%
% - u        : Residual from regression, as a nobs x neq double.
%
% - xpxi     : (x'x)^-1. If not given it will be calculated.
%
% - restr    : A 1 x neq where each element is a 1 x nxvar + extra logical.  
%              Where extra is 0, 1 or 2 dependent on the constant and/or 
%              time trend is included. Each logical element must be true 
%              to include in the regression equation of the corresponding 
%              equation.
%
% Output:
% 
% - stdBeta  : Std as a nvar x neq double.
%
% Written by Kenneth Sæterhagen Paulsen
   
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        restr = '';
        if nargin < 3
            xpxi = [];
        end
    end
    
    T         = size(u,1);
    E         = size(u,2);
    K         = @nb_bartlettKernel;
    bandWidth = floor(4*((T/100)^(2/9)));
    if ~isempty(restr)
        restrV = [restr{:}];
        N      = length(restrV);
    else
        N = size(x,2);
        n = N/E;
    end
    
    % Vectorize here??
    U     = u;
    X     = x;
    SIGMA = zeros(N,N);
    indS  = 1;
    for ii = 1:E
    
        if ~isempty(restr)
            n = sum(restr{ii});
        end
        indXS  = T*(ii-1) + 1;
        indXE  = indXS + T - 1;
        indE   = indS + n - 1;
        ind    = indS:indE;
        SIGMAT = 0;
        x      = X(indXS:indXE,ind);
        u      = U(:,ii);
        for v = 0:bandWidth-1

            gamma = 0;
            for t = v+1:T
                if v == 0
                    gamma = gamma + (u(t))^2*x(t,:)'*x(t,:);
                else
                    gamma = gamma + 2*u(t)*u(t-v)*x(t,:)'*x(t-v,:);
                end
            end
            SIGMAT = SIGMAT + K(v/bandWidth)*gamma;

        end
        SIGMAT         = T/(T-n)*SIGMAT;
        SIGMA(ind,ind) = SIGMAT;
        
        indS = indS + n;
        
    end
    
    % Calculate (x'x)^-1
    if isempty(xpxi)
        
        if T < 10000
            [~, r] = qr(x,0);
            xpxi   = (r'*r)\eye(N*E);
        else % use Cholesky for very large problems
            xpxi = (x'*x)\eye(N*E);
        end
        
    end
    
    % Get the estimated STD
    stdBeta = sqrt((T/(T - N))*diag(xpxi*SIGMA*xpxi));
    if isempty(restr)
        stdBeta = reshape(stdBeta,n,E);
    end

end

%==========================================================================
% SUB
%==========================================================================
% function xout = createLags(xin,bandWidth,T)
% 
%     xout              = nb_mlag(xin,bandWidth - 1,'varFast');
%     xout              = [xin,xout];
%     xout(isnan(xout)) = 0;
%     xout              = reshape(xout,[T,size(xin,2),bandWidth]);
%     
% end
