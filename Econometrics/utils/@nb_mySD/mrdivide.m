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
% - obj     : A scalar number, nb_param object, nb_mySD object or string.
%
% - another : A scalar number, nb_param object, nb_mySD object or string.
%  
% Output:
% 
% - obj     : An object of class nb_mySD.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = rdivide(obj,another);

end
