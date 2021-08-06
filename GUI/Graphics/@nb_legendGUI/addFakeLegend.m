function addFakeLegend(gui,~,~)
% Syntax:
%
% addFakeLegend(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for adding a fake legend  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT    = gui.plotter;
    fakeLegends = get(gui.popupmenu2,'string');

    if strcmpi(fakeLegends{1},' ')
        fakeName    = 'fakeLegend1';  
        num         = 0;
        fakeLegends = {};
    else

        num   = size(fakeLegends,1);
        found = 1;
        kk    = 1;
        while found
            fakeName = ['fakeLegend' int2str(kk)];
            found     = ~isempty(find(strcmp(fakeName,fakeLegends),1));
            kk        = kk + 1;
        end

    end

    % Update the object
    old = plotterT.fakeLegend;
    new = {fakeName,{...
           'color',gui.plotter.parent.settings.defaultColors{1},...
           'direction','north',...
           'linestyle','-',...
           'linewidth',2,...
           'marker','none',...
           'edgecolor','same'}};
    plotterT.set('fakeLegend',[old, new]);
    
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Update the fake legend selection list 
    set(gui.popupmenu2,'string',[fakeLegends;fakeName],'value',num + 1);

    % Switch the scatter group of interest
    updateFakeLegendPanel(gui,fakeName,0);
    
    % Update the table of the text panel
    data = get(gui.table,'data');
    if isempty(data{1})
        data = {fakeName,fakeName};
        set(gui.table,'data',data,'enable','on');
    else
        data = [data;{fakeName,fakeName}];
        set(gui.table,'data',data);
    end
    
end
