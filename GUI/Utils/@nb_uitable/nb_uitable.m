classdef nb_uitable < handle
% Description:
%
% Create uitable with autmatically adjusted column width, as long as the 
% 'columnWidth' is not an argument.
%
% Constructor:
%
%   obj = nb_uitable(varargin)
% 
%   Input:
%
%   - varargin : Inputs given to the MATLAB uitable function.
% 
%   Output:
% 
%   - obj     : An nb_uitable object.
% 
% See also:
% uitable
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties 
        
        % Reference to the uitable handle object
        table           = [];
        
        % Check only the columnames when fitting the column width. True or
        % false. Default is false.
        columnNamesOnly = false;
        
    end
    
    methods
        
        function obj = nb_uitable(varargin)          
            interpretInputs(obj,varargin{:});
        end
        
        function set(obj,varargin)
            interpretInputs(obj,varargin{:});
        end
        
        function update(obj)
            
            data     = get(obj.table,'data');
            colNames = get(obj.table,'columnName');
            if ~isempty(data)
                cw = getMaxColumnWidth(obj,data,colNames);
                set(obj.table,'columnWidth',cw);
            end
            
        end
        
        function varargout = get(obj,varargin)
           
            [varargout{1:nargout}] = get(obj.table,varargin{:});
            
        end
            
    end
    
    methods(Access=protected)
        
        function interpretInputs(obj,varargin)
            
            if ~isempty(varargin)     
                if ishghandle(varargin{1})
                    varargin = ['parent',varargin];
                end
            end
            
            indCNO = strcmpi('columnNamesOnly',varargin);
            if any(indCNO)
                indCNO = find(indCNO);
                for ii = 1:length(indCNO)
                    obj.columnNamesOnly = varargin{indCNO(ii)+1};
                    varargin            = [varargin(1:indCNO(ii)-1),varargin(indCNO(ii)+2:end)];
                end
            end
                
            if isempty(obj.table) || ~ishandle(obj.table)
                obj.table = uitable(varargin{:});
                set(obj.table,'userdata',{obj});
            end
            
            indCW = strcmpi('columnWidth',varargin);
            ind   = find(strcmpi('data',varargin),1,'last');
            if ~any(indCW) && ~isempty(ind)
                
                data = varargin{ind+1};
                ind  = find(strcmpi('columnName',varargin),1,'last');
                if ~isempty(ind)
                    columnName = varargin{ind+1};
                else
                    columnName = get(obj.table,'columnName');
                end
                
                columnWidth = getMaxColumnWidth(obj,data,columnName);
                if ~isempty(columnWidth)
                    varargin = [varargin, {'columnWidth',columnWidth}];
                end
                
            end
            set(obj.table,varargin{:});
            
        end
        
        function maxColumnWidth = getMaxColumnWidth(obj,data,columnName)  
        
            if ischar(columnName)
                columnName = cellstr(columnName);
            end
            
            if size(columnName,1) > 1
                columnName = columnName';
            end
            
            if isnumeric(data)
                data = num2cell(data);
            end
            
            if length(columnName) ~= size(data,2)
                if ~isempty(columnName) && ~isempty(data) && ~strcmpi(columnName{1},'numbered')
                    maxColumnWidth = [];
                    return
                else
                    if isempty(data)
                        data = columnName;
                    end
                end
            else
                data = [columnName;data];
            end
            
            if isempty(data)
                maxColumnWidth = [];
                return
            end
            
            addExtra = false;
            if ~isempty(columnName)
                addExtra = true;
            end
            
            if obj.columnNamesOnly
                data = data(1,:);
            end
            
            % Parent to plot it
            parent = get(obj.table,'parent');
            if ~strcmpi(get(parent,'type'),'figure')
                parent = ancestor(parent,'figure');
                if isempty(parent)
                    error([mfilename ':: Cannot reach the parent figure...'])
                end
            end
                
            old      = get(obj.table,'units');
            set(obj.table,'units','pixels')
            pos      = get(obj.table,'position');
            set(obj.table,'units',old);
            fontSize = get(obj.table,'fontSize');
            ax       = axes('parent',parent,'visible','off','position',[0,0,1,1],...
                            'xLim',[pos(1),pos(1) + pos(3)],'yLim',[pos(2),pos(2) + pos(4)]);
            t        = text(pos(1) + pos(3)/2,pos(2) + pos(4)/2,'','visible','off','parent',ax,'units','data');
         
            % Max length of data for each column
            dataSize       = size(data);
            maxColumnWidth = zeros(1, dataSize(2));
            for i=1:dataSize(2)
                  for j = 1:dataSize(1)
                      
                      string = data{j,i};
                      if isnumeric(string) || islogical(string)
                          string = num2str(string);
                      end
                      
                      if j == 1 && addExtra
                          string    = [string,'XXXXXXXXX']; %#ok<AGROW> % This is not perfect for column names
                          fontSizeT = fontSize*1.2;
                      else
                          string = [string,'XXXX']; %#ok<AGROW>
                          fontSizeT = fontSize;
                      end
                      try
                          set(t,'string',string,'fontSize',fontSizeT)
                          drawnow();
                          extent = get(t,'extent');
                      catch
                          break
                      end
                      if extent(3) > maxColumnWidth(1,i)
                          maxColumnWidth(1, i) = extent(3);
                      end
                      
                  end
            end
            if ishandle(t)
                delete(t);
            end
            
            % Minimum length
            maxColumnWidth(maxColumnWidth < 40) = 40;

            % Output as cell array
            maxColumnWidth = num2cell(maxColumnWidth);
            
        end
        
    end
    
end
