function t = type(obj)
% Syntax:
%
% t = type(obj)
%
% Description:
%
% Get the MATLAB basic class the nb_macro object represent.
% 
% Input:
% 
% - obj : An object of class nb_macro.
% 
% Output:
% 
% - t   : If numel(obj) > 0: cellstr
%         else             : one line char
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if numel(obj) > 1
        t = nb_callMethod(obj,@type,'cell');
    else
        t = class(obj.value);
    end
    
end
