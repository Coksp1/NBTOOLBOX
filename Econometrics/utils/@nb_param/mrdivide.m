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
% - obj     : A scalar number, nb_param object or string.
%
% - another : A scalar number, nb_param object, nb_mySD object or string.
% 
% Output:
% 
% - obj     : An object of class nb_param or nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = rdivide(obj,another);

end
