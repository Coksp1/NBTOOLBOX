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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = power(obj1,obj2);
    
end
