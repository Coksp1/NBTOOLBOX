classdef nb_dockedPanel < handle
% Description:
%
% Create a panel where the added uicontrol objects are vertical
% align at maximum size. 
%
% Each component can be minimized as long as the 'titleStyle'
% property is not set to 'text'.
%
% Constructor:
%
%   obj = nb_dockedPanel(varargin)
% 
%   Input:
%
%   - varargin : Inputs given to the MATLAB uipanel function.
%
%                Extra properties :
%
%                - 'titleStyle' : Title placed on top of the ui
%                                 components.
% 
%   Output:
% 
%   - obj     : An nb_dockedPanel object.
% 
%   Examples:
%
%   h = nb_dockedPanel('titleStyle','pushbutton');
%   uicontrol(h,'style','listbox',...
%               'title','Test');
%   uicontrol(h,'style','listbox',...
%               'title','Test'); 
%   uicontrol(h,'style','listbox',...
%               'title','Test');  
% 
% See also:
% uipanel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected) 
    % Should make some of these properties settable??
       
        % Number of added children
        numberOfChildren = 0;
    
        % Handle to the uipanel component
        panel           = [];
         
        % Titles of the added ui components
        titles          = {};
        
        % The type of title. Either 'radiobutton', 'pushbutton' 
        % or 'text'.
        titleStyle      = 'radiobutton';
        
    end
    
    properties (Dependent=true)
       
        % The added uicontrol components
        children        = [];
        
        % The parent of the panel
        parent          = [];
        
        % The position of the panel
        position        = [];
        
    end
    
    properties(Access=protected,Hidden=true)
        
        % Docking indicator for the uicompnents
        docked          = [];
        
    end
    
    properties(Access=protected,Constant=true,Hidden=true)
        
        % Height of docked ui components
        minimizedSize   = 0.0001;
        
        % Space between the ui components
        space           = 0.02;
        
    end
    
    events
       
        % Event triggered when a ui component is added
        addedUIComponent
        
        % Event triggeres when a ui component is beeing docked
        % undocked
        changedUIComponentState
        
    end
    
    methods
        
        function obj = nb_dockedPanel(varargin)
            
            % Parse extra properties
            titleStyleT = 'radiobutton';
            ind        = find(strcmpi('titleStyle',varargin),1);
            if ~isempty(ind)
                titleStyleT = varargin{ind + 1};
                varargin   = [varargin(1:ind-1),varargin(ind+2:end)];
            end
            obj.titleStyle = titleStyleT;
            
            % Create MATLAB panel
            obj.panel = uipanel(varargin{:});
       
            % Set the resize behavioral of the panel
            set(obj.panel,'units',      'normalized',...
                          'resizeFcn',  @obj.resizeCallback);
            
        end
        
        function children = get.children(obj)
            
            children = get(obj.panel,'children');
            
        end
        
        function parent = get.parent(obj)
            
            parent = get(obj.panel,'parent');
            
        end
        
        function position = get.position(obj)
            
            position = get(obj.panel,'position');
            
        end
         
    end
    
    methods(Access=protected)
        
        function locateChildren(obj)
            
            % Get the size of the titles in normalized units
            childs = get(obj.panel,'children');
            if isempty(childs)
                return
            end
            
            uih      = childs(1);
            oldUnits = get(uih,'units');
            set(uih,'units','normalized');
            pos      = get(uih,'position');
            heightT  = pos(4);
            set(uih,'units',oldUnits);
            
            % Get the height of the different components
            numberOfDockedUI   = sum(obj.docked);
            numberOfUndockedUI = obj.numberOfChildren - numberOfDockedUI;
            totalTextHeight    = obj.numberOfChildren*heightT;
            totalSpace         = (obj.numberOfChildren + 1)*obj.space;
            undockedSize       = (1 - totalTextHeight - totalSpace)/numberOfUndockedUI; 
            
            currentPosition = 0;
            for ii = 1:obj.numberOfChildren
                
                currentPosition = currentPosition + obj.space;
                if ~obj.docked(end - ii + 1)
                   
                    child           = childs(ii*2);
                    pos             = get(child,'position');
                    newPos          = pos;
                    newPos(4)       = undockedSize;
                    newPos(2)       = currentPosition;
                    set(child,'position',newPos);
                    currentPosition = currentPosition + undockedSize + heightT;
                    
                else
                    
                    child           = childs(ii*2);
                    pos             = get(child,'position');
                    newPos          = pos;
                    newPos(2)       = currentPosition - obj.minimizedSize;
                    set(child,'position',newPos);
                    currentPosition = currentPosition + heightT;
                    
                end
                
            end
            
            % Reposition the titles
            repositionTitles(obj)
            
        end
        
        function dockCompnent(obj,~,~,id)
            
            % Get the handle to the ui component to dock
            childs = get(obj.panel,'children');
            uih    = childs(end - id*2 + 2);
            
            if obj.docked(id)
            
                % The component will be enlarged later
                set(uih,'visible','on');
                
            else
                
                pos      = get(uih,'position');
                pos(4)   = obj.minimizedSize;
                set(uih,'visible','off','position',pos);
            
            end
            obj.docked(id) = ~obj.docked(id);
            
            % Relocate the ui components
            locateChildren(obj);
            
            % Trigger event
            notify(obj,'changedUIComponentState',nb_additionalNumberEvent(id));
            
        end
        
        function resizeCallback(obj,~,~)
           
            locateChildren(obj)
            
        end
        
        function repositionTitles(obj)
            
            % Reposition the titles of the ui components
            childs = get(obj.panel,'children');
            for ii = 1:2:length(childs)
                
                uih      = childs(ii+1);
                oldUnits = get(uih,'units');
                set(uih,'units','characters');
                pos      = get(uih,'position');
                tPos     = [pos(1),pos(2)+pos(4),pos(3),1.25];
                set(uih,'units',oldUnits);
                set(childs(ii),'position',tPos);
                
            end
            
        end
        
    end
    
end
