function nb_confirmWindow(message,callbackfuncNo,callbackfuncYes,...
                          nameOfWindow,buttonNo,buttonYes)
% Syntax:
%
% nb_confirmWindow(message,callbackfuncNo,callbackfuncYes,...
%                           nameOfWindow,buttonNo,buttonYes)
%
% Description:
%
% A window for printing confimation messages.
%
% Possible answars is yes and no.
% 
% Input:
% 
% - message         : The question to ask
%
% - callbackfuncNo  : The callback function handle to be called if 
%                     answering no. Can also be a cell.
%
% - callbackfuncYes : The callback function handle to be called if 
%                     answering yes. Can also be a cell.
% 
% Output:
% 
% - ret     : 1 if answer is yes, otherwise 0. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        buttonNo = 'No';
        if nargin < 5
            buttonYes = 'Yes';
            if nargin < 4
                nameOfWindow = 'Warning';
            end
        end
    end

    % Create the window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('Visible',     'off',...
               'units',       'characters',...
               'position',    [50 40 100 20],...
               'name',        nameOfWindow,...
               'NumberTitle', 'off',...
               'MenuBar',     'None',...
               'Toolbar',     'None',...
               'resize',      'off',...
               'windowStyle', 'modal',...
               'Color',       defaultBackground);
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Print question message
    htext = uicontrol('parent',             f,...
                      'units',              'normalized',...
                      'position',           [0.04 0.25 0.96 0.4],...
                      'Style',              'text',...
                      'HorizontalAlignment','left',...
                      'String',             message);

    % Push buttons to give an answer
    %--------------------------------------------------------------
    bHeight = 0.1;
    bWidth  = 0.15;
    space   = 0.1;
    start   = (1 - bWidth*2 - space)/2;
    ySpace  = 0.1;
    
    pbh1 = uicontrol(f,...
                     'units',       'normalized',...
                     'position',    [start + bWidth + space,ySpace,bWidth,bHeight],...
                     'callback',    callbackfuncNo,...
                     'String',      buttonNo,...
                     'Style',       'pushbutton');
    
    pbh2 = uicontrol(f,...
                     'units',       'normalized',...
                     'position',    [start,ySpace,bWidth,bHeight],...
                     'callback',    callbackfuncYes,...
                     'String',      buttonYes,...
                     'Style',       'pushbutton');
                 
    %Make the GUI visible.
    %--------------------------------------------------------------
    set(f,'Visible','on');             
    
end
