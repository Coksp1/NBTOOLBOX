function stdBeta = nb_homoOnlySTD(x,u,xpxi,restr)
% Syntax:
%
% stdBeta = nb_homoOnlySTD(x,residual)
%
% Description:
%
% Estimation of homoscedasticity only standard errors.
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

    T = size(u,1);
    E = size(u,2);
    
    % Calculate (x'x)^-1
    if isempty(xpxi)
        
        if T < 10000
            [~, r] = qr(x,0);
            xpxi   = (r'*r)\eye(size(r,1));
        else % use Cholesky for very large problems
            xpxi = (x'*x)\eye(size(x,1));
        end
        
    end
    
    % Get the estimated STD
    if ~isempty(restr)
        
        % Calculate covariance matrix
        sigu  = diag(u'*u)';
        s     = 1;
        tmp   = diag(xpxi);
        for ii = 1:E
            N            = sum(restr{ii});
            sige         = sigu(ii)/(T-N);
            tmp(s:s+N-1) = tmp(s:s+N-1)*sige;
            s            = s + N;
        end
        
    else
        
        % Calculate covariance matrix
        N    = size(x,2)/E;
        sigu = diag(u'*u)';
        sige = sigu/(T-N);
        tmp  = repmat(sige,N,1).*(reshape(diag(xpxi),N,E));
        
    end
    stdBeta = sqrt(tmp);

end
