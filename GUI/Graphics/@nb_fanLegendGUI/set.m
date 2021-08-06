function set(gui,hObject,~,type)
% Syntax:
%
% set(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get the user response
    %--------------------------------------------------------------
    switch lower(type)
        
        case 'fanlegend'
            
            plotterT.fanLegend = get(hObject,'value');
            
        case 'fanlegendlocation1'
            
            string = get(hObject,'string');
            number = str2double(string);
            
            if isnan(number)
                nb_errorWindow('The fan legend position(1) must be a number.')
            end
            
            if ischar(plotterT.fanLegendLocation)
                pos                        = [number,0.5];
                plotterT.fanLegendLocation = pos;
            else
                plotterT.fanLegendLocation(1) = number;
            end
            
        case 'fanlegendlocation2'
            
            string = get(hObject,'string');
            number = str2double(string);
            
            if isnan(number)
                nb_errorWindow('The fan legend position(1) must be a number.')
            end
            
            if ischar(plotterT.fanLegendLocation)
                pos                        = [0.5,number];
                plotterT.fanLegendLocation = pos;
            else
                plotterT.fanLegendLocation(2) = number;
            end
            
        case 'fanlegendlocation'
            
            string = get(hObject,'string');
            index  = get(hObject,'value');
            loc    = string{index};
            plotterT.fanLegendLocation = loc;
            
        case 'switch'
            
            value = get(hObject,'value');
            if value % Location
                plotterT.fanLegendLocation = 'outside';
                set(gui.editbox1,'string','','enable','off');
                set(gui.editbox2,'string','','enable','off');
                set(gui.popupmenu1,'enable','on');
            else % Position
                plotterT.fanLegendLocation = [0.5,0.5];
                set(gui.editbox1,'string','0.5','enable','on');
                set(gui.editbox2,'string','0.5','enable','on');
                set(gui.popupmenu1,'enable','off');
            end
            
    end
    
    % Update the graph object
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end
