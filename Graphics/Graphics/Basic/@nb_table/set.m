function set(obj, varargin)
% Syntax:
%
% set(obj, varargin)
%
% Description:
%
% Set properties of the nb_table class
% 
% Input:
% 
% - varargin : Property name property value pairs.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if size(varargin, 1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    for j = 1:2:size(varargin,2)

        if ischar(varargin{j})

            propertyName  = lower(varargin{j});
            propertyValue = varargin{j + 1};
            
            switch (propertyName)
                case 'backgroundcolor'    
                    setCellProperty('BackgroundColor', propertyValue);
                case 'color'
                    setCellProperty('Color', propertyValue);
                case 'dateformat'
                    if ~iscellstr(propertyValue) && ~ischar(propertyValue)
                        error([mfilename ':: Format must be set to a string or a cell of strings.'])
                    end
                    setCellProperty('DateFormat', propertyValue);    
                case 'decimals'
                    if ~isempty(propertyValue)
                        assert(all(ismember(propertyValue,[0,1,2,3,4,5,6,7,8,9])) || ischar(propertyValue), ...
                            'The property decimals must be in the set [0,1,2,3,4,5,6,7,8,9] or it must be a string that num2str can interpret.');
                    end
                    obj.decimals = propertyValue; 
                    set(obj,'string',obj.data); % Reformat the data
                case 'editing'
                    setCellProperty('Editing', propertyValue); 
                case 'fontname'
                    setCellProperty('FontName', propertyValue);    
                case 'fontsize'
                    setCellProperty('FontSize', propertyValue);   
                case 'fontunits'
                    setCellProperty('FontUnits', propertyValue);      
                case 'fontweight'
                    assertCellPropertyMembership(propertyValue, ...
                        {[], 'normal', 'bold'}, ...
                        'Font weight must be ''normal'' or ''bold''.');
                    setCellProperty('FontWeight', propertyValue);
                case 'horizontalalignment'
                    assertCellPropertyMembership(propertyValue, ...
                        {[], 'left', 'center', 'right'}, ...
                        'Horizontal alignment must be ''left'', ''center'' or ''right''.');
                    setCellProperty('HorizontalAlignment', propertyValue);
                case 'language'
                    if ischar(propertyValue)
                        if ismember(propertyValue,{'english','norwegian','norsk','engelsk'})
                            obj.language = propertyValue;
                        else
                            error([mfilename ':: The ''language'' property cannot be set to ' propertyValue '.'])
                        end
                    else
                        error([mfilename ':: The ''language'' property must be set to a string.'])
                    end
                case 'verticalalignment'
                    assertCellPropertyMembership(propertyValue, ...
                        {[], 'top', 'cap', 'middle', 'baseline', 'bottom'}, ...
                        'Vertical alignment must be ''top'', ''cap'', ''middle'', ''baseline'' or ''bottom''.');
                    setCellProperty('VerticalAlignment', propertyValue);
                case 'interpreter'
                    assertCellPropertyMembership(propertyValue, ...
                        {[], 'none', 'latex', 'tex'}, ...
                        'Interpreter must be ''none'', ''latex'' or ''tex''.');
                    setCellProperty('Interpreter', propertyValue);    
                case 'margin'
                    assert(all(...
                        isnumeric([propertyValue{:}])), ...
                        'Margin width must be numeric');
                    setCellProperty('Margin', propertyValue);
                case 'string'
                    String = toCellString(propertyValue, obj.decimals);
                    updateCells(obj, size(String));
                    setCellProperty('String', String);
                    obj.data = propertyValue;
                case 'bordertop'
                    if iscell(propertyValue)
                        assert(all(...
                            isnumeric([propertyValue{:}])), ...
                            'Border top must be numeric');
                    else
                        assert(isnumeric(propertyValue), ...
                            'Border top must be numeric');
                    end
                    setCellProperty('BorderTop', propertyValue);
                    setCellProperty('BorderBottom', ...
                        [obj.BorderTop(2:end, :); obj.BorderBottom(end, :)]);
                case 'borderleft'
                    if iscell(propertyValue)
                        assert(all(...
                            isnumeric([propertyValue{:}])), ...
                            'Border left must be numeric');
                    else
                        assert(isnumeric(propertyValue), ...
                            'Border left must be numeric');
                    end
                    setCellProperty('BorderLeft', propertyValue);
                    setCellProperty('BorderRight', ...
                        [obj.BorderLeft(:, 2:end), obj.BorderRight(:, end)]);
                case 'borderright'
                    
                    if iscell(propertyValue)
                        assert(all(...
                            isnumeric([propertyValue{:}])), ...
                            'Border right must be numeric');
                    else
                        assert(isnumeric(propertyValue), ...
                            'Border right must be numeric');
                    end
                    
                    setCellProperty('BorderRight', propertyValue);
                    setCellProperty('BorderLeft', ...
                        [obj.BorderLeft(:, 1), obj.BorderRight(:, 1:end-1)]);
                case 'borderbottom'
                    if iscell(propertyValue)
                        assert(all(...
                            isnumeric([propertyValue{:}])), ...
                            'Border bottom must be numeric');
                    else
                        assert(isnumeric(propertyValue), ...
                            'Border bottom must be numeric');
                    end

                    setCellProperty('BorderBottom', propertyValue);
                    setCellProperty('BorderTop', ...
                        [obj.BorderTop(1, :); obj.BorderBottom(1:end-1, :); ]);
                case 'columnspan'
                    assert(all(...
                        nb_iswholenumber([propertyValue{:}]) & ...
                        [propertyValue{:}] >= 1), ...
                        'Column span must be a positive integer');
                    assert(all(...
                        [propertyValue{:, end}] == 1), ...
                        'Cells in last column cannot span multiple columns');
                    
                    setCellProperty('ColumnSpan', propertyValue);
                case 'rowspan'
                    assert(all(...
                        nb_iswholenumber([propertyValue{:}]) & ...
                        [propertyValue{:}] >= 1), ...
                        'Column span must be a positive integer');
                    assert(all(...
                        [propertyValue{end, :}] == 1), ...
                        'Cells in last row cannot span multiple rows');
                    
                    setCellProperty('RowSpan', propertyValue);
                    
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

    % Update
%     if obj.updateOnChange
%         obj.update();
%     end
    
    % Helper functions
    function setCellProperty(propertyName, propertyValue)
        
        if isscalar(propertyValue) && ~iscell(propertyValue) || ...
                and(ischar(propertyValue),nb_sizeEqual(propertyValue,[1,nan]))
            propertyValue = {propertyValue};
            propertyValue = propertyValue(ones(obj.size));
        else
            assert(...
                all(size(propertyValue) == obj.size), ...
                'Property value size must match table size');
        end
        [obj.cells.(propertyName)] = propertyValue{:};
        
    end

end

function cellString = toCellString(value,precision)

    cellString = cell(size(value));
    if isempty(precision)
        converter = @(x)num2str(x);
    else
        converter = @(x)nb_num2str(x,precision);
    end
    
    for ii = 1:size(value,1)
        for jj = 1:size(value,2)
            if ischar(value{ii,jj}) || iscellstr(value{ii,jj})
                cellString{ii,jj} = cellstr(value{ii,jj});
            else
                if isnan(value{ii,jj})
                    cellString{ii,jj} = {''};
                else
                    cellString{ii,jj} = cellstr(converter(value{ii,jj}));
                end
            end
        end
    end
    
end

function assertCellPropertyMembership(propertyValue, values, errorMsg)

    values = cellfun(@num2str, values, 'UniformOutput', false);
    
    if iscell(propertyValue)
        propertyValue = cellfun(@num2str, propertyValue, 'UniformOutput', false);
        propertyValue = propertyValue(:);
    else
        propertyValue = num2str(propertyValue);
    end

    assert(all(...
        ismember(lower(propertyValue), ...
        lower(values))), ...
        errorMsg);
    
end
