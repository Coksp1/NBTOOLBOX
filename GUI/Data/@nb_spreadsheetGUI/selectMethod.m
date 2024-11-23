function selectMethod(gui,~,~)
% Syntax:
%
% selectMethod(gui,hObject,event)
%
% Description:
%
% Part of DAG. Give the user the possibility to select a method from a 
% list.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

     if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
     end
     nb_selectDataMethodGUI(gui);

end
