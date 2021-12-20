function obj = mpower(obj,another)
% Syntax:
%
% obj = mpower(obj,another)
%
% Description:
%
% Power operator (^). This will call power (.^)!
% 
% Input:
% 
% - obj     : A scalar number, nb_param object, nb_mySD object or string.
%
% - another : A scalar number, nb_param object, nb_mySD object or string.
% 
% Output:
% 
% - obj     : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = power(obj,another);

end
