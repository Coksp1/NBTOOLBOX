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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    xout = sum([xin,nb_mlag(xin,3)],2);
    
end
