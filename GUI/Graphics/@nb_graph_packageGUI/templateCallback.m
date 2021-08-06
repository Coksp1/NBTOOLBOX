function templateCallback(gui,~,~)
% Syntax:
%
% templateCallback(gui,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.templates)
        nb_errorWindow(['No templates are shared among all graphs of the package. ',...
                        'The last saved version of each graphs will be printed.'])
        return
    end

    % Create user interface
    fig  = nb_guiFigure(gui.parent,'Choose local template',[40, 15, 85.5, 31.5],'modal');
    grid = nb_gridcontainer(fig,'gridSize',[5,1],'verticalWeight',[0.02,0.84,0.02,0.1,0.02]);
    nb_emptyCell(grid);
    
    % Listbox
    grid2 = nb_gridcontainer(grid,'gridSize',[1,3],'horizontalWeight',[0.05,0.9,0.05]);
    nb_emptyCell(grid2);
    value = find(strcmpi(gui.template,gui.templates));
    list  = uicontrol(grid2,nb_constant.LISTBOX,...
        'string', gui.templates,...
        'value',  value,...
        'max',    1);
    
    nb_emptyCell(grid);
    
    % Select button
    grid3 = nb_gridcontainer(grid,'gridSize',[1,3],'horizontalWeight',[0.2,0.6,0.2]);
    nb_emptyCell(grid3);
    uicontrol(grid3,nb_constant.BUTTON,...
        'string', 'Choose',...
        'callback', @(h,e)chooseCallback(h,e,gui,list));

    set(fig,'visible','on');
    
end

%==========================================================================
function chooseCallback(~,~,gui,list)

    gui.template = nb_getUIControlValue(list);
    if iscell(gui.template)
        gui.template = gui.template{1};
    end

    % Delete GUI
    delete(nb_getParentRecursively(list));
    
end
