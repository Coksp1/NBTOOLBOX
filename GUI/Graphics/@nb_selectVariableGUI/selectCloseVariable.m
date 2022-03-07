function selectCloseVariable(gui,hObject,~)
% Syntax:
%
% selectCloseVariable(gui,hObject,event)
%
% Description:
%
% Part of DAG. Select the variable to be plotted as close
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get graph object
    plotterT        = gui.plotter;
    candleVariables = plotterT.candleVariables;
    
    % Get selected variable
    string = get(hObject,'string');
    value  = get(hObject,'value');
    var    = string{value};
    
    % Test the new value
    if isempty(var)
        
        ind = find(strcmpi('open',candleVariables(1:2:end)),1,'last');
        if isempty(ind)
            
            ind1 = find(strcmpi('high',candleVariables(1:2:end)),1,'last');
            ind2 = find(strcmpi('low',candleVariables(1:2:end)),1,'last');
            if isempty(ind1) || isempty(ind2)
                
                nb_errorWindow(['The close variable cannot be set to empty when open is empty '...
                               'and at the same time high and low is empty. Switch to old value.'])
                indT = find(strcmpi('close',candleVariables(1:2:end)),1,'last');
                var  = candleVariables{indT*2};
                indV = find(strcmpi(var,string),1,'last');
                set(hObject,'value',indV);
                return
                
            else
                
                % We remove it from the candlevariables
                indT            = find(strcmpi('close',candleVariables(1:2:end)),1,'last');
                candleVariables = [candleVariables(1:indT*2 - 2),candleVariables(indT*2 + 1:end)];
                
            end
                
        else
            
            % We remove it from the candlevariables
            indT            = find(strcmpi('close',candleVariables(1:2:end)),1,'last');
            candleVariables = [candleVariables(1:indT*2 - 2),candleVariables(indT*2 + 1:end)];
            
        end
        
    else
        
        % Change the close variable
        indT = find(strcmpi('close',candleVariables(1:2:end)),1,'last');
        if isempty(indT)
            candleVariables = [candleVariables,'close',var];
        else
            candleVariables{indT*2} = var;
        end
        
    end
    
    % Assign graph object
    plotterT.set('candleVariables',candleVariables);
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph')

end
