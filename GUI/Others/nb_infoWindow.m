function nb_infoWindow(message,name,scrollbox,resize,pos,windowStyle)
% Syntax:
%
% nb_infoWindow(message)
% nb_infoWindow(message,name,scrollbox,resize,pos,windowStyle)
%
% Description:
%
% A window for printing info messages
% 
% Input:
% 
% - message     : The wanted message to print
%
% - name        : Name of figure window
% 
% - scrollbox   : true or false. false is default.
%
% - resize      : 'on' or 'off'. 'off' is default.
%
% - pos         : A 1 x 4 double. Default is [50 40 100 20], also used if
%                 pos is empty ([]).
%
% - windowStyle : 'normal' or 'modal'. 'modal' is default.
% Output:
% 
% A GUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        windowStyle = 'modal';
        if nargin < 5
            pos = [];
            if nargin < 4
                resize = 'off';
                if nargin < 3
                    scrollbox = false;
                    if nargin < 2
                        name = '';
                    end
                end
            end
        end
    end
    
    if isempty(pos)
        pos = [50 40 100 20];
    end
    
    % Create the window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure(  'Visible',     'off',...
                 'Color',       defaultBackground,...
                 'units',       'characters',...
                 'position',    pos,...
                 'name',        name,...
                 'NumberTitle', 'off',...
                 'MenuBar',     'None',...
                 'Toolbar',     'None',...
                 'resize',      resize,...
                 'windowStyle', windowStyle,...
                 'dockControls','off',...
                 'tag','nb_infoWindow');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Print the info message
    if scrollbox
        nb_scrollbox( 'parent',         f,...
                  'background',         [1,1,1],...
                  'units',              'normalized',...
                  'position',           [0.04,0.04,0.92,0.92],...
                  'Style',              'text',...
                  'HorizontalAlignment','left',...
                  'String',             message);            
    else
        uicontrol('units',              'characters',...
                  'position',           [5,5,90,10],...
                  'parent',             f,...
                  'Style',              'text',...
                  'HorizontalAlignment','left',...
                  'String',             message);
    end

    % Make the window visible.
    set(f,'Visible','on');

end
