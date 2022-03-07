function y = nb_linearFilter(x)
% Syntax:
% 
% y = nb_linearFilter(x)
% 
% Description:
% 
% Linear filter
% 
% Input:
% 
% - x : A double storing timeseries.
%
% Output:
% 
% - y : The cyclical component of the x-series
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create a nobs*(nvar*npage)*1 matrix 
    [r,c,p]  = size(x);
    dat      = reshape(x,r,c*p,1);
    isNaN    = ~isfinite(dat);
    isNotNaN = ~isNaN;
    
    % Estimate the linear trend
    trendDummy = 1:r;
    trendDummy = trendDummy';
    constant   = 1;
    if any(isNaN(:))
        
        gap = dat;
        for ii = 1:size(dat,2)
            isNotNaNT = isNotNaN(:,ii);
            beta      = nb_ols(dat(isNotNaNT,ii),trendDummy(isNotNaNT),constant);
            trend     = trendDummy*beta(2) + beta(1);
            gap(:,ii) = dat(:,ii) - trend;
        end
        
    else  
        beta       = nb_ols(dat,trendDummy,constant);
        const      = repmat(beta(1,:,:),r,1);
        beta       = repmat(beta(2,:,:),r,1);
        trendDummy = repmat(trendDummy,1,c*p);
        trend      = trendDummy.*beta + const;
        gap        = dat - trend;
    end

    % Reshape the matrix back again
    y  = reshape(gap,r,c,p);
    
end
