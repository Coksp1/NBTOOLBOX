function stdBeta = nb_whiteRobustSTD(x,u,xpxi,restr)
% Syntax:
%
% stdBeta = nb_whiteRobustSTD(x,residual)
%
% Description:
%
% Estimation of White heteroscedasticity robust standard errors.
%
% See page 35 of Eviews User's Guide 2.
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
   
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        restr = '';
        if nargin < 3
            xpxi = [];
        end
    end

    T     = size(u,1);
    E     = size(u,2);
    
            
    % Calculate covariance matrix
    if ~isempty(restr)
        restrV = [restr{:}];
        N      = length(restrV);
    else
        N = size(x,2);
        n = N/E;
    end
    
    u2   = u.^2;
    uRM  = zeros(T*E,N);
    indS = 1;
    for ii  = 1:E
        if ~isempty(restr)
            n = sum(restr{ii});
        end
        indE  = indS + n - 1;
        indXS = T*(ii-1) + 1;
        indXE = indXS + T - 1;
        uRM(indXS:indXE,indS:indE) = repmat(u2(:,ii),1,n);
        indS  = indS + n;
    end
    u2x   = uRM.*x;
    SIGMA = u2x'*x;
    
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
