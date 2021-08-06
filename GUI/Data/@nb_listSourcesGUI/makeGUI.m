function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    % Create the main window
    f = nb_guiFigure(gui.parent,gui.name,[50  40  80   30],'normal','on');
    gui.figureHandle = f;
    
    % Make the main grid
    g  = nb_gridcontainer(f,'GridSize',[1,1],'Padding',10,'VerticalWeight',0.1);
    
    % Grid holding the popupmenu
    g2 = nb_gridcontainer(g,'GridSize',[1,3]); 
    
    % Choose iden
    if strcmpi(gui.browseBy,'graphs')
        objName = 'graph';
    else
        objName = 'dataset';
    end
    str = ['Choose ',objName];
    
    % Populate the title section
    uicontrol(g2,nb_constant.LABEL,...
                'string',str,...
                'position',[0.1,0,0.92,0.8],...
                'fontweight','bold');
            
    uicontrol(g2,nb_constant.POPUP,...
                'string',gui.listNames,...
                'position',[0.1,0.5,0.92,0.8],...
                'callback',@gui.changeObj);
            
    nb_emptyCell(g2);
    
    %%%% Add union of all elements
    
    % Source link
    uicontrol(f,nb_constant.LABEL,'string','Source',...
       'fontweight','bold','position',[0.04,0.75,0.60,0.05]);
    gui.editBox1 = uicontrol(f,nb_constant.EDIT,...
        'position',[0.25,0.75,0.60,0.05]);
    
    % Variables 
    uicontrol(f,nb_constant.LABEL,'string','Variables',...
       'fontweight','bold','position',[0.04,0.68,0.60,0.05]);
    gui.editBox2 = uicontrol(f,nb_constant.EDIT,...
        'max',2,'position',[0.25,0.47,0.60,0.25]);
    
    % Start date
    uicontrol(f,nb_constant.LABEL,'string','Start date',...
       'fontweight','bold','position',[0.04,0.40,0.60,0.05]);
    gui.editBox3 = uicontrol(f,nb_constant.EDIT,...
        'position',[0.25,0.40,0.20,0.05]);
    
    % End date
    uicontrol(f,nb_constant.LABEL,'string','End date',...
       'fontweight','bold','position',[0.04,0.33,0.60,0.05]);
    gui.editBox4 = uicontrol(f,nb_constant.EDIT,...
        'position',[0.25,0.33,0.20,0.05]);
    
    % Vintage
    uicontrol(f,nb_constant.LABEL,'string','Vintage',...
       'fontweight','bold','position',[0.04,0.26,0.60,0.05]);
    gui.editBox5 = uicontrol(f,nb_constant.EDIT,...
        'max',2,'position',[0.25,0.16,0.30,0.15]);
    
    % Sheet
    uicontrol(f,nb_constant.LABEL,'string','Sheet',...
       'fontweight','bold','position',[0.04,0.09,0.60,0.05]);
    gui.editBox6 = uicontrol(f,nb_constant.EDIT,...
        'position',[0.25,0.09,0.60,0.05]);
    
    % Information
    str = 'Note: You cannot make any changes in this window.';
    uicontrol(f,nb_constant.LABEL,'string',str,...
       'position',[0.04,0.01,0.70,0.05]);
    
    % Pass on object to create rest of GUI
    addSourcesGUI(gui);    
    
end
