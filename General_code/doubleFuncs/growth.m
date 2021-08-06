function dout = growth(din,t)
% Syntax:
%
% dout = growth(din,t)
%
% See also:
% egrowth, igrowth
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin < 2
        t = 1;
    end
    din  = log(din);
    dout = din - lag(din,t);
    
end
