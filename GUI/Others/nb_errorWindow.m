function nb_errorWindow(message,Err)
% Syntax:
%
% nb_errorWindow(message)
% nb_errorWindow(message,Err)
%
% Description:
%
% Create a window for printing error messages.
% 
% Input:
% 
% - message : The wanted error message to print
%
% - Err     : A MException object. Caught by catch!
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        Err = [];
    end

    % Create the window
    f = nb_guiFigure([],'Error',[40,15,500,250],'modal','on',[],'uifigure');
              
    % Print the error message
    if ~isempty(Err)
        
        cMenu = uicontextmenu('parent',f);
        uimenu(cMenu,'Label','Normal','Callback',@resizeCallback);
        uimenu(cMenu,'Label','Maximize','Callback',@resizeCallback);
        uimenu(cMenu,'Label','Minimize','Callback',@resizeCallback);
        
        set(f,'uicontextmenu', cMenu);
        
        if isempty(message)
            textPos   = [0.04,0.72,0.92,0.24];
            scrollPos = [0.04,0.18,0.92,1-0.04-0.18];
        else
            textPos   = [0.04,0.52,0.92,0.44];
            scrollPos = [0.04,0.18,0.92,1-0.52-0.18];
        end
        
        % Print the error message
        uicontrol(f, nb_constant.LABEL,...
           'position', textPos,...
           'String',   message,...
           'tag',      'errorMessage1',...
           'fontSize', 10);
        
        messageME = nb_createErrorMessage('MATLAB error::',Err);
        messageME = regexp(messageME,'[\f\n\r]','split')';
        nb_scrollbox(...
          'parent',        f,...
          'units',         'normalized',...
          'tag',           'errorMessage2',...
          'position',      scrollPos,...
          'String',        messageME);

        % Create an OK button
        uicontrol(f, nb_constant.BUTTON,...
          'position',  [0.4,0.04,0.2,0.1],...
          'String',    'OK',...
          'callback',  {@okCallback,f});
              
    else
        
        % Print the error message
        uicontrol(f, nb_constant.LABEL,...
           'position', [0.04,0.22,0.92,0.74],...
           'String',   message,...
           'tag',      'errorMessage1',...
           'fontSize', 10);

        % Create an OK button
        uicontrol(f, nb_constant.BUTTON,...
          'position',  [0.4,0.04,0.2,0.1],...
          'String',    'OK',...
          'callback',  {@okCallback,f});
              
    end
    
    % Make the window visible.
    set(f,'Visible','on');

end

function okCallback(~,~,f)
    close(f);
end

function resizeCallback(menuUI,~)

    fig      = ancestor(menuUI,'figure');
    scrollUI = findobj(fig,'tag','errorMessage2');
    textUI   = findobj(fig,'tag','errorMessage1');
    type     = get(menuUI,'Label');
    if strcmpi(type,'Maximize')
        textPos   = [0.04,0.72,0.92,0.24];
        scrollPos = [0.04,0.18,0.92,1-0.04-0.18];
        visible   = 'on';
    elseif strcmpi(type,'Minimize')
        textPos   = [0.04,0.22,0.92,0.74];
        scrollPos = [0.04,0.18,0.92,1-0.74-0.18];
        visible   = 'off';
    else
        textPos   = [0.04,0.52,0.92,0.44];
        scrollPos = [0.04,0.18,0.92,1-0.52-0.18];
        visible   = 'on';
    end
    set(textUI,'position',textPos);
    set(scrollUI,'position',scrollPos,'visible',visible);
    
end
