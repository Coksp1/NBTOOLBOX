function set(gui,hObject,~,property)
% Syntax:
%
% set(gui,hObject,event,property)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(property)
        
        case 'colormap'
        
            value = nb_getUIControlValue(hObject);
            if isempty(value)
                value = [];
            else
                try
                    value = nb_load(value);
                catch Err
                    nb_errorWindow('Could not load color map file.',Err)
                    return
                end
                if ~isnumeric(value)
                    nb_errorWindow('Could not load color map file. File must contain a matrix with size N x 3.')
                    return
                elseif size(value,2) ~= 3
                    nb_errorWindow('Could not load color map file. File must contain a matrix with size N x 3.')
                    return
                end
            end
            gui.plotter.colorMap = value; 
            
        case 'donutinnerradius'
        
            value = nb_getUIControlValue(hObject,'numeric');
            if isnan(value)
                nb_errorWindow('The inner radius must be set to a number between 0 and 1.')
                return
            elseif value <= -1 || value >= 1
                nb_errorWindow('The inner radius must be set to a number between -1 and 1.')
                return
            end
            gui.plotter.donutInnerRadius = value; 
            
        case 'donutradius'
        
            value = nb_getUIControlValue(hObject,'numeric');
            if isnan(value)
                nb_errorWindow('The radius must be set to a number greater then 0.')
                return
            elseif value <= 0 
                nb_errorWindow('The radius must be set to a number greater then 0.')
                return
            end
            gui.plotter.donutRadius = value;     
        
        case 'notickmarklabels'
        
            gui.plotter.noTickMarkLabels = ~nb_getUIControlValue(hObject);
            
        case 'notickmarklabelsleft'
        
            gui.plotter.noTickMarkLabelsLeft = ~nb_getUIControlValue(hObject);       
            
        case 'notickmarklabelsright'
        
            gui.plotter.noTickMarkLabelsRight = ~nb_getUIControlValue(hObject);    
            
        case 'pieaxisvisible'
        
            gui.plotter.pieAxisVisible = nb_getUIControlValue(hObject);
            
        case 'pieorigopositionx'
        
            gui.plotter.pieOrigoPosition(1) = nb_getUIControlValue(hObject,'numeric');    
            
        case 'pieorigopositiony'
        
            gui.plotter.pieOrigoPosition(2) = nb_getUIControlValue(hObject,'numeric');      
            
        case 'precision'
        
            gui.plotter.axesPrecision = nb_getUIControlValue(hObject,'userData');
            
    end
    
    % Udate the graph
    notify(gui,'changedGraph');        

end
