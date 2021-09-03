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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = power(obj1,obj2);
    
end