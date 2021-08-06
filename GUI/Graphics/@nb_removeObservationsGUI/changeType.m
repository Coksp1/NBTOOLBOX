function changeType(gui,hObject,~)
% Syntax:
%
% changeType(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the type of observation removal to use
% 
% Written by Kenneth Sæterhagen Paulsen      
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = gui.types;
    index  = get(hObject,'value');
    type   = string{index};
    
    string = get(gui.varpopup,'string');
    index  = get(gui.varpopup,'value');
    var    = string{index};
    
    % Get plotter object
    plotter  = gui.plotter;
    allDates = dates(plotter.DB);
    
    % Get the index of the variable choosen, and its options
    nanVars = plotter.nanVariables;
    index   = find(strcmpi(var,nanVars(1:2:end)),1);
    if isempty(index)
        oldType = 'none';
    else
        oldType = nanVars{index*2}{1};
        options = nanVars{index*2}(2:end);
    end
    
    switch lower(oldType)
        
        case 'none'
            
            switch lower(type)
                
                case 'none'
                    added = {};
                case 'before'
                    added = {var,{'before',plotter.DB.startDate.toString}};
                case 'after'
                    added = {var,{'after',plotter.DB.endDate.toString}};
                case 'beforeandafter'
                    added = {var,{'beforeandafter',plotter.DB.startDate.toString,plotter.DB.endDate.toString}};
                case 'between'
                    added = {var,{'between',plotter.DB.startDate.toString,plotter.DB.startDate.toString}};
                case 'ind'
                    added = {var,{'ind',{}}};
            end
            nanVars = [nanVars,added];
            
        case 'before'
            
            switch lower(type)
                
                case 'none'
                    newOptions = {};
                case 'before'
                    newOptions = {'before',options{1}};
                case 'after'
                    newOptions = {'after',options{1}};
                case 'beforeandafter'
                    newOptions = {'beforeandafter',options{1},''};
                case 'between'
                    newOptions = {'between',plotter.DB.startDate.toString,options{1}};
                case 'ind'
                    
                    dInd       = find(strcmp(options{1},allDates));
                    newOptions = {'ind',allDates(1:dInd-1)};
            end
            nanVars{index*2} = newOptions;
            
        case 'after'
            
            switch lower(type)
                
                case 'none'
                    newOptions = {};
                case 'before'
                    newOptions = {'before',options{1}};
                case 'after'
                    newOptions = {'after',options{1}};
                case 'beforeandafter'
                    newOptions = {'beforeandafter','',options{1}};
                case 'between'
                    newOptions = {'between',options{1},plotter.DB.endDate.toString};
                case 'ind'
                    
                    dInd       = find(strcmp(options{1},allDates));
                    newOptions = {'ind',allDates(dInd+1:end)};
            end
            nanVars{index*2} = newOptions;
            
        case 'beforeandafter'
            
            switch lower(type)
                
                case 'none'
                    newOptions = {};
                case 'before'
                    newOptions = {'before',options{1}};
                case 'after'
                    newOptions = {'after',options{2}};
                case 'beforeandafter'
                    newOptions = {'beforeandafter',options{1},options{2}};
                case 'between'
                    newOptions = {'between',options{1},options{2}};
                case 'ind'
                    
                    dInd1      = find(strcmp(options{1},allDates));
                    dInd2      = find(strcmp(options{2},allDates));
                    newOptions = {'ind',[allDates(1:dInd1-1),allDates(dInd2+1:end)]};
            end
            nanVars{index*2} = newOptions;
            
        case 'between'
            
            switch lower(type)
                
                case 'none'
                    newOptions = {};
                case 'before'
                    newOptions = {'before',options{1}};
                case 'after'
                    newOptions = {'after',options{2}};
                case 'beforeandafter'
                    newOptions = {'beforeandafter',options{1},options{2}};
                case 'between'
                    newOptions = {'between',options{1},options{2}};
                case 'ind'
                    
                    dInd1      = find(strcmp(options{1},allDates));
                    dInd2      = find(strcmp(options{2},allDates));
                    newOptions = {'ind',allDates(dInd1+1:dInd2-1)};
            end
            nanVars{index*2} = newOptions;
            
        case 'ind'

            selectedDatesOld = options{1};
            
            switch lower(type)
                
                case 'none'
                    newOptions = {};
                case 'before'
                    newOptions = {'before',selectedDatesOld{1}};
                case 'after'
                    newOptions = {'after',selectedDatesOld{end}};
                case 'beforeandafter'
                    newOptions = {'beforeandafter',selectedDatesOld{1},selectedDatesOld{end}};
                case 'between'
                    newOptions = {'between',selectedDatesOld{1},selectedDatesOld{end}};
                case 'ind'
                    newOptions = {'ind',selectedDatesOld};
            end
            nanVars{index*2} = newOptions;
            
            
    end
    
    if strcmpi(type,'none') && ~strcmpi(oldType,'none')
        plotter.nanVariables = [plotter.nanVariables(1:index*2-2),plotter.nanVariables(index*2+1:end)];
    else
        plotter.nanVariables = nanVars;
    end
    
    % Update the GUI with the option for the new variable
    updateTypePanel(gui,var,type);
    
    % Update graph
    notify(gui,'changedGraph');

end
