function obj = mpower(obj1,obj2)
% Syntax:
%
% obj = mpower(obj1,obj2)
%
% Description:
%
% Redirect to power, i.e. .^ and ^ is the same operator.
% 
% See also:
% power
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = power(obj1,obj2);
    
end
