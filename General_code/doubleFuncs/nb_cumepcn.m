function dout = nb_cumepcn(din,stripNaN)
% Syntax:
%
% dout = nb_cumepcn(din)
% dout = nb_cumepcn(din,stripNaN)
%
% Description:
%
% Calculate percentage cumulative growth, using the formula:
% 100'((x(t)-x(0))/x(t))
%
% See also:
% epcn, nb_icumepcn
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        stripNaN = false;
    end
    dout = nb_cumegrowth(din,stripNaN)*100;
    
end
