function addLeftColumnGUI(gui)
% Syntax:
%
% addLeftColumnGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    f    = gui.figureHandle;
    name = gui.name;
    if isempty(gui.parent)
        parentName = '';
    else
        parentName = [gui.parent.guiName,': '];
    end
    f.Name    = [parentName,name];
    sGraphObj = gui.infoStruct.(name);
    
    % Position helpers
    startT       = 0.04;
    startOp      = 0.23;
    startDistBot = 0.97;
    numOp        = 0.05;
    heightT      = 0.053;
    heightEB     = 0.025;
    widthEB      = 0.26;
    delta        = 0.025;

   % Norwegian Figure Name
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*2, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'Norwegian Figure Name');
      
    gui.editBox1 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*2+delta, widthEB, heightEB],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'string',                 sGraphObj.figureNameNor);      
      
    % English Figure Name
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*3, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'English Figure Name');
    
    gui.editBox2 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*3+delta, widthEB, heightEB],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'string',                 sGraphObj.figureNameEng);       
      
    % Norwegian Figure Title
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*4, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'Norwegian Figure Title');
      
    gui.editBox3 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*5.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...        
          'string',                 sGraphObj.figureTitleNor);      
     
    % English Figure Title
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*6, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'English Figure Title');

    gui.editBox4 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*7.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...
          'string',                 sGraphObj.figureTitleEng);        
      
    % Norwegian Footer
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*8, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'Norwegian Footer');
     
    gui.editBox5 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*9.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...  
          'string',                 sGraphObj.footerNor);    
   
   % English Footer
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*10, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'English Footer');
     
    gui.editBox6 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*11.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...  
          'string',                 sGraphObj.footerEng);      
      
    % Norwegian Tooltip
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*12, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'Norwegian Tooltip');
     
    gui.editBox7 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*13.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...  
          'string',                 sGraphObj.tooltipNor);    
  
   % English Tooltip
    uicontrol(...
          'units',                  'normalized',...
          'position',               [startT, startDistBot-numOp*14, 0.35, heightT],...
          'parent',                 f,...
          'style',                  'text',...
          'horizontalAlignment',    'left',...
          'string',                 'English Tooltip');
     
    gui.editBox8 = uicontrol(...
          'units',                  'normalized',...
          'position',               [startOp, startDistBot-numOp*15.25+delta, widthEB, heightEB * 3.5],...
          'parent',                 f,...
          'style',                  'edit',...
          'horizontalAlignment',    'left',...
          'max',                    2,...  
          'string',                 sGraphObj.tooltipEng);   
      
     % Plotter/plotter(1) properties 
     addSingleFieldGUI(gui)
     
     if sGraphObj.panel
        % Add information of plotter(2) properties
        addPanelFieldGUI(gui)   
     end
     
     % Add update button and display GUI window
     addUpdateButtonGUI(gui)
end
