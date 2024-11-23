function x = nb_adjout(y,threshold,tFlag,W)
% Syntax:
%
% x = nb_adjout(y,threshold,tFlag,W)
%
% Description:
%
% Outlier replacement using fraction of inverse quantile function. 
% 
% See online appendix "Factor Models and Structural Vector Autoregressions 
% in Macroeconomics" by Stock and Watson (2016). This is a adjusted 
% version of theirs adjout. Handle 3 dimensional input, and added the
% W input. See the subfunction adjOutSub for a copy of their original
% function.
%
% Input:
% 
% - y         : A T x N x P double. May include nan values.
%
% - threshold : Treshold to use for the outliers. Default is 5.
%
% - tFlag     : 0 > Replace with missing value
%               1 > Replace with maximum or minimum value
%               2 > Replace with median value
%               3 > Replace with local median (obs + or - W on each side)
%               4 > Replace with one-sided median (W preceding obs).
%                   Default.
% 
% - W         : The window of the replacement calculations. See the
%               tFlag == 3 or 4 for more. Default is 5.
%
% Output:
% 
% - x         : A T x N x P double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        W = 5;
        if nargin < 3
            tFlag = 4;
            if nargin < 2
                threshold = 5;
            end
        end
    end

    x = y;
    for ii = 1:size(y,3)
        for jj = 1:size(y,2)
            x(:,jj,ii) = adjOutSub(y(:,jj,ii),threshold,tFlag,W);
        end
    end
    
end

%==========================================================================
function x = adjOutSub(y,threshold,tFlag,W)

    z       = y(~isnan(y));
    pct_vec = [0.25 0.50 0.75];
    tmp     = pctile(z,pct_vec);
    zm      = tmp(2);
    iqr     = tmp(3)-tmp(1);

    small = 1.0e-06;
    if iqr < small
        x = y;
    else
        ya  = abs(y-zm);
        iya = ya > (threshold*iqr);
        iyb = ya <= (threshold*iqr);

        if tFlag == 0
            x      = y;
            x(iya) = NaN;
        elseif tFlag == 1
            isign = y > 0;
            jsign = -(y < 0);
            isign = isign + jsign;
            yt    = (zm*ones(size(y,1),1)) + isign .* (threshold*iqr*ones(size(y,1),1));
            x     = (iyb .* y) + (iya .* yt);
        elseif tFlag == 2
            x = (iyb .* y) + (iya * zm);
        elseif tFlag == 3
            % Compute rolling median
            ymvec = NaN*zeros(size(y,1),1);
            for i = 1:size(y,1)
                j1       = max( [1;(i-W)] );
                j2       = min([size(y,1) ;(i+W)] );
                tmp      = y(j1:j2);
                tmp      = tmp(~isnan(tmp));
                ymvec(i) = median(tmp);
            end
            x = (iyb .* y) + (iya .* ymvec);
        elseif tFlag == 4
            % Compute rolling median;
            ymvec = NaN*zeros(size(y,1),1);
            for i = 1:size(y,1)
                j1       = max( [1;(i-W)] );
                j2       = i;
                tmp      = y(j1:j2);
                tmp      = tmp(~isnan(tmp));
                ymvec(i) = median(tmp);
            end
            x = (iyb .* y) + (iya .* ymvec);
        end

    end

end

%==========================================================================
function xpct = pctile(x,pct)
    x    = sort(x);
    pct  = ceil(pct*size(x,1));
    xpct = x(pct);
end
