function changeLocationOption(gui,hObject,~)
% Syntax:
%
% changeLocationOption(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set loaction option of the legend callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get value selected
    value  = get(hObject,'value');
    
    % Assign graph object
    if value
        
        set(gui.editbox1,'enable','on');
        set(gui.editbox2,'enable','on');
        set(gui.popupmenu1,'enable','off');
        
        % Get current legend position
        ax  = get(plotterT,'axesHandle');
        leg = ax.legend;
        if ~isempty(leg.extent)
            
            axPos     = ax.position;
            newExtent = leg.extent;
            if isa(leg.parent.parent,'nb_graphPanel')
                        
                % Get the axes positions in figure units
                % instead of panel units
                panelH      = leg.parent.parent.panelHandle;
                oldUnits    = get(panelH,'units');
                set(panelH,'units','normalized');
                uipPos      = get(panelH,'Position');
                set(panelH,'units',oldUnits);
                axPosFig    = nan(1,4);
                axPosFig(1) = axPos(1)*uipPos(3) + uipPos(1);
                axPosFig(2) = axPos(2)*uipPos(4) + uipPos(2);
                axPosFig(3) = axPos(3)*uipPos(3);
                axPosFig(4) = axPos(4)*uipPos(4);
               
                % Get the new position in axes units
                newPos    = nan(1,2);
                newPos(1) = (newExtent(1) - axPosFig(1))/axPosFig(3);
                % Remember that the position argument is the top left corner.
                extentTemp2 = (newExtent(2) - axPosFig(2))/axPosFig(4);
                extentTemp4 = newExtent(4)/axPosFig(4); %/2
                newPos(2)   = extentTemp4 + extentTemp2 - leg.heightOfText(1)/2 - 2*leg.legTightInsetY;
                
            else
                
                % Get the new position in axes units
                newPos    = nan(1,2);
                newPos(1) = (newExtent(1) - axPos(1))/axPos(3);
                extentTemp2 = (newExtent(2) - axPos(2))/axPos(4);
                extentTemp4 = newExtent(4)/axPos(4); %/2
                newPos(2)   = extentTemp4 + extentTemp2 - leg.heightOfText(1)/2 - 2*leg.legTightInsetY;
                
            end
            
            plotterT.legPosition = newPos;
            set(gui.editbox1,'string',num2str(leg.extent(1)));
            set(gui.editbox2,'string',num2str(leg.extent(2)));
            
        else
            plotterT.legPosition = [0.04,0.96];
            set(gui.editbox1,'string',num2str(0.04));
            set(gui.editbox2,'string',num2str(0.96));
        end
        
    else
        set(gui.editbox1,'enable','off');
        set(gui.editbox2,'enable','off');
        set(gui.popupmenu1,'enable','on');
        plotterT.legPosition = [];
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
