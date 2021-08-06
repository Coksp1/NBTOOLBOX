function y = hpfilter(x,lamb)
% Syntax:
% 
% y = hpfilter(x,lamb)
% 
% Description:
% 
% Hodrick-Prescott filter. Handle nan.
%
% See page 3 of Cornea-Madeira (2016), "The Explicit Formula for the 
% Hodrick-Prescott Filter in Finite Sample".
% 
% Input:
% 
% - x        : A timeseries, as a nobs x 1 x npage double.
% 
% - lamb     : The lambda of the hp-filter
% 
% Output:
% 
% - y        : The cyclical component of the x-series
% 
% Examples:
% 
% y = hpfilter(x,400);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check for nan
    [r,c,p] = size(x);
    isNaN   = ~isfinite(x);
    if any(isNaN(:))
        y = x;
        for cc = 1:c
            for pp = 1:p
                good          = ~isnan(x(:,cc,pp));
                y(good,cc,pp) = hpfilter(x(good,cc,pp),lamb);
            end
        end
        return
    end

    a = zeros(r,r);
    for i=3:r-2
        a(i,i)   = 6*lamb + 1;
        a(i,i+1) = -4*lamb;
        a(i,i+2) = lamb;
        a(i,i-2) = lamb;
        a(i,i-1) = -4*lamb;
    end
    a(2,2)     = 1 + 5*lamb;
    a(2,3)     = -4*lamb;
    a(2,4)     = lamb;
    a(2,1)     = -2*lamb;
    a(1,1)     = 1 + lamb;
    a(1,2)     = -2*lamb;
    a(1,3)     = lamb ;
    a(r-1,r-1) = 5*lamb + 1;
    a(r-1,r)   = -2*lamb;
    a(r-1,r-2) = -4*lamb;
    a(r-1,r-3) = lamb;
    a(r,r)     = 1 + lamb;
    a(r,r-1)   = -2*lamb;
    a(r,r-2)   = lamb;
    
    I = eye(r);
    A = (I - I/a);
    y = x;
    for ii = 1:p
        y(:,:,ii) = A*x(:,:,ii) ;
    end
    
end

