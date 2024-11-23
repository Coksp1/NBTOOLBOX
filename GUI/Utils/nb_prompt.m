function output = nb_prompt(message, yesText, noText)
% Syntax:
%
% output = nb_prompt(message, yesText, noText)
%
% Description:
%
% Promt response from user.
% 
% Input:
% 
% - message : Quastion to the user.
%
% - yesText : Text on the yes button.
%
% - noText  : Text on the no button
% 
% Output:
% 
% - output : > 'yes'   : If the yes button where pushed.
%            > 'no'    : If the no button where pushed.
%            > 'close' : If the window where closed.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        noText = 'No';
        if nargin < 2
            yesText = 'Yes';
        end
    end
    
    % Create the window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure(...
        'Visible',          'off',...
        'units',            'characters',...
        'position',         [50 40 100 20],...
        'name',             'Warning',...
        'NumberTitle',      'off',...
        'MenuBar',          'None',...
        'Toolbar',          'None',...
        'resize',           'off',...
        'windowStyle',      'modal',...
        'Color',            defaultBackground,...
        'closeRequestFcn',  @closeCallback);
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Print question message
    uicontrol(f,...
        'units',              'normalized',...
        'position',           [0.04 0.25 0.96 0.4],...
        'Style',              'text',...
        'HorizontalAlignment','left',...
        'String',             message);

    % Push buttons to give an answer
    bHeight = 0.1;
    bWidth  = 0.25;
    space   = 0.1;
    start   = (1 - bWidth*2 - space)/2;
    ySpace  = 0.1;
    
    uicontrol(f,...
        'units',       'normalized',...
        'position',    [start, ySpace, bWidth, bHeight],...
        'callback',    @yesCallback,...
        'String',      yesText,...
        'Style',       'pushbutton');
    
    uicontrol(f,...
        'units',       'normalized',...
        'position',    [start + bWidth + space, ySpace, bWidth, bHeight],...
        'callback',    @noCallback,...
        'String',      noText,...
        'Style',       'pushbutton');
                 
    set(f, 'Visible', 'on');
    
    % Freeze execution until user clicks button
    uiwait(f);
    
    function yesCallback(varargin)
        output = 'yes';
        delete(f);
    end

    function noCallback(varargin)
        output = 'no';
        delete(f);
    end

    function closeCallback(varargin)
       output = 'close';
       delete(f);
    end

end
