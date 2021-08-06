function obj = sgrowth(obj,horizon)
% Syntax:
%
% obj = sgrowth(obj,horizon)
%
% Description:
%
% Calculates smoothened 12 or 6 months growth.
% x(*) = ((x13+x14+x15)/(x1+x2+x3)-1)*100 
% x(*) = ((x7+x8+x9)/(x1+x2+x3)-1)*100 
%
% Note: Works only for monthly data.
%
% Based on Anne Sofie Jores data transformation code.
%
% Input:
%
% - obj     : A nb_math_ts object
%
% - horizon : Either 1 or 2, depending on the frequency you want your
%            growth to be caluclated over. 1 is annual and 2 i semi-annual.
%
% Output:
% - out    : A nb_math_ts object.
% 
%
% Examples:
% 
% See also:
%
% nb_sgrowth
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        horizon = [];
    end
    if obj.frequency ~= 12
        error([mfilename ':: This function onlt work on monthly data.'])
    end
    obj.data = nb_sgrowth(obj.data,horizon);

end
