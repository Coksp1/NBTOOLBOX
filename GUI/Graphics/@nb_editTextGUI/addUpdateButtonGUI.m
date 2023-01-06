function addUpdateButtonGUI(gui)
% Syntax:
%
% addUpdateButtonGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f = gui.figureHandle;
    
    uicontrol(...
          'units',                  'normalized',...
          'position',               [0.40, 0.015 , 0.20 , 0.03],...
          'parent',                 f,...
          'style',                  'pushbutton',...
          'horizontalAlignment',    'left',...
          'string',                 'Update',...
          'callback',               @gui.setTextInfo);  
    
    % Show figure
    set(f,'visible','on')

end
