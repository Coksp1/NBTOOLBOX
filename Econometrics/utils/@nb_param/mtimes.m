function obj = mtimes(obj,another)
% Syntax:
%
% obj = mtimes(obj,another)
%
% Description:
%
% Times operator (*). Here assumed equal to .* operator.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = times(obj,another);

end
