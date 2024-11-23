function y = hpfilter(x,lamb,perc,fcstLen)
% Syntax:
% 
% y = hpfilter(x,lamb)
% y = hpfilter1s(x,lamb,perc,fcstLen)
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
% - perc     : Set to true to calculate the gap as (gap/trend)*100.
%
% - fcstLen  : The forecast length. Extrapolates the original series
%              using the average of the last 4 periods. Default is 0.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        fcstLen = 0;
        if nargin < 3
            perc = false;
        end
    end

    % Check for nan
    [r,c,p] = size(x);
    isNaN   = ~isfinite(x);
    if any(isNaN(:))
        y = x;
        for cc = 1:c
            for pp = 1:p
                good          = isfinite(x(:,cc,pp));
                y(good,cc,pp) = hpfilter(x(good,cc,pp),lamb,perc,fcstLen);
            end
        end
        return
    end
    
    if fcstLen > 0 
        r = r + fcstLen;
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
    if fcstLen > 0 
        for ii = 1:p
            xt        = x(:,:,ii);
            fcst      = mean(xt(end-3:end,:),1);
            xt        = [xt;fcst(ones(fcstLen,1),:)];  %#ok<AGROW>
            yt        = A*xt ; 
            y(:,:,ii) = yt(1:end-fcstLen,:); 
        end
    else
        for ii = 1:p
            y(:,:,ii) = A*x(:,:,ii) ;
        end
    end
    
    if perc
        t = x - y; 
        y = (y./t)*100;
    end
    
end
