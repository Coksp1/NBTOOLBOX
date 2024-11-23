function setCallback(gui,~,~)
% Syntax:
%
% setCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    plotter.setSpecial('returnLocal',true);      
    old     = plotter.stopUpdate;
    plotter.setSpecial('returnLocal',false);
    new     = nb_getUIControlValue(gui.comp.stopUpdate);

    % Update the graph object
    try
        plotter.stopUpdate = new;
        test = plotter.stopUpdate; %#ok<NASGU>
    catch Err
        plotter.stopUpdate = old;
        nb_errorWindow('Wrong date format:: ', Err);
        return
    end

end
