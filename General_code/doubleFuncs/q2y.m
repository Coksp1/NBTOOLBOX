function xout = q2y(xin)
% Syntax:
%
% xout = q2y(xin)
%
% Description:
%
% Transform quarterly to annual, using sum over the last 4 periods.
%
% See also: 
% growth
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    xout = sum([xin,nb_mlag(xin,3)],2);
    
end
