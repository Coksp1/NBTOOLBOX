function chooseTemplateWindow(gui,chooseFunc)
% Syntax:
%
% chooseTemplateWindow(gui,chooseFunc)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen and Per Bjarne Bye
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Create user interface
    fig  = nb_guiFigure(gui.parent,'Choose template',[40, 15, 85.5, 31.5],'modal');
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
    grid3 = nb_gridcontainer(grid,'gridSize',[1,3],'horizontalWeight',[0.3,0.4,0.3]);
    nb_emptyCell(grid3);
    uicontrol(grid3,nb_constant.BUTTON,...
        'string', 'Choose',...
        'callback', @(h,e)chooseCallback(h,e,gui,list,chooseFunc));
    
    % Help button
    icon = imread('qmark.png');

    uicontrol(fig,nb_constant.BUTTON,...
              'units',          'normalized',...
              'callback',       @helpChooseTemplateGP,...
              'String',         '',...
              'cData',          icon,...
              'position',       [0.90,0.02,0.075,0.08]);
    set(fig,'visible','on');
    
end

%==========================================================================
function chooseCallback(~,~,gui,list,chooseFunc)

    gui.template = nb_getUIControlValue(list);
    if iscell(gui.template)
        gui.template = gui.template{1};
    end

    % Delete GUI
    delete(nb_getParentRecursively(list));
    
    % Call the passed function
    chooseFunc()
    
end     

function helpChooseTemplateGP(~,~)
    
    to  = char(hex2dec('2192'));
    nb_helpWindow(...
            {'Choosing a template',...
            sprintf(['To be able to print the graphs, you need to choose what template to apply. \n',...
            'The template you choose will be applied to all the printed graphs. If you choose \n',...
            '"current", then the current chosen template for each individual graph in the package \n',...
            'will be applied. I.e., this is the method you can use to print graphs with different \n',...
            'templates at once.']),...
            'The template I want does not show up',...
            sprintf(['For a template to show up in the list, it must be defined for all graphs in \n',...
            'the package. If the template you want to use is not in the list, you can either go \n',...
            'through each graph in the session and add the template one-by-one from the template \n',...
            'menu in the graph window, or you can add the template to all graphs in the session \n',...
            'using the "add to all" function which you can find in Graphics ',to,' Settings ',to,' \n',...
            'Templates, from the main DAG window.'])});

end
