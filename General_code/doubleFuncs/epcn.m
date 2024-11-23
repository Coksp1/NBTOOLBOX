function dout = epcn(din,t,stripNaN)
% Syntax:
%
% dout = epcn(din,t)
% dout = epcn(din,t,stripNaN)
%
% Description:
%
% This function uses the standard growth formula as opposed to the log
% growth economist typically use.
%
% See also: 
% iepcn, egrowth, iegrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin<2
            t = 1;
        end
    end
    dout = egrowth(din,t,stripNaN)*100;
    
end
