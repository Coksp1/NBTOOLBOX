function addPatchObject(gui,~,~)
% Syntax:
%
% addPatchObject(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for adding a patch object (between 
% variables) 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    objects  = get(gui.popupmenu1,'string');

    if strcmpi(objects{1},' ')
        patchName = 'Patch 1';  
        num           = 0;
        objects       = {};
    else

        num   = size(objects,1);
        found = 1;
        kk    = 1;
        while found
            patchName = ['Patch ' int2str(kk)];
            found     = ~isempty(find(strcmp(patchName,objects),1));
            kk        = kk + 1;
        end

    end

    % Create new patch object
    %------------------------
        
    % Location
    old = plotterT.patch;
    new = {patchName, plotterT.DB.variables{1}, plotterT.DB.variables{1}, [0 0 0]};
    plotterT.patch = [old, new];

    % Notify listeners
    notify(gui,'changedGraph')
    
    % Update the line object selection list 
    set(gui.popupmenu1,'string',[objects;patchName],'value',num + 1);
    
    % Switch the line object of interest
    updatePatchPanel(gui,patchName,0);
        
end
