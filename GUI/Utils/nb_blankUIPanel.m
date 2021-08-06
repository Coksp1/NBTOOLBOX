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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    uiHandle = uipanel(...
        'title',       '',...
        'borderType',  'none',... 
        'units',       'normalized',...
        varargin{:});

end
