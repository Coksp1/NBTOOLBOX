function nb_helpWindow(message)
% Syntax:
%
% nb_helpWindow(message)
%
% Description:
%
% Display helpful comments in HTML format.
% 
% Input:
% 
% - 1 x n cellstr. Alternating title and description (n is even).
% 
% Output:
% 
% - A gui window with helpful text.
%
% Examples:
%
% nb_helpWindow({'Some title',...
%                   sprintf(['This is an explanation for what \n',...
%                            'the user should do.'])});
%
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if ~(mod(length(message),2)==0)
        error([mfilename, ':: Help message must be an even numbered cell.'])
    end
    
    % Alternate pattern of HTML formatted titles and regular text
    items = message;
    pre  = '<HTML><BODY><HTML><p><font size = "3"><b>';
    post = '</b></font></p></BODY></HTML>';
    for ii = 1:length(message)
       if  ~mod(ii,2) == 0
          items{ii} = [pre,message{ii},post]; 
       end
    end
    
    % Interjecting spaces in the cell array
    c      = cell(1,length(items)*1.5-1);
    c(:)   = {' '};
    invInd = 0:3:length(items)*1.5-1;
    invS   = invInd(2:end);
    ind    = setdiff(1:length(c),invS);
    
    c(ind) = items;

    
    % Create the window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('Visible',     'off',...
        'Color',       defaultBackground,...
        'units',       'characters',...
        'position',    [65   15  100  25],...
        'name',        'Help',...
        'NumberTitle', 'off',...
        'MenuBar',     'None',...
        'Toolbar',     'None',...
        'resize',      'on',...
        'windowStyle', 'modal',...
        'dockControls','off');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Create a MATLAB uicontrol object
    uicontrol('parent',f,...
        'HorizontalAlignment','left',...
        'units',              'normalized',...
        'position',           [0.04,0.04,0.92,0.92],...
        'background',[1,1,1],...
        'style','listbox',...
        'min',0,...
        'max',1000,...
        'value',[],...
        'string',c);
    
    % Make the window visible.
    set(f,'Visible','on');
    
end
