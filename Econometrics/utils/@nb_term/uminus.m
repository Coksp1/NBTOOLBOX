function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Uniary minus operator (-) for nb_term objects.
% 
% Input:
% 
% - obj : A vector of nb_term objects.
%
% Output:
% 
% - obj : A vector of nb_term object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:size(obj,1)
        obj(ii) = callTimesOnSub(nb_num(-1),obj(ii));
    end

end
