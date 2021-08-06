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
% - obj     : An object of class nb_eq2Latex, scalar double or string.
%
% - another : An object of class nb_eq2Latex, scalar double or string.
%  
% Output:
% 
% - obj     : An object of class nb_eq2Latex.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = rdivide(obj,another);

end
