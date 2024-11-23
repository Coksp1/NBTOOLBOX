function setTemplateCallback(gui,~,~)
% Syntax:
%
% setTemplateCallback(gui,~,~)
%
% Description:
%
% Add new template.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    choices = fieldnames(gui.plotter(1).template);
    if isempty(choices)
        nb_errorWindow('No templates to choose from.')
        return
    end
    
    % Create user interface
    fig  = nb_guiFigure(gui.parent,'Choose local template',[40, 15, 85.5, 31.5],'modal');
    grid = nb_gridcontainer(fig,'gridSize',[5,1],'verticalWeight',[0.02,0.84,0.02,0.1,0.02]);
    nb_emptyCell(grid);
    
    % Listbox
    grid2 = nb_gridcontainer(grid,'gridSize',[1,3],'horizontalWeight',[0.05,0.9,0.05]);
    nb_emptyCell(grid2);
    list = uicontrol(grid2,nb_constant.LISTBOX,...
        'string', choices,...
        'value',  1,...
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

    chosen = nb_getUIControlValue(list);
    if iscell(chosen)
        chosen = chosen{1};
    end

    if strcmpi(gui.type,'advanced')
        applyTemplate(gui.plotterAdv,chosen);
        for ii = 1:size(gui.plotterAdv.plotter,2)    
            % Update graph and trigger listeners
            graphUpdate(gui.plotterAdv.plotter(ii),[],[]);
        end
    else
        applyTemplate(gui.plotter,chosen);
        % Update graph and trigger listeners
        graphUpdate(gui.plotter,[],[]);
    end
    
end
