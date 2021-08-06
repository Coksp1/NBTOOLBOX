function dout = pcn(din,t)
% Syntax:
%
% dout = pcn(din,t)
%
% See also:
% growth, growth, ipcn
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<2
        t=1;
    end
    dout = growth(din,t)*100;
    
end
