function placeBetween(gui,hObject,~)
% Syntax:
%
% placeBetween(gui,hObject,event)
%
% Description:
%
% Part of DAG. Place between to dates
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get state
    value = get(hObject,'value');

    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    plotterT = gui.plotter;
    
    if value
    
        % Assign graph object
        old = plotterT.verticalLine{index};
        
        if strcmpi(plotterT.plotType,'scatter')
            
            if ~isnumeric(old)
            
                if isa(plotterT,'nb_graph_ts')

                    if ischar(old) && ~nb_contains(old,'%#') 
                        old = nb_date.toDate(old,plotterT.DB.frequency);
                        old = old - plotterT.startGraph + 1;
                    elseif isa(old,'nb_date')
                        old = old - plotterT.startGraph + 1;
                    end
                    
                else
                    
                    old = find(strcmp(old,plotterT.typesToPlot),1,'last');
                    if isempty(old)
                        old = 1;
                    end
                    
                end
                
            end
            
        end
        
        plotterT.verticalLine{index} = {old,old}; 

        % Update panel
        if isa(old,'nb_date')
           old = old.toString(); 
        end
        set(gui.editbox3,'string',old,'enable','on');
        
    else
        
        % Assign graph object
        old = plotterT.verticalLine{index};
        plotterT.verticalLine{index} = old{1}; 

        % Update panel
        set(gui.editbox3,'string','','enable','off');
        
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
