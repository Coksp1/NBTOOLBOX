function dout = epcn(din,t)
% Syntax:
%
% dout = epcn(din,t)
%
% Description:
%
% This function uses the standard growth formula as opposed to the log
% growth economist typically use.
%
% See also: 
% iepcn, egrowth, iegrowth
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin<2
        t=1;
    end
    dout = egrowth(din,t)*100;
    
end
