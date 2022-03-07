function [f,defaultBackground] = nb_guiFigure(mainGUI,name,positions,windowStyle,resize,callback)
% Syntax:
%
% [f,defaultBackground] = nb_guiFigure(mainGUI,name,positions,...
%                                        windowStyle,resize,callback)
%
% Description:
%
% Make window for GUI usage. Window will be centered in the current screen.
% 
% Input:
% 
% - mainGUI     : A nb_GUI object.
%
% - name        : The name of the new window, as a string.
% 
% - positions   : A 1 x 4 double with the position of the new window. Only
%                 the 3 and 4 element has somthing to say, as the window
%                 is automatically centered to the current monitor.
%
% - windowStyle : 'normal' or 'modal'. 'normal' is default.
%
% - resize      : 'on' or 'off'. 'off' is default.
%
% Output:
% 
% - f                 : A MATLAB figure object.
%
% - defaultBackground : A 1x3 with the background color used for the
%                       created window.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        callback = '';
        if nargin < 5
            resize = 'off';
            if nargin < 4
                windowStyle = 'normal';
            end
        end
    end
    
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' name];
    end    
        
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       positions,...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         resize,...
               'windowStyle',    windowStyle);
    nb_moveFigureToMonitor(f,currentMonitor);

    if ~isempty(callback)
        set(f,'CloseRequestFcn',callback);
    end
    
end
