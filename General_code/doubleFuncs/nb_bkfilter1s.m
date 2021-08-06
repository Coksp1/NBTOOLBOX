function x = nb_bkfilter1s(y,low,high)
% Syntax:
%
% x = nb_bkfilter1s(y,low,high)
%
% Description:
%
% One sided band-pass filter. For more on the filter see nb_bkfilter. 
% Handle nan values.
%
% Inputs:
%
% - y    : A timeseries, as a nobs x nvars x npage double.
%
% - low  : Lowest frequency. > 2
%
% - high : Highest frequency. > low
%   
% Output:
%
% - x : Double (nobs x 1 x npage) containing filtered data 
%   
% See also:
% nb_bkfilter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if high <= low
        error([mfilename ':: the lowest frequency cannot be be higher than the highest frequency.'])
    end
    if low < 2
        error([mfilename ':: the lowest frequency cannot be be less than 2.'])
    end
    
    [r,c,p] = size(y);
    x       = nan(r,c,p);
    for cc = 1:c

        for pp = 1:p
        
            % Find first finite observation 
            isFin = isfinite(y(:,cc,pp));
            f     = find(isFin,1);

            % Need at least 5 observation 
            l = f + 4;

            % Do the one sided filter
            while l <= r
                tempData   = y(f:l,cc,pp);
                isF        = isFin(f:l);
                tempData   = tempData(isF);
                temp       = nb_bkfilter(tempData,low,high);
                x(l,cc,pp) = temp(end);
                l          = l + 1;
            end
            
        end

    end
    
end
