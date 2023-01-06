function set(obj, varargin)
% Syntax:
%
% set(obj, varargin)
%
% Description:
%
% Set properties of the nb_plotLabels class
% 
% Input:
% 
% - varargin : Property name property value pairs.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(varargin, 1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    for j = 1:2:size(varargin,2)

        if ischar(varargin{j})

            propertyName  = lower(varargin{j});
            propertyValue = varargin{j + 1};
            
            switch (propertyName)
                case 'backgroundcolor'    
                    obj.formatAll.backgroundColor = propertyValue;
                case 'color'
                    obj.formatAll.color = propertyValue;
                case 'decimals'
                    if ~isempty(propertyValue)
                        assert(ismember(propertyValue,[0,1,2,3,4]), ...
                            'The property decimals must be in the set [1,2,3,4,5,6,7,8,9].');
                    end
                    obj.formatAll.decimals = propertyValue; 
                case 'fontname'
                    obj.formatAll.fontName = propertyValue;  
                case 'fontsize'
                    obj.formatAll.fontSize = propertyValue;  
                case 'fontunits'
                    assert(any(ismember(propertyValue,{'points', 'normalized', 'inches','centimeters'})), ...
                        'fontUnits must be ''points'', ''normalized'', ''inches'' or ''centimeters''.');
                    oldFontUnits  = obj.fontUnits;
                    obj.fontUnits = propertyValue;
                    setFontSize(obj,oldFontUnits)   
                case 'fontweight'
                    assert(any(ismember(propertyValue,{'normal', 'bold'})), ...
                        'Font weight must be ''normal'' or ''bold''.');
                    obj.formatAll.fontWeight = propertyValue;   
                case 'formatall'
                    if isstruct(propertyValue)
                        obj.formatAll = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a struct. See nb_plotLabels.getDefaultFormat'])
                    end
                case 'formatcells'
                    if iscell(propertyValue)
                        obj.formatCells = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a cell array of structs. See nb_plotLabels.getDefaultFormat '...
                                         'for the format of the struct elements.'])
                    end    
                case 'formatcolumns'
                    if iscell(propertyValue)
                        obj.formatColumns = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a cell array of structs. See nb_plotLabels.getDefaultFormat '...
                                         'for the format of the struct elements.'])
                    end  
                case 'formatrows'
                    if iscell(propertyValue)
                        obj.formatRows = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a cell array of structs. See nb_plotLabels.getDefaultFormat '...
                                         'for the format of the struct elements.'])
                    end
                case 'horizontalalignment'
                    assert(any(ismember(propertyValue,{'left', 'center', 'right'})), ...
                        'Horizontal alignment must be ''left'', ''center'' or ''right''.');
                    obj.formatAll.horizontalAlignment = propertyValue;    
                case 'interpreter'
                    assert(any(ismember(propertyValue,{'none', 'latex', 'tex'})), ...
                        'Interpreter must be ''none'', ''latex'' or ''tex''.');
                    obj.formatAll.interpreter = propertyValue; 
                case 'language'
                    if ischar(propertyValue)
                        obj.language = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end  
                case 'location'
                    if ischar(propertyValue)
                        obj.formatAll.location = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end 
                case 'normalized'
                    if ismember(propertyValue,{'axes','figure'})
                        obj.normalized = propertyValue;
                    else
                        error([mfilename ':: The input after the ''normalized'' property must be a string with either ''axes'' or ''figure''.'])
                    end    
                case 'margin'
                    assert(isnumeric(propertyValue),'Margin width must be numeric');
                    obj.formatAll.margin = propertyValue;         
                case 'parent'
                    
                    if ~isa(propertyValue,'nb_axes') && ~isempty(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be an nb_axes object.'])
                    end
                    if ~isempty(obj.parent)
                        if isvalid(obj.parent)
                            removeAnnotation(obj.parent,obj);
                        end
                    end
                    obj.parent = propertyValue;
                    if ~isempty(obj.parent)
                        addAnnotation(obj.parent,obj); 
                    end
                    
                case 'rotation'
                    if isscalar(propertyValue)
                        obj.formatAll.rotation = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a 1x1 double.']) 
                    end
                case 'space'
                    if isnumeric(propertyValue)
                        obj.formatAll.space = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a number.']) 
                    end     
                case 'verticalalignment'
                    assert(any(ismember(propertyValue,{'top', 'cap', 'middle', 'baseline', 'bottom'})), ...
                        'Vertical alignment must be ''top'', ''cap'', ''middle'', ''baseline'' or ''bottom''.');
                    obj.formatAll.verticalAlignment = propertyValue;
                otherwise
                    try
                        obj.(propertyName) = propertyValue;
                    catch Err
                        props = properties(obj);
                        ind   = find(strcmpi(propertyName,props),1);
                        if ~isempty(ind)
                            obj.(props{ind}) = propertyValue;
                        else
                            rethrow(Err)
                        end
                    end
            end

        end

    end
    
    if isa(obj.parent,'nb_axes')
        if ishandle(obj.parent.axesLabelHandle)
            plot(obj);
        end
    end

end
