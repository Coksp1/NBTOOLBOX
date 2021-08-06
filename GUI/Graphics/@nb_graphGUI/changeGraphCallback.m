function changeGraphCallback(gui,~,~)
% Syntax:
%
% changeGraphCallback(gui,h,e)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

    % Set up button group panel
    fig = nb_guiFigure([],'Change graph to edit',[40   15  40   10],'modal'); 
    
    % Make grid panel
    grid1 = nb_gridcontainer(fig,'GridSize',[5,1]);
    nb_emptyCell(grid1);
    grid2 = nb_gridcontainer(grid1,'GridSize',[1,2]);
    nb_emptyCell(grid1);
    grid3 = nb_gridcontainer(grid1,'GridSize',[1,3]);
    
    % Choose graph setting template
    uicontrol(grid2,nb_constant.LABEL,...
              'string','Edit');
    
    choices = {'1','2'};
    pop     = uicontrol(grid2,nb_constant.POPUP,...
              'string',choices,...
              'value', 1);   

    nb_emptyCell(grid3);
    uicontrol(grid3,nb_constant.BUTTON,...
        'string','Select',...
        'callback',{@changeCallback,gui,pop});
          
    % Make visible
    set(fig,'visible','on');
    
end

%==========================================================================
function changeCallback(~,~,gui,pop)

    value = get(pop,'value');
    if gui.currentGraph == value
        return
    end
    gui.currentGraph = value;
    changeMenu(gui,value);
    if ~isempty(gui.plotterAdv)
        gui.plotterAdv.currentGraph = value;
    end
    
end
