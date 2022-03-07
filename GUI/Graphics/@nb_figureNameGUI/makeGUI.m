function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
% 
% Part of DAG.
%
% Creates the menu for setting figure names in both Norwegian and English
% for graphs of type Advanced Table or Advanced Graph.
% With an advanced graph open: Advanced > Figure Name.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    plotterAdv = gui.plotter;
    parent     = plotterAdv.plotter.parent;
    
    if isa(plotterAdv.plotter,'nb_table_data_source')
        string = 'Table Name';
    else
        string = 'Figure Name';
    end
    
    % Create the main window
    %--------------------------------------------------------------
    f = nb_guiFigure(parent,string,[65   15  100  25],'modal','off'); 
    gui.figureHandle = f;
    
    % Create the grid
    %--------------------------------------------------------------
    g = nb_gridcontainer(f,...
            'GridSize', [9 1],...
            'position', [0.04,0.1,0.92,0.8]);
    

            
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(g,nb_constant.LABEL,...
                            'string',  'Norwegian',...
                            'position', [0.1,0.4,0.8,0.4]);
                        
    string = plotterAdv.figureNameNor;
    
    gui.editBox1 = uicontrol(g,nb_constant.EDIT,...
                            'string', string,...
                            'position', [0.1,0.4,0.8,0.4]);
    
    nb_emptyCell(g);
          
    % English
    %--------------------------------------------------------------
    uicontrol(g,nb_constant.LABEL,...
                            'string',   'English',...
                            'position', [0.1,0.4,0.8,0.4]);             

    string = plotterAdv.figureNameEng;
    
    gui.editBox2 = uicontrol(g,nb_constant.EDIT,...
                            'string',   string,...
                            'position', [0.1,0.4,0.8,0.4]);
                            
    nb_emptyCell(g);
                            
    % Update button      
    %-------------------------------------------------------------- 
    g2 = nb_gridcontainer(g,...
            'GridSize', [1 3],...
            'position', [0.04,0.1,0.92,0.8]);
    
    nb_emptyCell(g2);    
        
    uicontrol(g2,nb_constant.BUTTON,...
                             'string',   'Update',...
                             'position', [0.04,0.04,0.92,0.92],...
                             'callback', @gui.setFigureNameCallback);

    
    nb_emptyCell(g2);
    
    
    % Note
    %--------------------------------------------------------------
    nb_emptyCell(g);
    
    uicontrol(g,nb_constant.LABEL,...
                            'string',   '*) These names will be used in the Excel data sheet when graphs are exported.',...
                            'position', [0.1,0.1,0.8,0.4]);   
                          
    % Make visible
    %--------------------------------------------------------------
    set(f,'visible','on');
          
end
