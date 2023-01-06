function y = hpfilter1s(x,lamb,perc,fcstLen)
% Syntax:
% 
% y = hpfilter1s(x,lamb)
% y = hpfilter1s(x,lamb,perc,fcstLen)
% 
% Description:
% 
% One sided Hodrick-Prescott filter. Handle nan.
% 
% Input:
% 
% - x        : A timeseries, as a nobs x nvars x npage double.
% 
% - lamb     : The lambda of the hp-filter.
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
% See also:
% hpfilter
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        fcstLen = 0;
        if nargin < 3
            perc = false;
        end
    end

    [r,c,p] = size(x);
    y       = nan(r,c,p);
    for cc = 1:c

        for pp = 1:p
        
            % Find first finite observation 
            isFin = isfinite(x(:,cc,pp));
            f     = find(isFin,1);

            % Need at least 5 observation 
            l = f + 4;

            % Do the one sided filter
            while l <= r
                tempData   = x(f:l,cc,pp);
                isF        = isFin(f:l);
                tempData   = tempData(isF);
                if fcstLen > 0
                    fcst     = mean(tempData(end-3:end));
                    tempData = [tempData;fcst(ones(fcstLen,1),1)]; %#ok<AGROW>
                end
                temp = hpfilter(tempData,lamb);
                if fcstLen > 0
                    tempData = tempData(1:end-fcstLen); %#ok<NASGU>
                end
                y(l,cc,pp) = temp(end);
                l          = l + 1;
            end
            
        end

    end
    
    if perc
        t = x - y; 
        y = (y./t)*100;
    end
    
end
