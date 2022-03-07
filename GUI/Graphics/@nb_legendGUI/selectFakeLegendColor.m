function selectFakeLegendColor(gui,hObject,~)
% Syntax:
%
% selectFakeLegendColor(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the current fake legend
    string = get(gui.popupmenu2,'string');
    index  = get(gui.popupmenu2,'value');
    fakeL  = string{index};
    
    % Locate the fake legend in the graph object
    plotterT = gui.plotter;
    parent   = plotterT.parent;
    fakeLs   = plotterT.fakeLegend;
    indF     = find(strcmp(fakeL,fakeLs),1,'last');
    options  = fakeLs{indF + 1};
    
    % Get color selected
    endc  = nb_getGUIColorList(gui,parent);
    index = get(hObject,'value');
    color = endc{index};
    
    % Assign changes
    if strcmpi(get(hObject,'tag'),'first')
        
        ind = find(strcmpi('color',options),1,'last');
        if isempty(ind)
            options = [options,'color',color];
        else
            
            old = options{ind + 1};
            if isnumeric(old)
                if size(old,1) == 2
                    old = {old(1,:), old(2,:)};
                else
                    old = {old};
                end
            end
            if size(old,2) == 2
                % We are dealing with a shaded patch legend with
                % two colors
                old{1}           = color;
                options{ind + 1} = old;
            else
                options{ind + 1} = color;
            end
            
        end
        
    else
        
        ind = find(strcmpi('color',options),1,'last');
        if isempty(ind)
            
            color   = {[0, 0, 0], color};
            options = [options,'color',color];
            
        else
            
            old = options{ind + 1};
            if isnumeric(old)
                if size(old,1) == 2
                    old = {old(1,:), old(2,:)};
                else
                    old = {old};
                end
            end
            if size(old,2) == 2
                % We are dealing with a shaded patch legend with
                % two colors
                old{2}           = color;
                options{ind + 1} = old;
            else
                options{ind + 1} = [old, color];
            end
            
        end
        
    end
    fakeLs{indF + 1} = options;
    
    % Update graph object
    plotterT.fakeLegend = fakeLs;
    
    % Notify listeners
    notify(gui,'changedGraph');
    
end
