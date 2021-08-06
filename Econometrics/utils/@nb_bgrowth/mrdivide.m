function obj = mrdivide(obj,another)
% Syntax:
%
% obj = mrdivide(obj,another)
%
% Description:
%
% Right division operator (/), same as (./).
% 
% Input:
% 
% - another : A scalar number, nb_bgrowth object or string.
% 
% Output:
% 
% - obj     : An object of class nb_bgrowth.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = rdivide(obj,another);

end
