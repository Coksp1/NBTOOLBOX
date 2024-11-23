function dout = nb_cumpcn(din,skipNaN)
% Syntax:
%
% dout = nb_cumpcn(din)
% dout = nb_cumpcn(din,skipNaN)
%
% Description:
%
% Calculate cumulative approx growth, using the formula: 
% 100*(log(x(t))-log(x(0)))
%
% See also:
% pcn, nb_icumpcn
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        skipNaN = 0;
    end
    dout = nb_cumgrowth(din,skipNaN)*100;
    
end
