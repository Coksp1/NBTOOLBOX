function dout = pcn(din,t,stripNaN)
% Syntax:
%
% dout = pcn(din,t)
% dout = pcn(din,t,stripNaN)
%
% Description:
%
% Calculate approx growth, using the formula: 100*(log(x(t))-log(x(t-1)))
%
% See also:
% growth, growth, ipcn
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            t = 1;
        end
    end
    dout = growth(din,t,stripNaN)*100;
    
end
