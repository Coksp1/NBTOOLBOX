function setFanVariables(gui,~,~)
% Syntax:
%
% setFanVariables(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected lower fan variables
    fanVars  = get(gui.handle1,'string');
    if isempty(fanVars)
        nb_errorWindow('You must select some fan variables.')
        return
    end
   
    % Test the selected variables
    if rem(length(fanVars),2) ~= 0
        nb_errorWindow(['The selected number of variables must be even. Is ' int2str(length(fanVars)) '.'])
        return
    end
    
    % Assign locally
    gui.fanVariables = fanVars';
    
    % Update the properties panel
    nFans   = size(gui.fanVariables,2)/2;
    numbers = cellstr(num2str(nFans));
    value   = 1;
    
    set(gui.handle4,...
          'enable', 'off',...
          'string', numbers,...
          'value',  value);
    changeTable(gui,[],[]);
    
    set(gui.handle2,'enable','off');
      
    % Change panel
    set(gui.panelHandle1,'visible','off');
    set(gui.panelHandle2,'visible','on');

end
