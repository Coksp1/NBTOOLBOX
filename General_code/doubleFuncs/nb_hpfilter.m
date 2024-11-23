function tau = nb_hpfilter(y,alpha)
% Syntax:
% 
% tau = nb_hpfilter(y,alpha)
% 
% Description:
% 
% Hodrick-Prescott filter. Handle nan.
% 
% This is slower than the hpfilter function.
%
% See the "The exact weights of the HP filter" section in  Cornea-Madeira 
% (2016), "The Explicit Formula for the Hodrick-Prescott Filter in 
% Finite Sample".
%
% Input:
% 
% - x        : A time-series, as a nobs x 1 x npage double.
% 
% - alpha    : The smootheness parameter of the hp-filter.
% 
% Output:
% 
% - y        : The cyclical component of the y-series.
% 
% Examples:
% 
% tau = nb_hpfilter(y,400);
%
% See also:
% hpfilter
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check for nan
    [n,c,p] = size(y);
    isNaN   = ~isfinite(y);
    if any(isNaN(:))
        tau = y;
        for cc = 1:c
            for pp = 1:p
                good            = ~isnan(y(:,cc,pp));
                tau(good,cc,pp) = nb_hpfilter(y(good,cc,pp),alpha);
            end
        end
        return
    end
    
    % Calculate HP-filter weights
    n1        = n + 1;
    jj        = 1:n;
    lambda    = 1 + alpha*(2 - 2*cos((pi.*jj)./n1)).^2;
    lambdainv = 1./lambda;

    ii   = 1:n;
    jj   = 1:n;
    iijj = bsxfun(@times,ii,jj');
    T    = sqrt(2/n1).*sin((pi*iijj)./n1);
    
    term1 = sum(((2*T(1,1:2:end) - T(2,1:2:end)).^2).*lambdainv(1:2:end));
    term2 = sum(((2*T(1,2:2:end) - T(2,2:2:end)).^2).*lambdainv(2:2:end));
    k1    = 2*alpha/(1 - 2*alpha*term1);
    k2    = 2*alpha/(1 - 2*alpha*term2);

    K1          = zeros(n,n);
    ind         = 1:2:n;
    K1(ind,ind) = bsxfun(@times,2*T(ii(ind),1) - T(ii(ind),2),(2*T(1,jj(ind)) - T(2,jj(ind))))./bsxfun(@times,lambda(ii(ind)),lambda(jj(ind))');

    K2          = zeros(n,n);
    ind         = 2:2:n;
    K2(ind,ind) = bsxfun(@times,2*T(ii(ind),1) - T(ii(ind),2),(2*T(1,jj(ind)) - T(2,jj(ind))))./bsxfun(@times,lambda(ii(ind)),lambda(jj(ind))');

    % Calcualte the HP-trend
    A   = eye(n) - T*(diag(lambdainv) + k1*K1 + k2*K2)*T;
    tau = y;
    for ii = 1:size(y,3)
        tau(:,:,ii) = A*y(:,:,ii) ;
    end
    
end
