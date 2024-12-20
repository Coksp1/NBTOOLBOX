function merge(gui,~,~)
% Syntax:
%
% merge(gui,hObject,event)
%
% Description:
%
% Part of DAG. Makes it possible to merge the existing dataset with  
% another dataset stored in the main program
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    mergegui = nb_mergeDataGUI(gui.parent,gui.data,[],gui.dataName,'');
    addlistener(mergegui,'methodFinished',@gui.updateDataCallback);
    
end
