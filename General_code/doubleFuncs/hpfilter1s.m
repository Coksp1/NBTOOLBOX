function y = hpfilter1s(x,lamb)
% Syntax:
% 
% y = hpfilter1s(x,lamb)
% 
% Description:
% 
% One sided Hodrick-Prescott filter. Handle nan.
% 
% Input:
% 
% - x        : A timeseries, as a nobs x nvars x npage double.
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
% See also:
% hpfilter
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
                temp       = hpfilter(tempData,lamb);
                y(l,cc,pp) = temp(end);
                l          = l + 1;
            end
            
        end

    end

end

