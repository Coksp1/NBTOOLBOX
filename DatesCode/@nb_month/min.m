function d = min(obj,aObj)
% Syntax:
%
% d       = min(obj)
% [d,ind] = min(obj)
% d       = min(obj,aObj)
%
% Description:
%
% Find the min date.
% 
% Input:
% 
% One input:
%
% - obj  : A vector of nb_month objects.
%
% Two inputs:
%
% - obj  : A scalar nb_month object.
%
% - aObj : A scalar nb_month object.
% 
% Output:
% 
% - d    : A scalar nb_month object.
%
% - ind  : The index of the first date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        [~,ind] = min([obj.monthNr]);
        d       = obj(ind);
    else
        if nargout > 1
            error([mfilename ':: MIN with two dates to compare and two output arguments is not supported.'])
        end
        if obj < aObj
            d = obj;
        else
            d = aObj;
        end
    end
        
end
