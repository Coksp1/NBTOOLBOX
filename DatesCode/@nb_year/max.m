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
% - obj  : A vector of nb_year objects.
%
% Two inputs:
%
% - obj  : A scalar nb_year object.
%
% - aObj : A scalar nb_year object.
% 
% Output:
% 
% - d    : A scalar nb_year object.
%
% - ind  : The index of the last date.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin == 1
        [~,ind] = max([obj.yearNr]);
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