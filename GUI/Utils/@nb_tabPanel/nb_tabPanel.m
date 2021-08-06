classdef nb_tabPanel < nb_settable
% Description:
%
% A class for creating a tab panels.
%
% Superclasses:
%
% nb_settable, handle
%
% Constructor:
%
%   obj = nb_tabPanel(parent,varargin)
% 
%   Input:
%
%   - parent   : A figure or uipanel handle.
%
%   - varargin : Optional inputs given to the set method.
% 
%   Output:
% 
%   - obj      : An nb_tabPanel object.
% 
%   Examples:
%
%   h = nb_tabPanel();
%   set(h,'title',{'Tab1','Tab2','Tab3'}) 
% 
% See also:
% uipanel, nb_paddingPosition
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
        
        % Background color of listbox.
        backgroundColor             = [1,1,1];

        % Parent as a figure or uipanel handle.
        parent                      = [];
        
        % Position as a 1x4 double [left,bottom,width,height]. Given in
        % the units spesified by the units property. See also
        % nb_paddingPosition.
        position                    = [0,0,1,1];
        
        % The units the position property is set in. Default is 
        % 'normalized'.
        units                       = 'normalized';
        
        
    end

    properties

        % Background color of the active tab button. A 1x3 double with a
        % RGB color.
        activeBackgroundColor       = get(0,'defaultUicontrolBackgroundColor');

        % Border highligh color of the active tab button. A 1x3 double 
        % with a RGB color.
        activeHighlightColor        = [1,1,1];
        
        % Border title color of the active tab button. A 1x3 double with 
        % a RGB color.
        activeTitleColor            = [0,0,0];
        
        % Background color of the deactive tab buttons. A 1x3 double with a
        % RGB color.
        deactiveBackgroundColor     = get(0,'defaultUicontrolBackgroundColor')*0.9;
        
        % Border highligh color of the active tab button. A 1x3 double 
        % with a RGB color.
        deactiveHighlightColor      = [1,1,1];
        
        % Border title color of the active tab button. A 1x3 double with 
        % a RGB color.
        deactiveTitleColor          = [0,0,0];
        
        % Set to a 1 x obj.numberOfTabs logical. Set the element that you 
        % want to be temporarily removed to false.
        enable                      = [];
        
        % Set the margins of the tab panels. Also applies to the tab
        % buttons. In pixels. The margins must be set to a 1x2 double where
        % [horizontalMargin,verticalMargin]. Default is [1,1].
        margins                     = [2,2];
        
        % Tabs height in pixels. A scalar double.
        tabHeight                   = 20;
        
        % Background color of the tab panels. A 1x3 double with a RGB 
        % color. Default is [], i.e. use the default ui background color.
        %
        % Caution: If this color is set to non-empty, then you cannot 
        %          set the individual background colors of the different
        %          tabs without the risk of it being reset again!
        tabPanelsBackgroundColor    = [];
        
        % Tabs width in pixels. A scalar double.
        tabWidth                    = 60;
        
        % The titles of the tabs. This property set the number of tabs to 
        % add to the tab panel.
        %
        % Caution: If this property is reset, the old panels of the 
        % different tabs will be deleted!
        title                       = {};
        
    end

    properties (SetAccess=protected) 
   
        % Index of the active tab panel.
        activeIndex         = 1;
        
        % The number of tabs of the tab panel.
        numberOfTabs        = 0;
        
        % Handle to the uipanel. 
        panel               = [];
        
        % Handle to the tab panels.
        tabPanels           = [];
        
        % Handle to the text of each tab button.
        textHandles         = [];
        
        % Handle to the title panels.
        titlePanels         = [];
        
    end
    
    properties (SetAccess=protected,Dependent=true)
       
        % Position as a 1x4 double [left,bottom,width,height].
        positionInPixels 
        
    end
    
    properties (Access=protected) 
        
       
    end
    
    events
       
        % Event that is triggered if the user push a new tab button.
        selectionChange
        
    end
        
    methods
        
        function obj = nb_tabPanel(parent,varargin)
            
            if nargin < 1
                parent = figure();
            end
            if not(nb_isFigure(parent) || nb_isUipanel(parent))
                error([mfilename ':: The parent input must be a figure or uipanel handle.'])
            end
            makeGUI(obj,parent);
            set(obj,varargin{:});
            
        end
        
        %==================================================================
        % Get
        %==================================================================
        
        function value = get.backgroundColor(obj)
            value = get(obj.panel,'backgroundColor');
        end
        
        function value = get.parent(obj)
            value = get(obj.panel,'parent');
        end
        
        function value = get.position(obj)
            value = get(obj.panel,'position');
        end
        
        function value = get.positionInPixels(obj)
            set(obj.panel,'Units','pixels');
            value = get(obj.panel,'position');
            set(obj.panel,'Units',obj.units);
        end
        
        function value = get.units(obj)
            value = get(obj.panel,'units');
        end
        
        
        %==================================================================
        % Set
        %==================================================================
         
        function set.activeBackgroundColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The activeBackgroundColor property must be set to a RGB color.'])
            end
            obj.activeBackgroundColor = value;
            obj.update();
        end
        
        function set.activeHighlightColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The activeHighlightColor property must be set to a RGB color.'])
            end
            obj.activeHighlightColor = value;
            obj.update();
        end
        
        function set.activeTitleColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The activeTitleColor property must be set to a RGB color.'])
            end
            obj.activeTitleColor = value;
            obj.update();
        end
        
        function set.backgroundColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The backgroundColor property must be set to a RGB color.'])
            end
            set(obj.panel,'backgroundColor',value);
        end
        
        function set.deactiveBackgroundColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The deactiveBackgroundColor property must be set to a RGB color.'])
            end
            obj.deactiveBackgroundColor = value;
            obj.update();            
        end
        
        function set.deactiveHighlightColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The deactiveHighlightColor property must be set to a RGB color.'])
            end
            obj.deactiveHighlightColor = value;
            obj.update();
        end
        
        function set.deactiveTitleColor(obj,value)
            if isempty(value)
                value = get(0,'defaultUicontrolBackgroundColor');
            elseif ~nb_isRGB(value)
                error([mfilename ':: The deactiveTitleColor property must be set to a RGB color.'])
            end
            obj.deactiveTitleColor = value;
            obj.update();
        end
        
        function set.enable(obj,value)
            if ~islogical(value)
                error([mfilename ':: The enable property must be set to a logical vector with same length as the number of tabs of this panel.'])
            end
            obj.enable = value;
            setTabPosition(obj);   
        end
        
        function set.parent(obj,value)
            if ~not(isa(value,'figure') || isa(value,'uipanel'))
                error([mfilename ':: The parent property must set to a figure or a uipanel handle.'])
            end
            set(obj.panel,'parent',value);
        end
        
        function set.position(obj,value)
            if ~nb_sizeEqual(value,[1,4])
                error([mfilename ':: The position property must be given as a 1x4 double.'])
            end
            set(obj.panel,'position',value);
        end
        
        function set.tabPanelsBackgroundColor(obj,value)
            if ~nb_isRGB(value) && ~isempty(value)
                error([mfilename ':: tabPanelsBackgroundColor must be set to a RGB color.'])
            end
            obj.tabPanelsBackgroundColor = value;
            obj.update();            
        end
        
        function set.title(obj,value)
            if ~iscellstr(value)
                error([mfilename ':: The title property must be set to a cellstr.'])
            end
            obj.title = value(:);
            addTabs(obj);
        end
        
        function set.units(obj,value)
            set(obj.panel,'units',value);
        end
        
    end
    
    methods(Access=protected)
        
        function [ind,optStruct,opt] = interpretInputs(obj,opt)
            
            if obj.numberOfTabs == 0
                error([mfilename ':: This is a empty tab panel, and no children can be added.'])
            end
            
            indS      = cellfun(@isstruct,opt);
            optStruct = opt(indS);
            opt       = opt(~indS);
            [tab,opt] = nb_parseOneOptional('tab',1,opt{:});
            if nb_isOneLineChar(tab)
                ind = find(strcmpi(tab,obj.title));
                if isempty(ind)
                    error([mfilename ':: Cannot locate the tab with title ' tab])
                end
            elseif nb_isScalarInteger(tab)
                if tab < 1 || tab > obj.numberOfTabs
                    error([mfilename ':: When the ''tab'' input is given it must be in the set [1,' int2str(obj.numberOfTabs) '].'])
                end
                ind = tab;
            else
                error([mfilename ':: Bad value given to the ''tab'' options.'])
            end 
            
        end
        
        function update(obj) 
            
            if ~obj.doUpdate
                return
            end  
            if isempty(obj.tabPanels)
                return
            end
            
            % Set the active tab button properties
            set(obj.titlePanels(obj.activeIndex),...
                'backgroundColor',obj.activeBackgroundColor,...
                'highlightColor',obj.activeHighlightColor);
            set(obj.textHandles(obj.activeIndex),...
                'backgroundColor',obj.activeBackgroundColor,...
                'foregroundColor',obj.activeTitleColor);
            
            % Set the tab button properties
            tabIndexes    = 1:obj.numberOfTabs;
            indexDeactive = tabIndexes ~= obj.activeIndex;
            set(obj.titlePanels(indexDeactive),...
                'backgroundColor',obj.deactiveBackgroundColor,...
                'highlightColor',obj.deactiveHighlightColor);
            set(obj.textHandles(indexDeactive),...
                'backgroundColor',obj.deactiveBackgroundColor,...
                'foregroundColor',obj.deactiveTitleColor);
            
            % Set properties of the tab panels
            if ~isempty(obj.tabPanelsBackgroundColor)
                set(obj.tabPanels,...
                    'backgroundColor',obj.tabPanelsBackgroundColor);
            end
            
            % Update positions
            setTabPosition(obj); 
            
        end
        
        function makeGUI(obj,parent)
            
            if nb_oldGraphVersion()
                inp = struct('resizeFcn',@obj.sizeChangedCallback);
            else
                inp = struct('sizeChangedFcn',@obj.sizeChangedCallback);
            end
            
            obj.panel = uipanel(inp, ...
              'parent',parent, ...
              'units','normalized', ...
              'position',[0,0,1,1], ...
              'backgroundColor',get(0,'defaultUicontrolBackgroundColor'), ...
              'borderType','none', ...
              'visible','off');
        end
        
        function addTabs(obj)
            
            % Delete old handles
            set(obj.panel,'visible','off');
            if obj.numberOfTabs == 0
                try delete(obj.tabPanels); end %#ok<TRYNC>
                try delete(obj.textHandles); end %#ok<TRYNC>
                try delete(obj.titlePanels); end %#ok<TRYNC>
            end
            
            obj.numberOfTabs = length(obj.title);
            obj.tabPanels    = nb_gobjects(obj.numberOfTabs,1);
            obj.textHandles  = nb_gobjects(obj.numberOfTabs,1);
            obj.titlePanels  = nb_gobjects(obj.numberOfTabs,1);
            
            for ii = 1:obj.numberOfTabs
                
                obj.titlePanels(ii) = uipanel( ...
                    'backgroundColor',obj.deactiveBackgroundColor,...
                    'borderType','line',...
                    'parent',obj.panel, ...
                    'units','pixels', ...
                    'buttonDownFcn',@obj.tabHitCallback,...
                    'userData',ii);
                
                obj.textHandles(ii) = uicontrol( ...
                    'backgroundColor',obj.deactiveBackgroundColor,...
                    'parent',obj.titlePanels(ii), ...
                    'units','normalized', ...
                    'position',[0.05,0.05,0.9,0.9], ...
                    'style','text', ...
                    'string',obj.title{ii}, ...
                    'enable','inactive', ...
                    'hitTest','off');
                
                obj.tabPanels(ii) = uipanel( ...
                    'borderType','none',...
                    'parent',obj.panel, ...
                    'units','pixels', ...
                    'visible','off');
                
            end
            obj.activeIndex = 2; % Just set it to a number that is ~= 1
            
            % Position the tab buttons and panels
            obj.enable = true(1,obj.numberOfTabs);
            setTabPosition(obj);
            
            % Update the tab panel
            tabHitCallback(obj,obj.titlePanels(1),[]);
            
            % Make the full tab panel visible
            set(obj.panel,'visible','on');
            
        end
        
        function setTabPosition(obj)
            
            if ~nb_sizeEqual(obj.enable,[1,obj.numberOfTabs])
                warning('nb_tabPanel:enableSet2WrongValue',[mfilename ':: The ''enable'' property did not match the number of tabs. Reset to default.'])
                obj.enable = true(1,obj.numberOfTabs);
            end
            
            % Set the location of the tab buttons
            posInPixels = obj.positionInPixels;
            titlePos    = [0, posInPixels(4) - obj.tabHeight - obj.margins(2), ...
                           obj.tabWidth , obj.tabHeight];
            for ii = 1:obj.numberOfTabs  
                
                if obj.enable(ii)
                    titlePos(1) = titlePos(1) + obj.margins(1);
                    set(obj.titlePanels(ii),'position',titlePos); 
                    titlePos(1) = titlePos(1) + obj.margins(1) + obj.tabWidth;
                else
                    set(obj.titlePanels(ii),'visible','off');
                end
                
            end
            
            % Set the panel position
            panelPos = [0, 0, posInPixels(3), posInPixels(4) - obj.tabHeight - obj.margins(2)];
            set(obj.tabPanels,'position',panelPos); 
            
        end
        
        function tabHitCallback(obj,hObject,~)
            
            index = get(hObject,'userData');
            if obj.activeIndex == index
                return
            end
            
            % Deactive old tab
            set(obj.titlePanels(obj.activeIndex),'backgroundColor',obj.deactiveBackgroundColor);
            set(obj.textHandles(obj.activeIndex),'fontWeight','normal','backgroundColor',obj.deactiveBackgroundColor);
            
            % Activate new tab
            set(obj.titlePanels(index),'backgroundColor',obj.activeBackgroundColor);
            set(obj.textHandles(index),'fontWeight','bold','backgroundColor',obj.activeBackgroundColor);

            % Change active panel
            set(obj.tabPanels(obj.activeIndex),'visible','off'); 
            set(obj.tabPanels(index),'visible','on'); 
            
            % Store the active index
            obj.activeIndex = index;
            
            % Notify listeners
            notify(obj,'selectionChange');
            
        end
        
        function sizeChangedCallback(obj,~,~)
            setTabPosition(obj);
        end
        
    end
    
    methods (Static=true)
    
        function h = test()
            
            h = nb_tabPanel();
            set(h,'title',{'Tab1','Tab2','Tab3'});
            pause(1);
            set(h,'tabWidth',100);
            pause(1);
            set(h,'activeBackgroundColor',[1,1,1]);
            pause(1)
            set(h,'deactiveBackgroundColor',[0.5,0.5,0.5]);
            pause(1) 
            set(h,'tabPanelsBackgroundColor',[1,1,1]);
            pause(1)
            set(h,'backgroundColor',[1,1,1]);
            
        end
        
        function h = test2()
           
            h = nb_tabPanel();
            set(h,'title',{'Tab1','Tab2','Tab3'});
            
            uicontrol(h,'style','listbox','units','normalized','position',[0.1,0.1,0.2,0.7]);
            uicontrol(h,'style','edit','units','normalized','position',[0.1,0.1,0.2,0.7],'tab','Tab2');
            uicontrol(h,'style','edit','units','normalized','position',[0.1,0.1,0.2,0.7],'tab',3,'String','Hello!');
            
        end
        
        function h = test3()
            
            h = nb_tabPanel();
            set(h,'title',{'Tab1','Tab2','Tab3'});
            pause(1)
            set(h,'enable',[true,false,true]);
            
        end
        
    end
        
end
