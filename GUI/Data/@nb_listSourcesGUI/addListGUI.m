function addListGUI(gui)
% Syntax:
%
% addListGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    f = gui.figureHandle;
    
    % Correct the name if user changed object
    name       = gui.name;    
    parentName = [gui.parent.guiName,': '];
    f.Name     = [parentName,name];
    
    % Get list of sources of active graph
    src = gui.sources.(name)';
    
    % Make table with info (cannot use gridcontainer as the table is
    % cleared/deleted as obj is changed.
    gui.table = nb_uitable(f,...
                'units',          'normalized',...
                'ColumnFormat',   {'char'},...
                'ColumnName',     {'Sources'},...
                'ColumnEditable', false,...
                'ColumnWidth',    {338},...
                'position',       [0.04, 0.10, 0.93, 0.75],...
                'data',           src);
    
    % Display window
    set(f,'visible','on')
    
end
