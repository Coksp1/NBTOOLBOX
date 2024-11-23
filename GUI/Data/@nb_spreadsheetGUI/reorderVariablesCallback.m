function reorderVariablesCallback(gui,hObject,~)
% Syntax:
%
% reorderVariablesCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Reorder variables/types/datasets in a GUI
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    type = get(hObject,'label');
    if strcmpi(type,'variables')
       c = gui.data.variables; 
    elseif strcmpi(type,'types')
       c = gui.data.types; 
    else
       c = gui.data.dataNames; 
    end
    
    reorderGui = nb_reorderGUI(c,['Re-order ' type]);
    addlistener(reorderGui,'reorderingFinished',{@finishUpCallback,gui,type});
    
end

function finishUpCallback(hObject,~,gui,type)

    newOrder = hObject.cstr;
    dataT    = reorder(gui.data,newOrder,type);
    s.data   = dataT;
    updateDataCallback(gui,s,[]);

end
