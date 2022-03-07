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
    parent   = plotterT.parent;
    
    switch lower(type)
        
        case 'areaabrupt'
        
            plotterT.areaAbrupt = get(hObject,'value');
            
        case 'areaaccumulate'
        
            plotterT.areaAccumulate = logical(get(hObject,'value'));    
            
        case 'areaalpha'
        
            value = nb_getUIControlValue(hObject,'numeric');    
            if isnan(value)
                nb_errorWindow('The area alpha parameter is not a number between 0 and 1.')
                return
            elseif value < 0 || value > 1
                nb_errorWindow('The area alpha parameter is not a number between 0 and 1.')
                return
            end
            plotterT.areaAlpha = value;
            
        case 'axesfontsize'
            
            if strcmpi(gui.plotter.graphStyle,'mpr_white')
                nb_errorWindow('It is not allowed to set the axes font size property of an advanced graph.')
                set(hObject,'string',num2str(gui.plotter.axesFontSize));
                return
            end
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The axes font size must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The axes font size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.axesFontSize = value;
            
        case 'baralpha1'
        
            value = nb_getUIControlValue(hObject,'numeric');    
            if isnan(value)
                nb_errorWindow('The alpha blending 1 is not a number between 0 and 1.')
                return
            elseif value < 0 || value > 1
                nb_errorWindow('The alpha blending 1 is not a number between 0 and 1.')
                return
            end
            plotterT.barAlpha1 = value;    
            
        case 'baralpha2'
        
            value = nb_getUIControlValue(hObject,'numeric');    
            if isnan(value)
                nb_errorWindow('The alpha blending 2 is not a number between 0 and 1.')
                return
            elseif value < 0 || value > 1
                nb_errorWindow('The alpha blending 2 is not a number between 0 and 1.')
                return
            end
            plotterT.barAlpha2 = value;       
            
        case 'barblend'
        
            plotterT.barBlend = logical(get(hObject,'value'));         
            
        case 'barlinewidth'
                
            string = nb_getUIControlValue(hObject);  
            if isempty(string)
                plotterT.barLineWidth = [];
            else
                value = str2double(string);
                if isnan(value)
                    nb_errorWindow(['The bar line width must be set to a number or empty. Is ' string '.'])
                    return
                elseif value < 0   
                    nb_errorWindow(['The bar width must be set to a number greater then 0 (or empty). Is ' string '.'])
                    return
                end
                plotterT.barLineWidth = value;
            end
            
        case 'barorientation'
            
            % Need to check the plotTypes property, which is not 
            % compatible
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            
            if isempty(plotterT.plotTypes) || strcmpi(selected,'vertical')
        
                plotterT.barOrientation = selected;
                
            else
                nb_confirmWindow(['Are you sure you want to create a horizontal bar plot? '...
                    'You are currently using different plot types, which is not supported by the '...
                    'horizontal bar plot.'],{@notChangeBarOrientation,hObject},{@changeBarOrientation,gui,selected},...
                    'Bar Orientation');
                return
            end
              
        case 'barshadingcolor'
            
            endc  = nb_getGUIColorList(gui,parent);
            index = get(hObject,'value');
            color = endc{index};
            plotterT.barShadingColor = color;
            
        case 'barshadingdate'
            
            string             = get(hObject,'string');
            [newValue,message] = nb_interpretDateObsTypeInputGUI(plotterT,string);

            if ~isempty(message)
                nb_errorWindow(message);
                return
            end
            
            plotterT.barShadingDate = newValue;
            
        case 'barshadingobs'
            
            string             = get(hObject,'string');
            [newValue,message] = nb_interpretDateObsTypeInputGUI(plotterT,string);

            if ~isempty(message)
                nb_errorWindow(message);
                return
            end
            
            plotterT.barShadingObs = newValue;    
            
        case 'barshadingdirection'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.barShadingDirection = selected;
            
        case 'barwidth'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The bar width must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The bar width must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.barWidth = value;
            
        case 'sumto'
            
            string = get(hObject,'string');
            if isempty(string)
                value = []; 
            else
                
                value = str2double(string);
                if isnan(value)
                    nb_errorWindow(['The sum to property must be set to a number. Is ' string '.'])
                    return
                elseif value <= 0   
                    nb_errorWindow(['The sum to property must be set to a number greater then 0. Is ' string '.'])
                    return
                end
                
            end
            plotterT.sumTo = value;
            
        case 'candlewidth'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The candle width must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The candle width must be set to a number greater then 0. Is ' string '.'])
                return    
            end
            plotterT.candleWidth = value;
            
        case 'linewidth'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The line width must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The line width must be set to a number greater then 0. Is ' string '.'])
                return    
            end
            plotterT.lineWidth = value;
            
        case 'markersize'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The marker size must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The marker size must be set to a number greater then 0. Is ' string '.'])
                return    
            end
            plotterT.markerSize = value;
            
        case 'baseline'
            
            value = get(hObject,'value');
            plotterT.baseLine = value;
            if value
                set(gui.handle1,'enable','on');
                set(gui.handle2,'enable','on');
                set(gui.handle3,'enable','on');
                set(gui.handle4,'enable','on');
                set(gui.handlec,'enable','on');
            else
                set(gui.handle1,'enable','off');
                set(gui.handle2,'enable','off');
                set(gui.handle3,'enable','off');
                set(gui.handle4,'enable','off');
                set(gui.handlec,'enable','off');
            end
            
        case 'baselinecolor'
            
            endc  = nb_getGUIColorList(gui,parent);
            index = get(hObject,'value');
            color = endc{index};
            plotterT.baseLineColor = color;
            
        case 'baselinestyle'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.baseLineStyle = selected;
            
        case 'baselinewidth'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The base line width must be set to a number larger then 0. Is ' string '.'])
                return
            elseif value <= 0 
                nb_errorWindow(['The base line width must be set to a number larger then 0. Is ' string '.'])
                return
            end
            plotterT.baseLineWidth = value;
            
        case 'basevalue'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The base value must be set to a number. Is ' string '.'])
                return
            end
            plotterT.baseValue = value;
            
        case 'figuretitle'
            
            plotterT.figureTitle = get(hObject,'value');    
            
        case 'fontname'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.fontName = selected;
            
        case 'fontscale'
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            elseif value <= 0
                nb_errorWindow(['The font scale must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.fontScale = value;   
            
        case 'language'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.language = selected;
            
        case 'missingvalues'
            
            string   = get(hObject,'string');
            index    = get(hObject,'value');
            selected = string{index};
            plotterT.missingValues = selected;
            
            if strcmpi(selected,'both') || strcmpi(selected,'strip') 
                set(gui.handle5,'enable','on')
            else
                set(gui.handle5,'enable','off')
            end
            
        case 'scatterlinestyle'
            
            plotterT.scatterLineStyle = nb_getUIControlValue(hObject);
            
        case 'stopstrip'
           
            string             = get(hObject,'string');
            [newValue,message] = nb_interpretDateObsTypeInputGUI(plotterT,string);

            if ~isempty(message)
                nb_errorWindow(message);
                return
            end
            plotterT.stopStrip = newValue;
            
        case 'titlefontsize'
            
            if strcmpi(gui.plotter.graphStyle,'mpr_white')
                nb_errorWindow('It is not allowed to set the title font size property of an advanced graph.')
                set(hObject,'string',num2str(gui.plotter.titleFontSize));
                return
            end
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The title font size must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The title font size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.titleFontSize = value;
            
        case 'xlabelfontsize'
            
            if strcmpi(gui.plotter.graphStyle,'mpr_white')
                nb_errorWindow('It is not allowed to set the x-label font size property of an advanced graph.')
                set(hObject,'string',num2str(gui.plotter.xLabelFontSize));
                return
            end
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The x-axis label font size must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The x-axis label font size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.xLabelFontSize = value;
            
        case 'ylabelfontsize'
            
            if strcmpi(gui.plotter.graphStyle,'mpr_white')
                nb_errorWindow('It is not allowed to set the y-label font size property of an advanced graph.')
                set(hObject,'string',num2str(gui.plotter.yLabelFontSize));
                return
            end
            
            string   = get(hObject,'string');
            value    = str2double(string);
            if isnan(value)
                nb_errorWindow(['The y-axis label font size must be set to a number. Is ' string '.'])
                return
            elseif value <= 0   
                nb_errorWindow(['The y-axis label font size must be set to a number greater then 0. Is ' string '.'])
                return
            end
            plotterT.yLabelFontSize = value;
            
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
     
end

%==================================================================
% Callbacks
%==================================================================
function changeBarOrientation(hObject,~,gui,selected)

    gui.plotter.barOrientation = selected;

    % Notify listeners
    notify(gui,'changedGraph');
    
    % Close confirm window
    close(get(hObject,'parent'));

end

function notChangeBarOrientation(hObject,~,pop)

    % Set the selected value to 'Vertical'
    set(pop,'value',1);

    % Close confirm window
    close(get(hObject,'parent'));

end


