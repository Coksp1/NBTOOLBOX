function dout = egrowth(din,t,stripNaN)
% Syntax:
%
% dout = egrowth(din,t)
% dout = egrowth(din,t,stripNaN)
%
% Description:
%
% This function uses the standard growth formula as opposed to the log
% growth economist typically use.
%
% See also: 
% growth, iegrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin<2
            t = 1;
        end
    end
    if stripNaN
        dout  = din;
        isNaN = isnan(din);
        for vv = 1:size(din,2)
            for pp = 1:size(din,3)
                dinT    = din(~isNaN(:,vv,pp),vv,pp);
                doutT   = cat(1,nan(t,1,1),(dinT(t + 1:end)-dinT(1:end - t))./dinT(1:end - t));
                dout(~isNaN(:,vv,pp),vv,pp) = doutT;
            end
        end
    else
        [r,c,p] = size(din); %#ok<ASGLU>
        dout    = cat(1,nan(t,c,p),(din(t+1:end,:,:) - din(1:end-t,:,:))./din(1:end-t,:,:));
    end
    
end
