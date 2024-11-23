classdef nb_createDispTable
% Description:
%
% Display properties or methods in groups with user defined headings.
%
% Constructor:
%
%   obj = nb_createDispTable(docObj,groups,remove,type)
% 
%   Input:
%
%   - See description on the corresponding property.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (Access=protected)
        
        % An object of any type.
        docObj  = []
        
        % A N x 2 cell array with how to group the different properties/
        % methods. First column gives the group name, while the second 
        % column must be a cellstr with the properties/methods of that 
        % group. All the non-group properties will be added to the group 
        % 'Other properties:' or 'Other methods:'.
        groups  = {};
        
        % Properties/methods which should not be displayed in the table, 
        % but is returned by the properties/methods method when called on  
        % the docObj property (of this class).
        remove  = {};
        
        % Type of disp, either 'properties' or 'methods'.
        type    = 'properties';
        
    end
    
    methods
        
        function obj = nb_createDispTable(docObj,groups,remove,type)
           obj.docObj = docObj; 
           obj.groups = groups;
           obj.remove = remove;
           obj.type   = type;
        end
        
        function obj = set.groups(obj,value)
            if size(value,2) ~= 2
                error([mfilename ': The groups property must have 2 columns.'])
            end
            if ~iscell(value)
                error([mfilename ': The groups property must be a cell array.'])
            end
            obj.groups = value;
        end
        
        function obj = set.remove(obj,value)
            if ~(iscell(value) || isempty(value))
                error([mfilename ': The remove property must be a cellstr array.'])
            end
            obj.remove = value(:);
        end
        
        function obj = set.type(obj,value)
            if ~nb_isOneLineChar(value) || ~ismember(lower(value),{'properties','methods'})
                error([mfilename ': The type property must be set to either ''properties'' or ''methods''.'])
            end
            obj.type = lower(value);
        end
            
        function disp(obj)
           
            typeFunc  = str2func(obj.type);
            className = class(obj.docObj);
            types     = typeFunc(obj.docObj);
            if ~isempty(obj.remove)
                types = setdiff(types,obj.remove);
            end
            typesHyperlink = cell(size(types));
            for ii = 1:length(types)
                typesHyperlink{ii} = ['<a href="matlab: nb_createDispTable.help(''' className ''',''',...
                                       types{ii} ''',''' obj.type ''')">' types{ii} '</a>'];
            end
            
            if isscalar(obj.docObj)
                if strcmp(obj.type,'properties')
                    dispFunc = @(x,y)dispWithValue(obj,x,y);
                    nCol     = 2;
                else
                    dispFunc = @(x,y)cellstr(x);
                    nCol     = 1;
                end
            else
                dispFunc = @(x,y)cellstr(x);
                nCol     = 1;
            end
            for ii = 1:size(obj.groups,1) 
                nb_createDispTable.dispOneGroup(obj.groups{ii,1},obj.groups{ii,2},nCol,dispFunc,types,typesHyperlink);
            end
            
            % Do we need to give the other properties?
            done = unique(nb_nestedCell2Cell(obj.groups(:,2)));
            ind  = ismember(types,done);
            left = types(~ind);
            if ~isempty(left)
                nb_createDispTable.dispOneGroup(['Other ' obj.type ':'],left,nCol,dispFunc,types,typesHyperlink);
            end
            
        end
        
    end
    
    methods (Access=protected)
       
        function out = dispWithValue(obj,typeHyperlink,type)
        
            out   = cell(1,2);
            value = obj.docObj.(type);
            if isempty(value)
                switch lower(class(value))
                    case 'double'
                        out{2} = '[]';
                    case 'cell'
                        out{2} = '{}';
                    case 'char'
                        out{2} = '''''';
                    case 'string'
                        out{2} = '""';
                    case 'nb_date'
                        out{2} = '''''';
                    otherwise
                        out{2} = nb_createLinkToClass(value);
                end
            elseif nb_isScalarLogical(value)
                if value
                    out{2} = 'true';
                else
                    out{2} = 'false';
                end
            elseif nb_isScalarNumber(value)
                out{2} = num2str(value);
            elseif isnumeric(value) && numel(value) < 5
                out{2} = nb_any2String(value);
            elseif nb_isOneLineChar(value)
                out{2} = ['''' value ''''];
            else
                out{2} = nb_createLinkToClass(value);
            end
            out{1} = [typeHyperlink,': '];
            
        end
            
    end
    
    methods (Static=true,Hidden=true)
       
        function help(className,typeName,type)
            
            disp(' ')
            if strcmpi(type,'properties')
                typeSingle = 'property';
            else
                typeSingle = 'method';
            end
            disp(['Help on the ' typeSingle ' ' typeName ':'])
            disp(' ')
            h = help([className '.' typeName]);
            h = regexprep(h,'Help for .+ is inherited from superclass .+$','');
            disp(h)
            
        end
        
    end
    
    methods (Static=true,Access=protected)
    
        function dispOneGroup(groupName,groupTypes,nCol,dispFunc,types,typesHyperlink)
            
            % Group heading
            disp(' ')
            disp(groupName)
            
            % Create table with properties for each group
            table = cell(length(groupTypes),nCol);
            for cc = 1:length(groupTypes)
                ind = strcmpi(groupTypes{cc},types);
                if ~any(ind)
                    error([mfilename ':: The following property/method is not a property/method ',...
                                     'of the class: ' groupTypes{cc}])
                end
                table(cc,:) = dispFunc(typesHyperlink{ind},groupTypes{cc});
            end
            if nCol > 1
                disp(nb_createDispTable.cell2charTable(table));
            else
                disp(char(table{:}))
            end
            
        end
        
        function tableAsChar = cell2charTable(table)
            
            temp = strrep(table(:,1),'<a href="matlab: help ','');
            temp = regexprep(temp,'">.+</a>','');
            dim  = nan(size(table,1),1);
            for ii = 1:size(table,1)
                dim(ii) = size(temp{ii},2) + 2;
            end
            dim = max(dim) - dim + 1;

            tableAsChar = '';
            for ii = 1:size(table,1)
                tableRow    = [blanks(dim(ii)),table{ii,1},table{ii,2}];
                tableAsChar = char(tableAsChar,tableRow);
            end
            tableAsChar = tableAsChar(2:end,:);
            
        end
        
    end
    
end
