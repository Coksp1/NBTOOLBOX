function y = nb_linearFilter1s(x)
% Syntax:
% 
% y = nb_linearFilter1s(x)
% 
% Description:
% 
% One sided "linear" filter
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
                temp       = nb_linearFilter(tempData);
                if l == f + 4
                    y(1:l,cc,pp) = temp;
                else
                    y(l,cc,pp) = temp(end);
                end
                l = l + 1;
            end
            
        end

    end
    
end
