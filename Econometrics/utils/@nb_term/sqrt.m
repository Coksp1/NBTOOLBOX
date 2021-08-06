function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% sqrt operator for nb_term objects.
% 
% Input:
% 
% - obj : A vector of nb_term objects.
%
% Output:
% 
% - obj : A vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:size(obj,1)
        obj(ii) = callPowerOnSub(obj(ii),nb_num(0.5));
        obj(ii) = clean(obj(ii));
    end
    
end
