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
% - obj     : An object of class nb_eq2Latex, scalar double or string.
%
% - another : An object of class nb_eq2Latex, scalar double or string.
%   
% Output:
% 
% - obj     : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = power(obj,another);

end
