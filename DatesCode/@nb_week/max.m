function d = max(obj,aObj)
% Syntax:
%
% d       = max(obj)
% [d,ind] = max(obj)
% d       = max(obj,aObj)
%
% Description:
%
% Find the max date.
% 
% Input:
% 
% One input:
%
% - obj  : A vector of nb_week objects.
%
% Two inputs:
%
% - obj  : A scalar nb_week object.
%
% - aObj : A scalar nb_week object.
% 
% Output:
% 
% - d    : A scalar nb_week object.
%
% - ind  : The index of the last date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        [~,ind] = max([obj.weekNr]);
        d       = obj(ind);
    else
        if nargout > 1
            error([mfilename ':: MAX with two dates to compare and two output arguments is not supported.'])
        end
        if obj > aObj
            d = obj;
        else
            d = aObj;
        end
    end
        
end
