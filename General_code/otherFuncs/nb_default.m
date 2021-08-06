function value = nb_default(value, default)
% Syntax:
%
% value = nb_default(value, default)
%
% Description:
%
% Return default if value is empty.
% 
% Input:
% 
% - value   : Any type.
%
% - default : Any type.
% 
% Output:
% 
% - value = Either value or default.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(value)
        value = default;
    end
    
end
