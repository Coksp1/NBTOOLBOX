function obj = nb_scrollbox(varargin)
% Syntax:
%
% obj = nb_scrollbox(varargin)
%
% Description:
%
% Display text with vertical and horizontal scrollbars
% 
% Input:
% 
% - See uicontrol
% (Style, Min, Max and Value are overriden)
% 
% Output:
% 
% - See uicontrol
%
% Examples:
%
% f  = figure
% ui = nb_scrollbox(...
%                'units','normal',...
%                'position',[0.1,0.1,0.8,0.8],...
%                'parent',f,...
%                'string','Some long string')
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create a MATLAB uicontrol object
    obj = uicontrol(...
        'HorizontalAlignment','left',...
        'background',[1,1,1],varargin{:});
    
    % Listboxes automatically add vertical and
    % horizontal scrollbars when needed
    set(obj, 'Style', 'listbox');
    
    % Enable selection of multiple lines
    set(obj, 'Min', 0);
    set(obj, 'Max', 100);
    
    % Deselect all lines
    set(obj, 'Value', []);

end
