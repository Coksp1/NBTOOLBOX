function setFakeLegendProperty(gui,hObject,~,type)
% Syntax:
%
% setFakeLegendProperty(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the current fake legend
    string = get(gui.popupmenu2,'string');
    index  = get(gui.popupmenu2,'value');
    fakeL  = string{index};
    
    % Locate the fake legend in the graph object
    plotterT = gui.plotter;
    fakeLs   = plotterT.fakeLegend;
    indF     = find(strcmp(fakeL,fakeLs),1,'last');
    options  = fakeLs{indF + 1};
    
    % Get the selected value
    string   = get(hObject,'string');
    index    = get(hObject,'value');
    selected = string{index};
    
    % Assign changes
    ind = find(strcmpi(type,options),1,'last');
    if isempty(ind)
        options = [options,type,selected];
    else
        options{ind + 1} = selected;
    end
    fakeLs{indF + 1} = options;
    
    % Update graph object
    plotterT.fakeLegend = fakeLs;
    
    % Notify listeners
    notify(gui,'changedGraph'); 
    
    % Enable/unable
    if strcmpi(type,'type')
        
        if strcmpi(selected,'line')
            set(gui.popupmenu5,'enable','off');
            set(gui.radiobutton2,'enable','off');
            set(gui.popupmenu6,'enable','off');
            set(gui.popupmenu8,'enable','on');
            set(gui.popupmenu9,'enable','off');
        else
            if get(gui.radiobutton2,'value')
                set(gui.popupmenu5,'enable','on');
            end
            set(gui.radiobutton2,'enable','on');
            set(gui.popupmenu6,'enable','on');
            set(gui.popupmenu8,'enable','off');
            set(gui.popupmenu9,'enable','on');
        end
        
    end

end
