function uiHandle = nb_blankUIPanel(varargin)
% Syntax:
%
% uiHandle = nb_blankUIPanel(varargin)
%
% Description:
%
% Make blank uipanel.
% 
% Input:
% 
% - varargin : Optional inputs given to the uipanel function.
% 
% Output:
% 
% - uiHandle : A uipanel handle.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    uiHandle = uipanel(...
        'title',       '',...
        'borderType',  'none',... 
        'units',       'normalized',...
        varargin{:});

end
