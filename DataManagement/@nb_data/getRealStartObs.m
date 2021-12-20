function realStartObs = getRealStartObs(obj,type)
% Syntax:
%
% realStartObs = getRealStartObs(obj)
% realStartObs = getRealStartObs(obj,format,type)
%
% Description:
%
% Get the real start obs of the nb_data object. I.e the first 
% observation which is not nan or infinite. 
% 
% Input:
% 
% - obj          : An object of class nb_data
%
% - type         : Either 'any' (default) or 'all'.
% 
% Output:
% 
% - realStartObs : The first observation of the object which is 
%                   not nan or infinite. As a double
%
% Examples:
%
% realStartObs = obj.getRealStartObs();
% realStartObs = obj.getRealStartObs('all');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'any';
    end

    isFinite = isfinite(obj.data);
    if strcmpi(type,'all')
        isFinite = all(all(isFinite,2),3);
    else
        isFinite = any(any(isFinite,2),3);
    end
    first        = find(isFinite,1);
    realStartObs = obj.startObs + first - 1;

end
