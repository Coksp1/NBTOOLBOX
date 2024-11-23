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
% - obj     : An object of class nb_eq2Latex, scalar double or string.
%
% - another : An object of class nb_eq2Latex, scalar double or string.
%   
% Output:
% 
% - obj     : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = times(obj,another);

end
