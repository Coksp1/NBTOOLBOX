function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% log operator for nb_term objects.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:size(obj,1)
        obj(ii) = callLogOnSub(obj(ii));
        obj(ii) = clean(obj(ii));
    end
    
end
