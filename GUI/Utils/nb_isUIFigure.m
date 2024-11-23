function ret = nb_isUIFigure(h)
% Syntax:
%
% ret = nb_isUIFigure(h)
%
% Description:
%
% Is the handle h a uifigure handle?
% 
% Input:
% 
% - h : Any
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = matlab.ui.internal.isUIFigure(h);

end
