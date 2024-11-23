classdef nb_graph_adv < matlab.mixin.Copyable 
% Syntax:
%     
% obj = nb_graph_adv(plotter,varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a class for making graphs with figure titles and footers. 
% (MPR styled graphs)
%
% Objects of this class can be given to an object of class
% nb_graph_package to create a graph package. 
%     
% Constructor:
%     
%     obj = nb_graph_adv(plotter,varargin)
%     
%     Input:
% 
%     - plotter  : An object of class nb_graph.
% 
%     - varargin : 'propertyName',propertyValue,...
% 
%     Output:
% 
%     - obj      : An object of class nb_graph_adv
%     
%     Examples:
% 
%     data       = nb_ts('test');
%     plotter    = nb_graph_ts(data);
%     advPlotter = nb_graph_adv(plotter,'figureTitleNor',...
%                               'A title','footerNor','A footer');   
% 
%     or   
% 
%     advPlotter = nb_graph_adv(plotter,'figureTitleNor',...
%                               char('A title','A new line'),...
%                               'footerNor',...
%                               char('A footer','A new line'));
% 
%     or     
% 
%     advPlotter = nb_graph_adv(plotter,'figureTitleNor',...
%                               {'A title','A ne line'},...
%                               'footerNor',...
%                               {'A footer','A new line'});   
%
% See also:
% nb_figureTitle, nb_footer, nb_graph_ts, nb_graph_cs, nb_ts, nb_cs
% nb_graph_package
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties
        
        % Save PDF to A4 portrait format. 0 or 1
        a4Portrait              = 0;
        
        % Overrun the chapter property of the nb_graph_package it is
        % included in. Default is [], i.e. use the chapter of the 
        % nb_graph_package. Must be set to a number.
        chapter                 = [];
        
        % Sets the figure counter to this number when included in a 
        % nb_graph_package object. Nice property to have if some 
        % graphs of the package is created with other tools. Must be 
        % a scalar. 
        counter                 = [];
        
        % Set to true to add Figur 1 to the first line of figureTitleNor
        % and Graph 1 to figureTitleEng.
        defaultFigureNumbering  = false;
        
        % Depricated
        excelFooterEng          = '';
        
        % Depricated
        excelFooterNor          = '';
        
        % Sets the english name of the figure. This name will be 
        % used on the englisg index page of the excel spreadsheet.
        figureNameEng           = '';
        
        % Sets the norwegian name of the figure. This name will be 
        % used on the norwegian index page of the excel 
        % spreadsheet.
        figureNameNor           = '';
        
        % Sets the alignment of the figure title. As a string. 
        % Either  'left', 'center' or 'right'. 'left' is default.
        figureTitleAlignment    = 'left';
        
        % Sets the english figure title of the graph. Either a  
        % string ('A figure title'), char (char('A figure title',
        % 'A new line')) or a cellstr ({'A figure title',
        % 'A new line'})
        %
        % 6 lines of the figure title is supported.
        figureTitleEng          = '';
        
        % Sets the figure title font size. 0.0511 
        % is default.
        figureTitleFontSize     = 0.0511;
        
        % Sets the figure title font weight. Must be a string.   
        % Either 'bold', 'light', 'normal' or 'demi'. 'normal' is 
        % default
        figureTitleFontWeight   = 'normal';
        
        % Sets the interpreter of the figure title text. Must be a 
        % string. Either 'latex' (mathematical expressions), 'tex' 
        % (Normal latex interpreter) or 'none' (No interpeter). 
        % Default is 'tex'.
        figureTitleInterpreter  = 'tex';
        
        % Sets the norwegian figure title of the graph. Either a 
        %  string ('A figure title'), char (char('A figure title',
        % 'A new line')) or a cellstr ({'A figure title',
        % 'A new line'})
        %
        % 6 lines of the figure title is supported.
        figureTitleNor          = '';
        
        % Sets where to place the figure title in the x-axis   
        % direction, either 'center', 'leftaxes', 'right' or the  
        % default value 'left'.
        figureTitlePlacement    = 'left';
        
        % Wrap text of figure title automatic. Default is false, i.e. no 
        % wrapping.
        figureTitleWrapping     = false;
          
        % For some reason the graph is sometimes flipped and sometimes not.
        % If the graph is flipped use this property to flip it back.
        flip                    = 0;
        
        % Sets the font name used for the text of graph. As a 
        % string. Default is 'arial'.
        fontName                = 'Arial';
        
        % Sets the font units of all the fonts of the graph. Either
        % {'points'} | 'normalized' | 'inches' |  'centimeters'. 
        % Default is 'points'.
        % 
        % Caution : If you set the fontUnits property in a method call
        %           to the set method, all the font properties set 
        %           before the fontUnits property will be set in the
        %           old fontUnits, while all the font properties set 
        %           after will be in the new fontUnits.
        % 
        % Caution : When the legType is set to 'MATLAB' this property
        %           will not set the font units of the legend.
        % 
        % Caution : Don't use this property in combination with one of 
        %           the graph styles defined by this class. I.e.
        %           'mpr', 'mpr_white', 'presentation' and 
        %           'presentation_white' They will set this property 
        %           to 'normalized'.
        % 
        % Caution : 'normalized' font units must be between 0 and 1.
        %           The normalized units are not the same as the MATLAB
        %           normalized units. This normalized units are not
        %           only normalized to the axes size, but also across
        %           resolution of the screen. (But only vertically)
        fontUnits               = 'normalized';
        
        % Sets the english footer of the graph. Either a string 
        % ('A footer'), char (char('A footer','A new line')) or   
        % a cellstr ({'A footer','A new line'})
        %
        % 6 lines of the footer is supported.
        footerEng               = '';
        
        % Sets the norwegian footer of the graph. Either a string 
        % ('A footer'), char (char('A footer','A new line')) or a  
        % cellstr ({'A footer','A new line'})
        %
        % 6 lines of the footer is supported.
        footerNor               = '';
        
        % Sets the alignment of the footer. As a string. Either 
        % 'left', 'center' or 'right'. 'left' is default.
        footerAlignment         = 'left';
        
        % Sets the footer font size. 0.0397 is default.
        footerFontSize          = 0.0397;
        
        % Sets the footer font weight. Must be a string. Either  
        % 'bold', 'light', 'normal' or 'demi'. 'normal' is default.
        footerFontWeight        = 'normal';
        
        % Sets the interpreter of the footer text. Must be a string.
        % Either 'latex' (mathematical expressions), 'tex' (Normal 
        % latex interpreter) or 'none' (No interpeter). Default is 
        % 'tex'.
        footerInterpreter       = 'tex';
        
        % Sets where to place the footer in the x-axis direction, 
        % either 'center', 'leftaxes', 'right' or the default 
        % value 'left'.
        footerPlacement         = 'left';
        
        % Wrap text of footer automatic. Default is false, i.e. no 
        % wrapping.
        footerWrapping          = false;

        % Sets from where to color the text of the excel output 
        % file as forecast. Either a string with the date  
        % ('2012Q1') or a cellstr ({'Var1','2012Q1','Var2',
        % '2012Q2'}).
        forecastDate            = {};
        
        % Sets from where to color the text of the excel output 
        % file as forecast. Either a cellstr with the types which
        % is "forecast".
        forecastTypes           = {};
        
        % Sets the number of graphs the counter should jump. As a 
        % scalar. Default is 1.
        jump                    = 1;
        
        % Sets the english legends of the produced graph. I.e. overrun
        % the legends property of the given nb_graph_ts or nb_graph_cs 
        % object. Must be a cellstr. I.e. {'legend1','legend2'}
        %
        % Caution : This will set the legAuto property of the 
        %           nb_graph_ts or nb_graph_cs object to 'off'. I.e.
        %           You must also provided the legends for the 
        %           patches and fake legends by this property. See  
        %           the documentation of the nb_graph_ts or 
        %           nb_graph_cs for more on the legAuto property.
        legendsEng              = {};
        
        % Give 1 if the graph should be "numbered" with a letter 
        % instead of an number. I.e. 'Figur 1.1a' or 'Chart 1.1a'.
        % Default is 0 (Numbering the graph as 'Figur 1.1' or 
        % 'Chart 1.1')
        letter                  = 0;
        
        % Restart letter counting. {0} (false) | 1 (true).
        letterRestart           = 0;
        
        % A handle to an nb_struct object storing the local 
        % variables
        localVariables          = [];
        
        % Sets the number of the graph. As a scalar. E.g. 'Figure 1'
        % or 'Chart 1' if the number property is set to 1.
        number                  = [];
        
        % Sets the underlying graph object. Must be of class 
        % nb_graph_ts, nb_graph_cs, nb_graph_data, nb_table_ts, nb_table_cs
        % nb_table_data or nb_table_cell.
        plotter                 = [];
        
        % When included in a nb_graph_package object this property will 
        % overrun the nb_graph_package.roundoff property if not empty. Must  
        % be an integer greater or equal to 0, or empty (uses the property
        % of the package). Default is empty.
        roundoff                = [];  
        
        % Sets the variables which can not be published. I.e. will 
        % not written to the excel output file. Must be a cellstr. 
        % E.g. {'Var1','Var2',...}.
        remove                  = {};
        
        % Sets the savename of the saved output file. Mainly used 
        % by the nb_graph_package class. Must be a string.
        saveName                = '';
        
        % Text to be displayed as a tooltip with technical comments when 
        % reading electronic report. If empty, excel footer is used when 
        % writing text. English.
        tooltipEng              = '';
        
        % Text to be displayed as a tooltip with technical comments when 
        % reading electronic report. If empty, excel footer is used when
        % writing text. Norwegian.
        tooltipNor              = '';     
        
        % Boolean indicating whether to wrap the tooltip. Default is false.
        tooltipWrapping         = false;
        
        % User data, can be set to anything you want.
        userData                = '';
        
    end
    
    properties (Hidden=true)
        
        % Used by nb_graphGUI, when a nb_graphAdv object is consisting of
        % a 1 x 2 panel of graphs. 
        currentGraph            = 1;
        
    end
    
    properties (Access=protected,Hidden=true)
       
 
    end
    
    events
        
        titleOrFooterChange
        updatedGraph
         
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function obj = nb_graph_adv(plotter,varargin)
            
            if nargin == 0
                return
            end
        
            if isa(plotter,'nb_graph_obj') 
                obj.plotter = plotter;
            else
                error([mfilename ':: The first input must be an object of class nb_graph_obj, but is of class ' class(plotter)])
            end
            
            % Assign the figure title/footer objects
            figTit           = nb_figureTitle();   
            figTit.fontSize  = obj.figureTitleFontSize; 
            figTit.fontUnits = obj.fontUnits;         
            obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
            
            figTit           = nb_figureTitle();    
            figTit.fontSize  = obj.figureTitleFontSize; 
            figTit.fontUnits = obj.fontUnits;
            obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
            
            foo           = nb_footer();   
            foo.fontSize  = obj.footerFontSize; 
            foo.fontUnits = obj.fontUnits;
            obj.plotter(1).setSpecial('footerObjectNor',foo);
            
            foo           = nb_footer();    
            foo.fontSize  = obj.footerFontSize; 
            foo.fontUnits = obj.fontUnits;
            obj.plotter(1).setSpecial('footerObjectEng',foo);
            
            % Parse the optional inputs
            obj.set(varargin{:});
            
        end
        
        varargout = set(varargin)
        varargout = graphEng(varargin)
        varargout = graphNor(varargin)
        varargout = saveFigure(varargin)
        varargout = update(varargin)
        
        function setSpecial(obj,varargin)
        % Syntax:
        % 
        % setSpecial(obj,varargin)
        % 
        % Written by Kenneth S. Paulsen

            for jj = 1:2:size(varargin,2)

                propertyName  = varargin{jj};
                propertyValue = varargin{jj + 1};

                if ischar(propertyName)

                    switch lower(propertyName)

                        case 'localvariables'

                            if isa(propertyValue,'nb_struct')
                                obj.localVariables = propertyValue;
                                for ii = 1:size(obj.plotter,2)
                                    setSpecial(obj.plotter(ii),'localVariables',propertyValue);
                                end
                            else
                                error([mfilename ':: The ' propertyName ' property must be a set to a nb_struct.'])
                            end

                        otherwise

                            error([mfilename ':: The class nb_graph_adv has no property ''' propertyName ''' or you have no access to set it.'])

                    end

                end

            end

        end
        
    end
    
    methods(Hidden=true)
        
        function addDefaultContextMenu(obj)
        % Adds default context menu to the graphs axes 
            
            if isa(obj.plotter,'nb_graph')
                string = 'Graph';
            else
                string = 'Table'; 
            end
        
            UIContextMenu     = uicontextmenu();
            graphMenu         = uimenu(UIContextMenu,'Label',string);
            dataMenu          = uimenu(UIContextMenu,'Label','Data');
            propertiesMenu    = uimenu(UIContextMenu,'Label','Properties');
            annotationMenu    = uimenu(UIContextMenu,'Label','Annotation');
            advancedMenu      = uimenu(UIContextMenu,'Label','Advanced');
            addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu,advancedMenu);
              
            % Assign to the plotter property, as this object need a
            % reference to the context menu, see enableUIComponents of the
            % nb_graph or nb_table_data_source
            setSpecial(obj.plotter,'UIContextMenu',UIContextMenu);
            
        end
        
        function addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu,advancedMenu,index)
            
            if nargin < 7
                index = 1;
            end
            
            addMenuComponents(obj.plotter(index),graphMenu,dataMenu,propertiesMenu,annotationMenu);
            
            % Remove some menu components not supported for advanced 
            % graph objects (only when addAdvanced is set to true, i.e.
            % when figure title and footer is added to graph)
            if obj.plotter(index).addAdvanced
                tit  = findobj(propertiesMenu,'tag','title');
                set(tit,'visible','off');
                enableDFN = 'off';
            else
                enableDFN = 'off';
            end
            
            % Add advanced menus
            if index == 1
               enable = 'on';
            else
               enable = 'off'; 
            end
            uimenu(advancedMenu,'Label','Figure Name','Callback',@obj.setFigureName);
            uimenu(advancedMenu,'Label','Figure Title','Callback',@obj.setFigureTitle,'enable',enable);
            uimenu(advancedMenu,'Label','Excel Title','Callback',@obj.setExcelTitle);          
            uimenu(advancedMenu,'Label','Footer','Callback',@obj.setFooter,'enable',enable);
            uimenu(advancedMenu,'Label','Excel Footer','Callback',@obj.setExcelFooter);
            uimenu(advancedMenu,'Label','Tooltip','Callback',@obj.setTooltip);
            uimenu(advancedMenu,'Label','Remove','Callback',@obj.setRemovedVariables);
            uimenu(advancedMenu,'Label','Numbering','Callback',@obj.setNumberingOptions);
            uimenu(advancedMenu,'Label','Round-off','Callback',@obj.setRoundOffCallback);
            if isa(obj.plotter(index),'nb_graph_ts') || isa(obj.plotter(index),'nb_table_ts')
                uimenu(advancedMenu,'Label','Forecast date','Callback',@obj.setForecastDate);
            elseif isa(obj.plotter(index),'nb_graph_cs') || isa(obj.plotter(index),'nb_table_cs')
                uimenu(advancedMenu,'Label','Forecast types','Callback',@obj.setForecastTypes);
            end
            uimenu(advancedMenu,'Label','Default figure numbering',...
                'Callback',@obj.setDefaultFigureNumbering,'checked','on','enable',enableDFN);
            uimenu(advancedMenu,'Label','Help','separator','on','Callback',@nb_graph_adv.helpOpenAdvancedMenuCallback);
            
            % Correct update data callback
            updateMenu = findobj(dataMenu,'Label','Update');
            set(updateMenu,'Callback',@obj.updateGUI);
            
        end
        
        function updateGUI(obj,~,~)
        % Update data of graph and replot
        
            for ii = 1:size(obj.plotter,2)
                updateGUI(obj.plotter(ii),[],[]);
            end
        
        end
          
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods(Access=protected)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to make deep copy of all the
        % graph objects
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the plotter object
            copyObj.plotter = copy(obj.plotter);
%             if isa(obj.localVariables,'nb_struct')
%                 copyObj.localVariables = copy(obj.localVariables);
%             end
            
        end
        
        %{
        -----------------------------------------------------------
        Set the font size properties, given the fontUnits property
        
        This method is called each time the fontUnits property is 
        set
        -----------------------------------------------------------
        %}
        function setFontSize(obj,oldFontSize,normalizeFactor)
            
            if nargin < 3
                normalizeFactor = 0.001455616863482;
            end
            
            switch lower(oldFontSize)
                
                case 'points'
            
                    switch lower(obj.fontUnits)

                        case 'points'

                            % Do nothing

                        case 'normalized'

                            obj.footerFontSize      = obj.footerFontSize*normalizeFactor;
                            obj.figureTitleFontSize = obj.figureTitleFontSize*normalizeFactor;

                        case 'inches'

                            obj.footerFontSize      = obj.footerFontSize/72;
                            obj.figureTitleFontSize = obj.figureTitleFontSize/72;

                        case 'centimeters'

                            obj.footerFontSize      = obj.footerFontSize*2.54/72;
                            obj.figureTitleFontSize = obj.figureTitleFontSize*2.54/72;

                        otherwise

                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

                    end
                    
                case 'normalized'
                    
                    switch lower(obj.fontUnits)

                        case 'points'

                            obj.footerFontSize      = obj.footerFontSize/normalizeFactor;
                            obj.figureTitleFontSize = obj.figureTitleFontSize/normalizeFactor;

                        case 'normalized'
                            
                            % Do nothing
                            
                        case 'inches'

                            obj.footerFontSize      = (obj.footerFontSize/normalizeFactor)/72;
                            obj.figureTitleFontSize = (obj.figureTitleFontSize/normalizeFactor)/72;

                        case 'centimeters'

                            obj.footerFontSize      = (obj.footerFontSize/normalizeFactor)*2.54/72;
                            obj.figureTitleFontSize = (obj.titleFontSize/normalizeFactor)*2.54/72;

                        otherwise

                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

                    end
                    
                case 'inches'
                    
                    switch lower(obj.fontUnits)

                        case 'points'

                            obj.footerFontSize      = obj.footerFontSize*72;
                            obj.figureTitleFontSize = obj.figureTitleFontSize*72;
                            
                        case 'normalized'

                            obj.footerFontSize      = (obj.footerFontSize*72)*normalizeFactor;
                            obj.figureTitleFontSize = (obj.figureTitleFontSize*72)*normalizeFactor;

                        case 'inches'

                            % Do nothing

                        case 'centimeters'

                            obj.footerFontSize      = obj.footerFontSize*2.54;
                            obj.figureTitleFontSize = obj.figureTitleFontSize*2.54;

                        otherwise

                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

                    end
                    
                case 'centimeters' 
                    
                    switch lower(obj.fontUnits)

                        case 'points'

                            obj.footerFontSize      = (obj.footerFontSize/2.54)*72;
                            obj.figureTitleFontSize = (obj.figureTitleFontSize/2.54)*72;
                            
                        case 'normalized'

                            obj.footerFontSize      = ((obj.footerFontSize/2.54)*72)*normalizeFactor;
                            obj.figureTitleFontSize = ((obj.figureTitleFontSize/2.54)*72)*normalizeFactor;

                        case 'inches'

                            obj.footerFontSize      = obj.footerFontSize/2.54;
                            obj.figureTitleFontSize = obj.figureTitleFontSize/2.54;

                        case 'centimeters'

                            % Do nothing

                        otherwise

                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

                    end
                    
            end
            
        end
        

    end
    
    %======================================================================
    % Hidden methods of the class
    %======================================================================
    methods (Access=public,Hidden=true)
        
        varargout = applyTemplate(varargin);
        varargout = saveTemplate(varargin);
        
        function s = saveobj(obj)
        % Overload how the object is saved to a .MAT file
            
            s = struct(obj);
            
        end
        
        function s = struct(obj)
            % Converts the object to a struct
            
            s       = struct();
            s.class = 'nb_graph_adv';
            props   = properties(obj);
            for ii = 1:length(props)
                
                switch lower(props{ii})
                    case 'plotter'
                        nGraphs   = size(obj.plotter,2);
                        if nGraphs > 1
                            s.plotter = cell(1,nGraphs);
                            for gg = 1:nGraphs
                                s.plotter{gg} = struct(obj.plotter(gg));
                            end
                        else
                            s.plotter = struct(obj.plotter);
                        end
                    otherwise
                        s.(props{ii}) = obj.(props{ii});
                end
            
            end
                
        end
        
        function setDefaultFigureNumbering(obj,hObject,~)
            
            if isempty(obj.plotter.DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
            value = get(hObject,'checked');
            if strcmpi(value,'on')
                set(hObject,'checked','off');
                input = 0;
            else
                set(hObject,'checked','on');
                input = 1;
            end
            obj.defaultFigureNumbering         = input;
            obj.plotter.defaultFigureNumbering = input;
            obj.plotter.graphUpdate([],[]);
            
        end
        
        function setFigureName(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_figureNameGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setFigureTitle(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_figureTitleGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            addlistener(gui,'changedGraph',@obj.notifyTitleOrFooterChange);
            
        end
        
        function setFooter(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_footerGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            addlistener(gui,'changedGraph',@obj.notifyTitleOrFooterChange);
            
        end
        
        function setExcelTitle(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_figureTitleGUI(obj,'excel');
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end        
        
        function setExcelFooter(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_footerGUI(obj,'excel');
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setTooltip(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_tooltipGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setForecastDate(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_forecastDateGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setForecastTypes(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_forecastTypesGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setNumberingOptions(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_numberingOptionsGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setRemovedVariables(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_removedVariablesGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function setRoundOffCallback(obj,~,~)
            
            if isempty(obj.plotter(1).DB)
                nb_errorWindow('No properties can be set, because the data of the graph/table is empty.')
                return
            end
        
            % Make GUI
            gui = nb_roundOffGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        
        function graphUpdate(obj,~,~)
           
            % We don't update the graph here as this is taken care of
            % already!
            
            % Notify listeners
            notify(obj,'updatedGraph');
            
        end
        
        function notifyTitleOrFooterChange(obj,~,~)
            
            notify(obj,'titleOrFooterChange')
              
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Access=public,Hidden=true,Static=true)
        
        function obj = loadobj(s)
            
            obj = nb_graph_adv.unstruct(s);
        
        end
        
        function obj = unstruct(s)
        % Convert a struct to an nb_graph_adv object
        
            obj    = nb_graph_adv();
            s      = rmfield(s,'class');
            fields = fieldnames(s);
            for ii = 1:length(fields)
        
                switch lower(fields{ii})     
                    case 'plotter'
                        if iscell(s.plotter)
                            nGraphs  = size(s.plotter,2);
                            plotters = cell(1,nGraphs);
                            for gg = 1:nGraphs
                                plotters{gg} = nb_graph_obj.fromStruct(s.plotter{gg});
                            end
                            obj.plotter = horzcat(plotters{:});
                        else
                            obj.plotter = nb_graph_obj.fromStruct(s.plotter);
                        end
                    otherwise
                        obj.(fields{ii}) = s.(fields{ii});
                end
                
            end
            
            % Move excel footers to children
            if ~isempty(obj.excelFooterEng)
                for ii = 1:size(obj.plotter,2)
                    obj.plotter(ii).excelFooterEng = obj.excelFooterEng;
                end
                obj.excelFooterEng = {};
            end
            if ~isempty(obj.excelFooterNor)
                for ii = 1:size(obj.plotter,2)
                    obj.plotter(ii).excelFooterNor = obj.excelFooterNor;
                end
                obj.excelFooterNor = {};
            end  
            
            % Allways set current graph to first to be robust in
            % nb_graphGUI
            obj.currentGraph = 1;
            
            % Secure that both graphs has the same template
            if size(obj.plotter,2) > 1
                obj.plotter(2).currentTemplate = obj.plotter(1).currentTemplate;
            end
            
            % Check that footer is stored properly
            if ~isempty(obj.footerNor)
                % Be sure that the footer is set properly, some problem
                % with this in 2020 version, should have been fixed, but
                % keep it for a while for robustness...
                set(obj,'footerNor',obj.footerNor);
            end
            if ~isempty(obj.footerEng)
                % See comment above...
                set(obj,'footerEng',obj.footerEng);
            end
            
        end
        
    end
    
    methods(Hidden=true,Static=true)
        varargout = helpTextAdvancedMenuCallback(varargin);
        varargout = helpOpenAdvancedMenuCallback(varargin);
    end
    

end
