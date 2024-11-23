function newTemplateCallback(gui,~,~)
% Syntax:
%
% newTemplateCallback(gui,~,~)
%
% Description:
%
% Add new template.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    graphSettings = fieldnames(gui.parent.settings.graphSettings);
    templates     = fieldnames(gui.plotter(1).template);
    index         = ~ismember(graphSettings,templates);
    choices       = graphSettings(index)';
    if isempty(choices)
        nb_infoWindow('No more templates to choose from.')
        return
    end
    
    % Create user interface
    fig   = nb_guiFigure(gui.parent,'New local template',[40, 15, 85.5, 31.5],'modal');
    set(fig,'visible','on');
    grid  = nb_gridcontainer(fig,'gridSize',[5,1],'verticalWeight',[0.02,0.84,0.02,0.1,0.02]);
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
        'string', 'Add',...
        'callback', @(h,e)addCallback(h,e,gui,list));
    
    set(fig,'visible','on');

end

%==========================================================================
function addCallback(~,~,gui,list)

    chosen = nb_getUIControlValue(list);
    if iscell(chosen)
        chosen = chosen{1};
    end
    templateAll = gui.parent.settings.graphSettings.(chosen);
    tempProps   = nb_graph.getTemplateProps();
    template    = nb_keepFields(templateAll,tempProps);
    
    gui.plotter(1).template.(chosen) = template;
    if strcmpi(gui.type,'advanced')
        if size(gui.plotterAdv.plotter,2) > 1
            gui.plotterAdv.plotter(2).template.(chosen) = template;
        end
    end
    
    % Delete parent figure
    delete(nb_getParentRecursively(list));
    
    % Add a dot when changed
    gui.changed = 1;
    
end
