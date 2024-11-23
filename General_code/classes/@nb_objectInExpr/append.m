function obj = append(obj,aObj,~)
% Syntax:
%
% obj = append(obj,aObj)
% obj = append(obj,aObj,priority)
%
% Description:
%
% Append aObj to obj with a given priority.
% 
% Input:
% 
% - obj      : A nb_objectInExpr object.
%
% - aObj     : A nb_objectInExpr object.
%
% - priority : 'first' or 'second'. If 'first' all the observation fra obj
%              is used before the observations from aObj, otherwise it is
%              reverse. 'first' is default.
% 
% Output:
% 
% - obj      : A nb_objectInExpr object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % In this case we take max!
    obj = compareMax(obj,aObj);

end
