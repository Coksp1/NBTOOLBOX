function obj = mtimes(obj1,obj2)
% Syntax:
%
% obj = mtimes(obj1,obj2)
%
% Description:
%
% Redirect to times, i.e. .* and * is the same operator.
% 
% See also:
% times
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = power(obj1,obj2);
    
end
