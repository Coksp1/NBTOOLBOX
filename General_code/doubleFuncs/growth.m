function dout = growth(din,t,stripNaN)
% Syntax:
%
% dout = growth(din,t)
% dout = growth(din,t,stripNaN)
%
% Description:
%
% Calculate approx growth, using the formula: log(x(t))-log(x(t-1))
%
% See also:
% egrowth, igrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            t = 1;
        end
    end
    if stripNaN
        % Strip nan values before calculating the growth
        dout  = din;
        isNaN = isnan(din);
        for vv = 1:size(din,2)
            for pp = 1:size(din,3)
                dinT  = din(~isNaN(:,vv,pp),vv,pp);
                dinT  = log(dinT); 
                doutT = cat(1,nan(t,1,1),dinT(t+1:end)-dinT(1:end-t));
                dout(~isNaN(:,vv,pp),vv,pp) = doutT;
            end
        end
    else
        din  = log(din);
        dout = din - nb_lag(din,t);
    end
    dout(~isfinite(dout)) = nan;
    
end
