function dout = iepcnnan(din,t,periods)
% Syntax: 
%
% - dout = iepcnnan(din,t,periods)
%
% Description:
%
% - Uses iepcn, but is robust for trailing and leading NaNs. It also
%   checks whether there is any NaNs in between observations in the 
%   double, and returns nan if this is the case. 
% 
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - t       : A double matrix with dimensions [r,c,p]. Initial values
% 
% - periods : The number of periods the din has been growthed over.
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% See also:
% epcn, iepcn
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end
    dout = iegrowthnan(din/100,t,periods);

end
