function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj, propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_table
% 
% Input:
% 
% - obj           : An object of class nb_table
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('children');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch lower(propertyName)

        case 'allowdimensionchange'
           propertyValue = obj.allowDimensionChange;
        case 'deleteoption'
            propertyValue = obj.deleteOption;   
        case 'language'
            propertyValue = obj.language;
        case 'parent'
            propertyValue = obj.parent;
        case 'side'
            propertyValue = obj.side; 
        case 'type'
            propertyValue = obj.type;
        case 'bordercolor'
           propertyValue = obj.BorderColor;
        
        % Dependent properties
        case 'size'
            propertyValue = size(obj.cells);
        case 'children'
            handlesStruct = struct([obj.cells.graphicHandles]);
            handlesCell = struct2cell(handlesStruct);
            handles = [handlesCell{:}];
            
            % Don't add 'inherited' context menu
            if isempty(obj.defaultContextMenu)
               handles = [handles, obj.contextMenu];
            else
                handles = [handles, ...
                    obj.contextMenuAdd, obj.contextMenuDelete, ...
                    obj.contextMenuFormat, obj.contextMenuTemplate];
            end
            
            propertyValue = handles;
        case 'color'
           propertyValue = getCellProperty('Color'); 
        case 'backgroundcolor'
           propertyValue = getCellProperty('BackgroundColor'); 
        case 'editing'
           propertyValue = getCellProperty('Editing');   
        case 'fontname'
           propertyValue = getCellProperty('FontName');
        case 'fontsize'
           propertyValue = getCellProperty('FontSize'); 
        case 'fontunits'
           propertyValue = getCellProperty('FontWeight');   
        case 'fontweight'
           propertyValue = getCellProperty('FontWeight');  
        case 'dateformat'
           propertyValue = getCellProperty('DateFormat');  
        case 'horizontalalignment'
           propertyValue = getCellProperty('HorizontalAlignment');
        case 'verticalalignment'
           propertyValue = getCellProperty('VerticalAlignment');
        case 'interpreter'
           propertyValue = getCellProperty('Interpreter');     
        case 'margin'
           propertyValue = getCellProperty('Margin'); 
        case 'string'
           propertyValue = getCellProperty('String');  
        case 'bordertop'
           propertyValue = getCellProperty('BorderTop'); 
        case 'borderleft'
           propertyValue = getCellProperty('BorderLeft'); 
        case 'borderright'
           propertyValue = getCellProperty('BorderRight'); 
        case 'borderbottom'
           propertyValue = getCellProperty('BorderBottom'); 
        case 'columnspan'
           propertyValue = getCellProperty('ColumnSpan'); 
        case 'rowspan'
           propertyValue = getCellProperty('RowSpan'); 
        case 'defaultcontextmenu'
           propertyValue = obj.defaultContextMenu;    
        otherwise
            error([mfilename ':: Bad property name; ' propertyName])

    end

    % Helper function
    function values = getCellProperty(propertyName)
        values = {obj.cells.(propertyName)};
        values = reshape(values, obj.size);
    end
end


        
             
        
