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
% - another : A scalar number, nb_bgrowth object or string.
% 
% Output:
% 
% - obj     : An object of class nb_bgrowth.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = times(obj,another);

end
