function selectIndicatorVariable(gui,hObject,~)
% Syntax:
%
% selectIndicatorVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select the variable to be plotted as indicator
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object
    plotterT        = gui.plotter;
    candleVariables = plotterT.candleVariables;
    
    % Get selected variable
    string = get(hObject,'string');
    value  = get(hObject,'value');
    var    = string{value};
    
    % Test the new value
    if isempty(var)
        
        % We remove it from the candlevariables
        indT            = find(strcmpi('indicator',candleVariables(1:2:end)),1,'last');
        candleVariables = [candleVariables(1:indT*2 - 2),candleVariables(indT*2 + 1:end)];
        
    else
        
        % Change the indicator variable
        indT = find(strcmpi('indicator',candleVariables(1:2:end)),1,'last');
        if isempty(indT)
            candleVariables = [candleVariables,'indicator',var];
        else
            candleVariables{indT*2} = var;
        end
        
    end
    
    % Assign graph object
    plotterT.set('candleVariables',candleVariables);
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
