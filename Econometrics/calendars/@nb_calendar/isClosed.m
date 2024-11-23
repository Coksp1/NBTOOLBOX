function ret = isClosed(obj)
% Syntax:
%
% ret = isClosed(obj)
%
% Description:
%
% Is the clandar closed or not.
% 
% Input:
% 
% - obj : A 1 x N vector of objects of class nb_calendar.
% 
% Output:
% 
% - ret : A 1 x N logical vector.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        ret = nb_callMethod(obj,@isClosed,'logical');
        return
    end
    ret = obj.closed;

end
