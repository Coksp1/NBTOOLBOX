function loadOptionsWhenExist(gui)
% Syntax:
%
% loadOptionsWhenExist(gui)
%
% Description:
%
% Part of DAG.
% 
% When the save name is found in the data property of the
% objects parent we ask the user if it will try to merge, 
% overwrite or exit without saving the loaded data.
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the window
    f = nb_guiFigure(gui.parent,'Import Option',[50 40 100 20],'modal','off');                   

    % Print question message
    message = ['The dataset ''' gui.name ''' already exist, what do you want to do?'];
    uicontrol(f,nb_constant.LABEL,...
      'position', [0.04 0.25 0.96 0.4],...
      'String',   message); 

    % Push buttons to give an answer
    %--------------------------------------------------------------
    bHeight = 0.1;
    bWidth  = 0.15;
    space   = 0.1;
    start   = (1 - bWidth*3 - space*2)/2;
    ySpace  = 0.1;

    uicontrol(f,nb_constant.BUTTON,...
     'position',    [start,ySpace,bWidth,bHeight],...
     'callback',    @gui.exitGUI,...
     'String',      'Cancel');

    uicontrol(f,nb_constant.BUTTON,...
     'position',    [start + bWidth + space,ySpace,bWidth,bHeight],...
     'callback',    @gui.overwrite,...
     'String',      'Overwrite');
                 
    uicontrol(f,nb_constant.BUTTON,...
     'position',    [start + bWidth*2 + space*2,ySpace,bWidth,bHeight],...
     'callback',    @gui.rename,...
     'String',      'Rename');               

    %Make the GUI visible.
    %--------------------------------------------------------------
    set(f,'Visible','on'); 

end
