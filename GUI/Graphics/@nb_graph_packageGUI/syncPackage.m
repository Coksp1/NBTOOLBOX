function syncPackage(gui,~,event)
% Syntax:
%
% syncPackage(gui,hObject,event)
%
% Description:
%
% Part of DAG. Sync package given that an advanced graph object have been 
% changed
%
% Input:
%
% - event : An nb_additionalStringEvent object
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isvalid(gui)
        return
    end
    
    appGraphs           = gui.parent.graphs;
    nameOfChangedObject = event.string;
    ind                 = find(strcmpi(nameOfChangedObject,gui.package.identifiers),1);
    if ~isempty(ind)
        gui.package.graphs{ind} = copy(appGraphs.(nameOfChangedObject));
    end

end
