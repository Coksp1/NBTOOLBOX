classdef nb_graph_cs < nb_graph
% Syntax:
%     
% obj = nb_graph_cs(varargin)
% 
% Superclasses:
% 
% handle, nb_graph
%     
% Description:
%     
% This is a class for making graphics of cross sectional data.
%   
% Constructor:
%     
%     obj = nb_graph_cs(data)
%     
%     Constructor of the nb_graph_cs class
%     
%     Input:
% 
%     - data : If you have one source you want to collect the 
%              data from you can give it as a input to this 
%              constructor. I.e:
% 
%              > nb_cs         : nb_graph_cs(data)
%              > excel         : nb_graph_cs('excelName1')
%
%     It is also possible to initialize an empty nb_graph_cs 
%     object. (Do not provide any inputs to the constructor)
% 
%     Output:
% 
%     - obj : An object of class nb_graph_cs
%    
% See also:
% nb_graph, nb_graph_ts, nb_graph_adv, nb_graph_subplot
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % Sets the orientation of the bar plot. This property is 
        % discarded when using the plotTypes property. Must be a string
        % with either 'vertical' (default) or 'horizontal'
        barOrientation          = 'vertical';
        
        % Sets the types which should have shaded bars. Must be a 
        % cellstr, with the names of the types to be shaded. E.g.
        % {'Type1','Type2',...}
        barShadingTypes         = {};              
             
        % All the data given to the nb_graph_cs object collected in a 
        % nb_cs object. Should not be set using obj.DB = data! Instead see  
        % the nb_graph_cs.resetDataSource method.  
        DB                      = nb_cs;            
         
        % Sets the realtive length of the inner circle of the donut. -0.5
        % mean that the donut has an inner circle with the same radius as
        % half the outer circle of the donut.
        donutInnerRadius       = -0.5;
        
        % Sets the radius of the donut. Default is 1.
        donutRadius            = 1;
        
        % Sets the colors of the fan charts. Must be a matrix of size; 
        % number of fan layer x 3, with the RGB color specifications. 
        % 
        % or
        % 
        % A string with the basis color for the fan colors. Either 
        % 'red', 'blue', 'green', 'yellow', 'magenta', 'cyan' or 
        % 'white'. 
        % 
        % Be aware that the classification of the color of the given 
        % "basecolor" is based on the property fanPercentiles, so if 
        % you have more or less than 4 layers you must change this 
        % property to have the same size as the number of layers. (This 
        % is the case even if you don't use it to calculate the 
        % percentiles of a given datasets. Given by the property 
        % fanDatasets)
        % 
        % Default is the nb colors.
        %
        % Caution: If fanMethod is set to 'graded' the color used are those
        %          assign to the colorMap property.
        fanColor                = 'nb';            
        
        % Sets the data of the added fan layers.
        % 
        % If you have the data of the different layer in separate 
        % datasets. Then the input to this property must be a 2 * number 
        % of layers cell matrix. Can be excel spreadsheets or .mat files.
        % 
        % or
        % 
        % You can also give the data with all the simulated data or 
        % fan layers in a nb_cs object. (Each page one simulation or each 
        % page one layer).
        % 
        % Remember that the percentiles for the fan charts is set by the 
        % property  fanPercentiles, default is [.3, .5, .7, .9]. 
        % 
        % The fan layers are added differently given the method you use.
        % 
        % > graph(...): Adds the fan given in this property to the last 
        %               variable given in the property variablesToPlot. 
        %               (If not the fanVariable property is set.) If you 
        %               graph more datasets (in separate figures), the 
        %               fan layers will be the same for all of them. 
        %               Set the fanVariables property if that is not 
        %               wanted.
        % 
        % > graphSubPlots(...): Adds the fan given in this property to  
        %                       the corresponding variable in the last 
        %                       given datasets (last page of the nb_cs 
        %                       object given by the property DB) of each 
        %                       each subplot.
        % 
        % -graphInfoStruct(...): Adds the fan given by this property to 
        %                        each variable of each subplot. Added 
        %                        for the last given dataset. (Last page 
        %                        of the nb_cs object given by the 
        %                        property DB.)        
        fanDatasets             = {};               
        
        % Set this property if you want to add a MPR styled legend 
        % of the fan layers. Set it to 1 if wanted. Default 
        % is not (0).        
        fanLegend               = 0;               
        
        % Sets the font size of the fan legend. Default is 12. Must be
        % a scalar.        
        fanLegendFontSize       = 12;

        % Sets the location of the fan legend. Locations are:
        % 
        % > 'Best', (same as 'North'.)
        % > 'NorthWest'
        % > 'North'
        % > 'NorthEast'
        % > 'SouthEast'
        % > 'South'
        % > 'SouthWest'
        % > 'outside'  : Places the legend outside the axes, one the 
        %                right side. (If you create subplots, this is 
        %                the only option which will look good.)
        % 
        % You can also give a 1 x 2 double vector with the location of 
        % where to place the legend. First column is the x-axis location 
        % and the second column is the y-axis location. Both must be 
        % between 0 and 1.        
        fanLegendLocation       = 'outside';        
        
        % Set this property if you want to give the text over the 
        % colored boxes of the MPR looking fan legend, you must give   
        % them as a cell. (Must have same size as number of layers.) 
        % Default is the percentiles with the % sign added. E.g. 
        % {'30%','50%','70%','90%'}.        
        fanLegendText           = {};               
        
        % {'percentiles'} | 'hdi' | 'graded'; Which type of fan chart is 
        % going to be made. 'percentiles' are produced by using 
        % percentiles, 'hdi' use highest density intervals, while 'graded'
        % creates a graded fan chart of the colors specified with the
        % colorMap property.
        fanMethod               = 'percentiles'; 
        
        % Sets the percentiles you want to calculate (if the fanDatasets
        % property is representing simulation) or specify the 
        % percentiles you have given (if the fanDatasets property is 
        % representing already calculated percentiles). Must be given as 
        % a double vector. Default is [0.3 0.5 0.7 0.9]. 
        % 
        % This property is also the default base for the text of the 
        % fan legend. (Where the percentiles are given in percent.)        
        fanPercentiles          = [.3,.5,.7,.9];    
        
        % Sets the variable you want to add the fan layers to. Must be 
        % given as a string with the variable name. Default is to use 
        % the last variable in the variablesToPlot property.        
        fanVariable             = '';         
        
        % If highlighted area between two types of the graph is wanted 
        % set this property.
        % 
        % One highlighted area: 
        % A cell array on the form {'type1', 'type2'}
        % 
        % More highlighted areas: 
        % A nested cell array on the form 
        % {{'type1(1)', 'type2(1)'},{'type1(2)', 'type2(2)'},...} 
        %
        % If plotType is set to 'scatter' scalars can be used 
        % instead. 
        highlight               = {}; 
        
        % Sets the colors of the background patches. Must be on of the 
        % following:
        % 
        % > A string with the color name to use when plotting (all) the 
        %   patch(es) 
        % > A cell array of strings with the color names 
        % > A cell with 1 x 3 doubles with the RGB color specification. 
        % 
        % When given as a cell this property must match the highlight 
        % property. I.e. the number of highlighted areas added.  
        % 
        % The default color of the highlighted areas is 'light blue'.        
        highlightColor          = {}; 
        
        % Make the axes box visible ('on') or not ('off'), when doing
        % pie or donut plot. 'on' is default.
        pieAxisVisible          = 'on';
        
        % Sets the pie and donut edge color. Default is to not 
        % display edges (same as setting to 'none'). Can be a one line   
        % char with the colors that can be interpreded by 
        % nb_plotHandle.interpretColor, or a double with size 1x3 with the 
        % RGB colors.
        pieEdgeColor            = [];
        
        % Sets the element(s) of the pie or donut chart which should 
        % explode. Must be a cellstr of the variables to explode. E.g. 
        % {'Var1','Var2',...}        
        pieExplode              = {};               

        % Set the origo position of pie or donut plot. Default is [-0.5,0].  
        % Must either be empty or a 1x2 double.
        pieOrigoPosition        = [];
        
        % Set this property to make text labels move more from the 
        % center of the pie or donut chart. Must be a cellstr of the  
        % variables to explode the text of. E.g. {'Var1','Var2',...}        
        pieTextExplode          = {};               
        
        % Extension of the pie or donut labels, e.g. 'mrd.kr' or '%'. Must 
        % be a string.        
        pieLabelsExtension      = '%';  
        
        % Sets the plot type. Either:
        % 
        % > 'line'        : If line plot(s) is wanted. Default. 
        % 
        % > 'stacked'     : If stacked bar plot(s) is wanted.
        % 
        % > 'grouped'     : If grouped bar plot(s) is wanted. 
        % 
        % > 'dec'         : If decomposition plot(s) is wanted. Which is 
        %                   a bar plot with also a line with the sum of 
        %                   the stacked bars. 
        % 
        % > 'area'        : If area plot(s) is wanted. 
        % 
        % > 'radar'       : If radar plot(s) is wanted. 
        % 
        % > 'candle'      : If candle plot(s) is wanted. 
        %
        % > 'scatter'     : If scatter plot(s) is wanted. 
        %
        % > 'pie'         : If pie plot(s) is wanted. 
        %
        % > 'donut'       : If donut plot(s) is wanted. 
        %
        % > 'image'       : If you want to plot the data as an image
        %                   mapped to the colors found by the property
        %                   colorMap.
        plotType                = 'line';           
        
        % Sets the plot type of the given variables. Must be a cell 
        % array on the form: {'var1', 'line', 'var2', 'grouped',...}. 
        % Here we set the plot type of the variables 'var1' and 'var2' 
        % to 'line' and 'grouped' respectively. The variables given 
        % must be included in the variablesToPlot or 
        % variablesToPlotRight properties.
        % 
        % Only the plot types 'line', 'stacked', 'grouped', 'dec'
        % and 'area' are supported.        
        plotTypes               = {};                
        
        % The color of the font of the labels. Either a 1x3 double with  
        % the color of all the labels or a size(xData,1) x 3 with the 
        % color of each label (RGB colors). Can also be a string with 
        % the color names to use on all labels or a cellstr with the 
        % color names of each label. Size must be 1 x size(xData,1)
        radarFontColor          = [0 0 0];
        
        % The number of isocurves of the radar plot. Must be an 
        % integer. Default is 10.
        radarNumberOfIsoLines   = 10;
        
        % Rotate the radar. In radians. Must be a scalar. Default 
        % is 0.
        radarRotate             = 0; 
        
        % Sets the axes limits, so the radar plot is  scaled
        % properly. (Also set the size of the plotted radar). Must
        % be a 1x2 double. Default is [2,1.25].
        radarScale              = [2,1.25]; 
           
        % Sets the scatter line style. Must be string. See 'lineStyles'
        % for supported inputs. (Sets the line style of all scatter plots)
        scatterLineStyle        = 'none';
        
        % Sets the variables to be used for the scatter plot plotted  
        % against the left axes. Must either be a nested cell array. 
        % E.g:
        % 
        % {'scatterGroup1',{'var1','var2',...},...
        %  'scatterGroup2',{'var10','var11',...}}
        % 
        % Be aware : Each variable will result in one point in the 
        %            scatter.
        scatterVariables        = {};

        % Sets the variables to be used for the scatter plot plotted  
        % against the right axes. Must either be a nested cell array. 
        % E.g:
        % 
        % {'scatterGroup1',{'var1','var2',...},...
        %  'scatterGroup2',{'var10','var11',...}}
        % 
        % Be aware : Each variable will result in one point in the 
        %            scatter.
        scatterVariablesRight   = {};

        % The types used for the scatter plot. Must be a 1x2 cellstr 
        % array. The first element will be the type plotted against the
        % x-axis, while the second element will be the type plotted 
        % against the left y-axis. E.g:
        % 
        % {'type1','type2'}
        scatterTypes            = {};

        % The types used for the scatter plot. Must be a 1x2 cellstr 
        % array. The first element will be the type plotted against the
        % x-axis, while the second element will be the type plotted 
        % against the right y-axis. E.g:
        % 
        % {'type1','type2'}
        scatterTypesRight       = {};          
        
        % Sets the types to plot for each plotted variables. Must be a 
        % cellstr. E.g. {'type1','type2',...}
        %
        % If the plotType property is set to 'pie', selecting more plot 
        % types will create more graphs (one per type). 
        typesToPlot             = {};               
        
        % Sets the types to plot for each plotted variables on the right 
        % axes. Must be a cellstr. E.g. {'type1','type2',...}. Only an 
        % option if plotType is set to 'grouped', and barOrientation is set
        % to horizontal, and some variables are given to the 
        % variablesToPlotRight property.
        typesToPlotRight         = {};
        
        % Sets the type(s) of where to place a vertical line(s). Must be
        % a cellstr array with all the types which should have a 
        % vertical line, either 'type' or {'type1','type2',...}. 
        % 
        % Each element of the cell could also be given as a cell with 
        % two types, i.e. {'type1','type2'}. Then the vertical line 
        % will be placed between the given types. 
        %
        % If plotType is set to 'scatter' scalars can be used 
        % instead. 
        verticalLine            = {};              
        
        % Sets the color(s) of the given vertical line(s). Must either 
        % be an M x 3 double with the RGB color(s) or a 1 x M cell array 
        % of strings with the color name(s). Where M must be less than 
        % the number of plotted vertical lines. 
        % 
        % If less or no color(s) is/are set by this property the default 
        % color(s) for the rest or all the vertical line(s) is/are 
        % [0 0 0]. I.e. MATLAB black.        
        verticalLineColor       = {};               
        
        % Sets the y-axis limit(s) of the given vertical line(s). Must 
        % either be a 1 x M cell array of 1 x 2 double with the upper 
        % and lower y-axis limit(s). Where M must be less than the 
        % number of plotted vertical lines. 
        % 
        % If less or no limit(s) is/are set by this property the default 
        % limit for the rest or all the vertical line(s) is/are the full 
        % height of the graph.        
        verticalLineLimit       = {};               
        
        % Sets the line style(s) of the given vertical line(s). Must 
        % either be a 1 x M cell array of strings with the style(s). 
        % Where M must be less than the number of plotted vertical 
        % lines. 
        % 
        % If less or no style(s) is/are set by this property the default 
        % line style is/are used for the rest or all the vertical 
        % line(s) is/are '--'.        
        verticalLineStyle       = {'--'};             
        
        % Sets the line width of (all) the vertical line(s). Must be a 
        % scalar. Default is 1.5.        
        verticalLineWidth       = 1.5;              
        
        % Sets the x-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Only an option when the plotType property is set to 'scatter'.
        xLim                    = [];

        % Sets the scale of the x-axis. Either {'linear'} | 'log'.
        %
        % Only an option when plotType is set to 'scatter'.
        xScale                  = 'linear'; 

        % Sets the x-ticks spacing. Must be a scalar.    
        xSpacing                 = [];               

        % The location of the x-axis tick marks labels. Either  
        % {'bottom'} | 'top' | 'baseline'. 'basline' will only work in 
        % combination with the xtickLocation property set to a double
        % with the basevalue.        
        xTickLabelLocation      = 'bottom'; 

        % The alignment of the x-axis tick marks labels. {'below'} | 
        % 'middle'.        
        xTickLabelAlignment     = 'below';
        
        % The location of the x-axis tick marks. Either {'bottom'} | 
        % 'top' | double. If given as a double the tick marks will be 
        % placed at this value (where the number represent the y-axis
        % value).
        xTickLocation           = 'bottom'; 

        % Sets the rotation of the x-axis tick mark labels. Must be a 
        % scalar with the number of degrees the labels should be 
        % rotated. Positive angles cause counterclockwise rotation.        
        xTickRotation           = 0;                
        
        % Sets the direction of the y-axis of the plot. Must be a 
        % string. Either 'normal' or 'reverse'. Default is 'normal'.
        % 
        % Caution: If the variablesToPlotRight is not empty this setting 
        %          only sets the left y-axis direction.        
        yDir                    = 'normal';         
        
        % Sets the direction of the right y-axis of the plot. Either 
        % 'normal' or 'reverse'. Default is 'normal'. (Only when the 
        % variablesToPlotRight property is not empty.)        
        yDirRight               = 'normal';         
        
        % Sets the y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this setting only sets the left y-axis limits. 
        % 
        % Only an option for the graph(...) and graphSubPlots() methods.  
        % (For the graphInfoStruct(...) method use the property 
        % GraphStruct.)
        yLim                    = [];               
        
        % Sets the right y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Only when the 
        % variablesToPlotRight property is not empty.) (Both or one of 
        % them can be set to nan, i.e. the default limits will be used) 
        % E.g. [0 6], [nan, 6] or [0, nan].
        % 
        % Only an option for the graph(...) and graphSubPlots() methods.  
        % (For the graphInfoStruct(...) method use the property 
        % GraphStruct.)           
        yLimRight               = [];  
        
        % The y-axis tick mark labels offset from the axes  
        yOffset                 = 0.01;          
        
        % Sets the scale of the y-axis. {'linear'} | 'log'.(Both  
        % the left and the right axes if nothing is plotted on the 
        % right axes.)
        yScale                  = 'linear';
        
        % Sets the scale of the right y-axis. {'linear'} | 'log'.  
        % (Has only somthing to say if somthing is plotted on the 
        % right axes)
        yScaleRight             = 'linear';
        
        % Sets the spacing between y-axis tick mark labels of the 
        % y-axis. Must be scalar. 
        % 
        % Caution: The spacing will be the number of periods between the
        %          tick marks labels. The number of periods will follow 
        %          the frequency of the xTickFrequency property if 
        %          setted, else it will  follow the frequency of the 
        %          data provided. (Except when dealing with daily data, 
        %          because then the default xTickFrequency is 'yearly')
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this property only sets the spacing between ticks of 
        %          the left y-axis.         
        ySpacing                = [];               
        
        % Sets the spacing between y-axis tick mark labels of the 
        % right y-axis. Must be scalar. 
        % 
        % Caution: The spacing will be the number of periods between the
        %          tick marks labels. The number of periods will follow 
        ySpacingRight           = [];               
        
    end 
    
    %======================================================================
    % Protected properties 
    %======================================================================
    properties (Access=protected)
        
        fanData                     = [];               % A property which temporary stores the data for fan charts
        typesOfGraph                = {};               % X-tick of the graph. Not settable.
            
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_graph_cs(data)
            
            obj = obj@nb_graph;
            
            if nargin == 1
                
                switch class(data)
                    
                    case 'nb_cs'
                        
                        obj.DB = data;
                          
                    otherwise
                        
                        error([mfilename ':: The input to this function must be an object of class nb_cs.'])
                        
                end
                
                % Set some default properties
                obj.typesToPlot     = obj.DB.types;
                obj.variablesToPlot = obj.DB.variables;
                
            elseif nargin > 1
                
                error([mfilename ':: Too many input to the nb_cs constructor'])
                
            end
            
        end
        
        function spreadsheetFanDataGUI(obj,~,~)
        % Create simple spreadsheet of data behind figure    

            if isempty(obj.fanDatasets)
                nb_errorWindow('The fan data of the graph is empty and cannot be displayed.')
                return
            end

%             if isa(obj.parent,'nb_GUI')
%                 gui = nb_spreadsheetAdvGUI(obj.parent,obj.fanDatasets,1);
%                 addlistener(gui,'saveToGraph',@obj.resetDataCallback);
%                 set(gui,'page',obj.page);
%             else
%                 nb_spreadsheetSimpleGUI(obj.parent,obj.fanDatasets);
%             end
            nb_spreadsheetSimpleGUI(obj.parent,obj.fanDatasets);

        end
        
        function setSpecial(obj,varargin)
        % Undocumented function to set properties which are 
        % protected 
            
            if size(varargin,1) && iscell(varargin{1})
                % Makes it possible to give options directly through a cell
                varargin = varargin{1};
            end

            for jj = 1:2:size(varargin,2)

                propertyName  = varargin{jj};
                propertyValue = varargin{jj + 1};

                if ischar(propertyName)

                    switch lower(propertyName)
                        
                        case 'advanced'
                            
                            obj.advanced = propertyValue;
                            
                        case 'axeshandle'
                            
                            obj.axesHandle = propertyValue;
                            
                        case 'db'
                            
                            obj.DB = propertyValue;
                           
                        case 'defaultfigurenumbering'
                            
                            obj.defaultFigureNumbering = propertyValue;    
                            
                        case 'figurehandle'
                            
                            obj.figureHandle = propertyValue;
                            
                            if isempty(propertyValue)
                                obj.manuallySetFigureHandle = 0;
                            else
                                obj.manuallySetFigureHandle = 1;
                            end
                            
                        case 'figtitleobjecteng'
                            
                            obj.figTitleObjectEng = propertyValue;
                            
                        case 'figtitleobjectnor'
                            
                            obj.figTitleObjectNor = propertyValue;
                            
                        case 'footerobjecteng'
                            
                            obj.footerObjectEng = propertyValue;
                            
                        case 'footerobjectnor'
                            
                            obj.footerObjectNor = propertyValue;
                            
                        case 'fontunits'
                            
                            oldFontSize   = obj.fontUnits;
                            obj.fontUnits = propertyValue;
                            setFontSize(obj,oldFontSize);
                            
                        case 'graphmethod'
                            
                            obj.graphMethod = propertyValue;
                            
                        case 'localvariables'
                            
                            % Set local variables without testing
                            obj.localVariables    = propertyValue;
                            
                        case 'plotaspectratio'
                            
                            obj.plotAspectRatio = propertyValue;
                            
                        case 'uicontextmenu'
                            
                            obj.UIContextMenu = propertyValue;
                            
                        case 'variablestoplot'
                            
                            obj.variablesToPlot = propertyValue;
                            
                        otherwise
                            
                            error([mfilename ':: The class nb_graph_cs has no property ''' propertyName ''' or you have no access to set it.'])
                    end

                end
            end

        end
        
        function disp(obj)
            
            link = nb_createLinkToClass(obj);
            disp([link, ' with:'])
            disp(['   <a href="matlab: nb_graph.dispMethods(''' class(obj) ''')">Methods</a>']);
            
            groups = {
                'Annotation properties:',           {'highlight','highlightColor','verticalLine','verticalLineColor',...
                                                     'verticalLineLimit','verticalLineStyle','verticalLineWidth'}
                'Axes properties:',                 {'barOrientation','barShadingTypes','xLim','xScale','xSpacing',...
                                                     'xTickLabelLocation','xTickLabelAlignment','xTickLocation','xTickRotation',...
                                                     'yDir','yDirRight','yLim','yLimRight','yOffset','yScale','yScaleRight',...
                                                     'ySpacing','ySpacingRight'}
                'Data properties:',                 {'DB'}
                'Fan chart properties:',            {'fanColor','fanDatasets','fanLegend','fanLegendFontSize',...
                                                     'fanLegendLocation','fanLegendText','fanMethod','fanPercentiles',...
                                                     'fanVariable'}                            
                'Pie and donut plot properties:',   {'donutInnerRadius','donutRadius','pieAxisVisible','pieEdgeColor',...
                                                     'pieExplode','pieOrigoPosition','pieTextExplode','pieLabelsExtension'} 
                'Plot properties:',                 {'plotType','plotTypes','typesToPlot','typesToPlotRight'} 
                'Radar plot properties:',           {'radarFontColor','radarNumberOfIsoLines','radarRotate','radarScale'}                               
                'Scatter plot properties:',         {'scatterLineStyle','scatterVariables','scatterVariablesRight',...
                                                     'scatterTypes','scatterTypesRight'}                       
            };
            groups = nb_graph.mergeDispTables(groups,nb_graph.dispTableGeneric());
            remove = {'numberOfGraphs'};
            type   = 'properties';
            disp(nb_createDispTable(obj,groups,remove,type));
            
        end
        
        varargout = get(varargin)
        varargout = graph(varargin)
        varargout = graphInfoStruct(varargin)
        varargout = graphSubPlots(varargin)
        varargout = saveData(varargin)     
        varargout = update(varargin)
        
        
    end
    
    methods (Access=public,Hidden=true)
        
        function s = saveobj(obj)
        % Overload how the object is saved to a .MAT file
        
            s = struct(obj);
        
        end
    
        function addDefaultContextMenu(obj)
        % Adds default context menu to the graphs axes 
            
            obj.UIContextMenu = uicontextmenu();
            graphMenu         = uimenu(obj.UIContextMenu,'Label','Graph');
            dataMenu          = uimenu(obj.UIContextMenu,'Label','Data');
            propertiesMenu    = uimenu(obj.UIContextMenu,'Label','Properties');
            annotationMenu    = uimenu(obj.UIContextMenu,'Label','Annotation');
            addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
            
        end
        
        function addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
            
            if ~isempty(graphMenu)
                uimenu(graphMenu,'Label','Notes','separator','on','Callback',@obj.editNotes);
            end
            
            if ~isempty(dataMenu)
                uimenu(dataMenu,'Label','Page','Callback',@obj.setPageGUI);
                uimenu(dataMenu,'Label','Spreadsheet','Callback',@obj.spreadsheetGUI);
                uimenu(dataMenu,'Label','Update','separator','on','Callback',@obj.updateGUI);
            end

            set(propertiesMenu,'enable','on');
            uimenu(propertiesMenu,'Label','Plot type','Callback',@obj.selectPlotTypeGUI);
            uimenu(propertiesMenu,'Label','Select variable','Callback',@obj.selectVariableGUI);
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Left axes variables','Callback',{@obj.reorderGUI,'left'});
                uimenu(reorderM,'Label','Right axes variables','tag','removeWhenRadarPie','Callback',{@obj.reorderGUI,'right'});
                uimenu(reorderM,'Label','Types','tag','removeWhenPie','Callback',{@obj.reorderGUI,'types'});
                uimenu(reorderM,'Label','Right axis types','tag','removeWhenPie','Callback',{@obj.reorderGUI,'typesRight'});
            uimenu(propertiesMenu,'Label','Patch','tag','removeWhenRadarPie','Callback',@obj.patchGUI);
            uimenu(propertiesMenu,'Label','Legend','Callback',@obj.legendGUI);
            uimenu(propertiesMenu,'Label','Title','tag','title','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','X-Axis Label','tag','xlabel','Callback',@obj.addAxesTextGUI);
            yLab = uimenu(propertiesMenu,'Label','Y-Axis Label','Callback','');
                uimenu(yLab,'Label','Left','tag','yLabel','Callback',@obj.addAxesTextGUI);
                uimenu(yLab,'Label','Right','tag','yLabelRight','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','Axes','Callback',@obj.axesPropertiesGUI); 
            uimenu(propertiesMenu,'Label','Look Up','Callback',@obj.lookUpGUI);  
            uimenu(propertiesMenu,'Label','General','Callback',@obj.generalPropertiesGUI);

            set(annotationMenu,'enable','on');
            uimenu(annotationMenu,'Label','Horizontal Line','tag','removeWhenRadarPie','Callback',{@obj.lineGUI,'horizontal'});
            uimenu(annotationMenu,'Label','Vertical Line','tag','removeWhenRadarPie2','Callback',{@obj.lineGUI,'vertical'});
            uimenu(annotationMenu,'Label','Highlighted Area','tag','removeWhenRadarPie2','Callback',@obj.highlightGUI);
            uimenu(annotationMenu,'Label','Text Box','separator','on','Callback',@obj.addTextBox);
            uimenu(annotationMenu,'Label','Rectangle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Circle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Arrow','Callback',@obj.addArrow);
            uimenu(annotationMenu,'Label','Text Arrow','Callback',@obj.addTextArrow);
            uimenu(annotationMenu,'Label','Curly Brace','Callback',@obj.addCurlyBrace);
            uimenu(annotationMenu,'Label','Draw line','Callback',@obj.addDrawLinesAnnotation);
            uimenu(annotationMenu,'Label','Regression line','Callback',@obj.addRegressionLinesAnnotation);
            uimenu(annotationMenu,'Label','Plot Labels','Callback',@obj.addPlotLabelsAnnotation);
            uimenu(annotationMenu,'Label','Color bar','Callback',@obj.addColorBarAnnotation);
            bar = uimenu(annotationMenu,'Label','Bar Annotation','separator','on');
                uimenu(bar,'Label','Add','callback',@obj.addBarAnnotation);
                uimenu(bar,'Label','Edit...','callback',@obj.editBarAnnotation);
                uimenu(bar,'Label','Delete','callback',@obj.deleteBarAnnotation);
            
        end
        
        %==================================================================
        function [message,retcode,s] = updatePropsWhenReset(obj,newDataSource)
        % Update properties dependent on the data source when the data is
        % reset. Used in the GUI. See also resetDataSource.
        
            retcode = 0;
            s       = struct('properties',struct);
            message = '';
            if ~isa(newDataSource,class(obj.DB))
                
                retcode = 1;
                message = 'Cannot plot the data type of the updated data in a time-series graph. Save it to a new dataset and graph that dataset!';
                return

            else
                
                % Check the types properties
                %---------------------
                if isempty(newDataSource)

                    message = 'The changed data is empty. All data dependent settings will be set to default values!';

                    s.properties.typesToPlot           = {};
                    s.properties.barShadingTypes       = {};
                    s.properties.highlight             = {};
                    s.properties.highlightColor        = {};
                    s.properties.pieExplode            = {};
                    s.properties.pieTextExplode        = {};
                    s.properties.scatterVariables      = {};
                    s.properties.scatterVariablesRight = {};
                    s.properties.verticalLine          = {};
                    s.properties.verticalLineColor     = {};
                    s.properties.verticalLineLimit     = {};
                    s.properties.verticalLineStyle     = {'--'};

                else

                    [s.properties.barShadingTypes,message]       = nb_graph_cs.checkTypes(obj.barShadingTypes,message,1,1,newDataSource.types,'the bar shading types');
                    [s.properties.highlight,message,indH]        = nb_graph_cs.checkTypes(obj.highlight,message,1,1,newDataSource.types,'one of the highlight areas');
                    [s.properties.verticalLine,message,ind]      = nb_graph_cs.checkTypes(obj.verticalLine,message,1,1,newDataSource.types,'one of the vertical lines');
                    
                    if ~isempty(obj.highlightColor)
                        s.properties.highLightColor = obj.highlightColor(indH);
                    end
                    if ~isempty(obj.verticalLineColor)
                        s.properties.verticalLineColor = obj.verticalLineColor(ind);
                    end
                    if ~isempty(obj.verticalLineLimit)
                        s.properties.verticalLineLimit = obj.verticalLineLimit(ind);
                    end
                    if ~isempty(obj.verticalLineStyle)
                        s.properties.verticalLineStyle = obj.verticalLineStyle(ind);
                    end
                    
                    types = newDataSource.types;
                    if ~isempty(obj.typesToPlot)
                
                        typesTP  = obj.typesToPlot;
                        ind      = ismember(typesTP,types);
                        typesTR  = typesTP(~ind);
                        if ~isempty(typesTR) && ~(strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle'))

                            newMessage = ['Some of the given types to plot will be removed by your changes to the data; ' ...
                                    nb_cellstr2String(typesTR,', ',' and ') '.'];
                            message = nb_addMessage(message,newMessage);

                            s.properties.typesToPlot = typesTP(ind);

                        end

                    end
                    
                    
                    
                end

                % Check the scatter variables and types
                %--------------------------------------
                [s,message] = nb_graph_cs.checkScatterOptions(obj,newDataSource,s,message);
                
                % Check the variables properties
                %-------------------------------
                vars = newDataSource.variables;
                if ~isempty(obj.pieExplode)
                    
                    ind = ismember(obj.pieExplode,vars);
                    s.properties.pieExplode = obj.pieExplode(ind);
                    if not(all(ind))
                        newMessage = ['The given pie explode variables will be removed by your changes to the data; ' ...
                            nb_cellstr2String(obj.pieExplode(~ind),', ') '. Default will be used.'];
                        message    = nb_addMessage(message,newMessage);
                    end
                     
                end
                
                if ~isempty(obj.pieTextExplode)
                    
                    ind = ismember(obj.pieTextExplode,vars);
                    s.properties.pieTextExplode = obj.pieTextExplode(ind);
                    if not(all(ind))
                        newMessage = ['The given pie text explode variables will be removed by your changes to the data; ' ...
                            nb_cellstr2String(obj.pieExplode(~ind),', ',' and ') '. Default will be used.'];
                        message    = nb_addMessage(message,newMessage);
                    end
                     
                end
                
                if ~isempty(obj.candleVariables)
                    
                    candleVars = obj.candleVariables;
                    ind        = ismember(candleVars(2:2:end),vars);
                    if all(~ind)
                        
                        s.properties.candleVariables = {};
                        if strcmpi(obj.plotType,'candle')
                            cvars      = candleVars(2:2:end);
                            newMessage = ['All the given candle variables will be removed by your changes to the data; ' ...
                                nb_cellstr2String(cvars(~ind),', ',' and ') '. Nothing to plot!'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    elseif ~all(ind)
                        
                        indProp = repmat(ind,2,1);
                        indProp = indProp(:)';
                        s.properties.candleVariables = obj.candleVariables(indProp); 
                        
                        if strcmpi(obj.plotType,'candle')
                            cvars      = candleVars(2:2:end);
                            newMessage = ['Some of the given candle variables will be removed by your changes to the data; ' ...
                                nb_cellstr2String(cvars(~ind),', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    end
                    
                end
                
                if ~isempty(obj.variablesToPlot)
                
                    varsTP   = obj.variablesToPlot;
                    ind      = ismember(varsTP,vars);
                    varsTR   = varsTP(~ind);
                    if ~isempty(varsTR)
                        
                        if ~(strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle'))
                            newMessage = ['Some of the given variables to plot will be removed by your changes to the data; ' ...
                                    nb_cellstr2String(varsTR,', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                        s.properties.variablesToPlot = varsTP(ind);
                        
                    end
                    
                end
                
                if ~isempty(obj.variablesToPlotRight)
                
                    varsTP = obj.variablesToPlotRight;
                    ind    = ismember(varsTP,vars);
                    varsTR = varsTP(~ind);
                    if ~isempty(varsTR)

                        s.properties.variablesToPlotRight = varsTP(ind);
                        if ~(strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle'))
                            newMessage = ['Some of the given variables to plot will be removed by your changes to the data; ' ...
                                    nb_cellstr2String(varsTR,', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        function [lVarsXNew,lVarsYNew] = getLabelVariablesScatter(obj, type)
        % Get labels of scatter plot
        %
        % - type : > 1         : For nb_displayValue
        %          > otherwise : For nb_plotLabels
        
            lVarsXNew = {};
            lVarsYNew = {};
            if ~isempty(obj.scatterVariables)
                
                lVarsXNew = obj.scatterVariables(2:2:end);
                scTypes   = obj.scatterTypes;
                if type == 1
                    scTypes = {[scTypes{1} ',' scTypes{2}]};
                end
                lVarsYNew = {scTypes};
                lVarsYNew = lVarsYNew(1,ones(1,length(lVarsXNew)));
                
            end

            if ~isempty(obj.scatterVariablesRight)
                
                lVarsXNew = obj.scatterVariables(2:2:end);
                scTypes   = obj.scatterTypes;
                if type == 1
                    scTypes = {[scTypes{1} ',' scTypes{2}]};
                end
                lVarsYNew = {scTypes};
                lVarsYNew = lVarsYNew(1,ones(1,length(lVarsXNew)));
                
            end
            
        end
        
        function xTickMarkLabels = interpretXTickLabels(obj,xTickMarkLabels)
        % Interpret x-tick labels using xTixkLabels, localVariables or 
        % lookUpMatrix properties    
            
            if ~isempty(obj.xTickLabels)
                
                try
                    checked = obj.xTickLabels(1:2:end);
                    new     = obj.xTickLabels(2:2:end);
                    xT      = strtrim(xTickMarkLabels);
                    for ii = 1:length(checked)
                        ind = find(strcmpi(checked{ii},xT),1,'last');
                        if ~isempty(ind)
                            xTickMarkLabels{ind} = new{ii};
                        end
                    end
                catch Err
                    error([mfilename ':: Wrong input given to the xTickLabels property:: ' Err.message])
                end
                
            end

            if ~isempty(obj.lookUpMatrix)
                for ii = 1:length(xTickMarkLabels)
                    xTickMarkLabels{ii} = nb_graph.findVariableName(obj,xTickMarkLabels{ii});
                end
            end
            
            % Interpret the local variables syntax
            if ~isempty(obj.localVariables)
                for ii = 1:length(xTickMarkLabels)
                    xTickMarkLabels{ii} = nb_localVariables(obj.localVariables,xTickMarkLabels{ii});
                end
            end
            for ii = 1:length(xTickMarkLabels)
                xTickMarkLabels{ii} = nb_localFunction(obj,xTickMarkLabels{ii});
            end
            
        end
        
    end
        
    %======================================================================
    % Protected methods of the class
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Clears the handles of the object
        -------------------------------------------------------------------
        %}
        function obj = clearHandles(obj)
            
            if obj.manuallySetFigureHandle == 0
                obj.figureHandle = [];
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Get the default colors
        -----------------------------------------------------------
        %}
        function getColors(obj,tempData,tempDataRight)
            
            if ~obj.manuallySetColorOrder
                obj.colorOrder = [];
            end
            
            if ~obj.manuallySetColorOrderRight
                obj.colorOrderRight = [];
            end
            
            if isempty(obj.colors)
            
                if isempty(obj.colorOrder) && isempty(obj.colorOrderRight)

                    left                = size(tempData,2);
                    right               = size(tempDataRight,2);
                    col                 = nb_plotHandle.getDefaultColors(left + right);
                    obj.colorOrder      = col(1:left,:);
                    obj.colorOrderRight = col(left + 1:end,:);

                else

                    if isempty(obj.colorOrder)
                        fail1 = 1;
                    elseif size(obj.colorOrder,1) ~= size(tempData,2)

                        warning('nb_graph_cs:graph:wrongColorOrderInput',[mfilename ':: The property ''colorOrder'' doesn''t '...
                                'match the number of plotted variables. Default colors will be used.'])
                        fail1 = 1;
                    else
                        fail1 = 0;
                    end

                    if isempty(obj.colorOrderRight)
                        fail2 = 1;
                    elseif size(obj.colorOrderRight,1) ~= size(tempDataRight,2)

                        warning('nb_graph_cs:graph:wrongColorOrderRightInput',[mfilename ':: The property ''colorOrderRight'' doesn''t '...
                                'match the number of plotted variables. Default colors will be used.'])
                        fail2 = 1;
                    else
                        fail2 = 0;  
                    end

                    if fail1 && fail2

                        left                = size(tempData,2);
                        right               = size(tempDataRight,2);
                        col                 = nb_plotHandle.getDefaultColors(left + right);
                        obj.colorOrder      = col(1:left,:);
                        obj.colorOrderRight = col(left + 1:end,:);

                    elseif fail1

                        obj.colorOrder = nb_plotHandle.getDefaultColors(size(tempData,2)); 

                    elseif fail2

                        obj.colorOrderRight = nb_plotHandle.getDefaultColors(size(tempDataRight,2));

                    end

                end
                
            else
                
                % Parse the colors property to find the colors
                % of the variables plotted
                if strcmpi(obj.plotType,'scatter') 
                    
                    obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.scatterVariables(1:2:end));
                    obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,obj.scatterVariablesRight(1:2:end));
                    
                elseif strcmpi(obj.plotType,'candle')
                    
                    obj.colorOrder      = interpretColorsProperty(obj,obj.colors,{'candle'});
                    obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,{'candle'});
                    
                else
                    
                    if strcmpi(obj.graphMethod,'graphInfoStruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                        
                        obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.DB.dataNames);
                        obj.colorOrderRight = [];
                        
                    else
                
                        obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.variablesToPlot(:)');
                        obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,obj.variablesToPlotRight(:)');
                        
                    end
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Parse optional inputs for the graphInfoStruct method
        -------------------------------------------------------------------
        %}
        function parseInputs(obj,graphInfoStructInputs)
            
            % Initialize fields of the 'inputs' property
            %--------------------------------------------------------------
            fields = {  'colorOrder'
                        'legends'
                        'legLocation'
                        'legPosition'
                        'lineStyle'
                        'plotType'
                        'title'
                        'xLabel'
                        'yLabel'
                        'yLabelRight'
                        'yLim'
                        'yLimRight'
                        'ySpacing'
                        'ySpacingRight'};
             
            obj.inputs = struct();        
            for ii = 1:length(fields)
                
                obj.inputs.(fields{ii}) = [];
                
            end
            
            % Parse the optional inputs
            %--------------------------------------------------------------
            for jj = 1:2:size(graphInfoStructInputs,2)
                
                propertyName  = graphInfoStructInputs{jj};
                propertyValue = graphInfoStructInputs{jj + 1};
                
                if ischar(propertyName)
                    
                    switch lower(propertyName)
                            
                        case 'colororder'

                            if isnumeric(propertyValue)
                                obj.inputs.colorOrder = propertyValue;
                            elseif iscellstr(propertyValue)
                                obj.inputs.colorOrder = nb_plotHandle.interpretColor(propertyValue);
                            else
                                error([mfilename ':: The input after ''colorOrder'' must be a double matrix or a cellstr array, with the color order '...
                                                 'of the plotted right axes variables. See documentation on use']);
                            end          
                                    
                        case 'fanvariable'

                            if ischar(propertyValue)
                                obj.inputs.fanVariable = propertyValue;
                            else
                                error([mfilename ':: The input after the ''fanVariable'' property must be a string with the variable the fan chart should be centered around.'])
                            end                    

                        case 'legends'

                            if iscell(propertyValue) || ischar(propertyValue)
                                obj.inputs.legends           = cellstr(propertyValue);
                                obj.inputs.manuallySetLegend = 1;
                            else
                                error([mfilename ':: The input after the ''legends'' property must be a cell or a char (single or array). For more see documentation.'])
                            end
                            
                        case 'leglocation'

                            if ischar(propertyValue)
                                obj.inputs.legLocation = propertyValue;
                            else
                                error([mfilename ':: The input after the ''legLocation'' property must be a string with where to put the legend in the figure. See info in the nb_graph_ts class.'])
                            end   
                            
                        case 'legposition'
                            
                            if isnumeric(propertyValue)
                                obj.inputs.legPosition = propertyValue;
                            else
                                error([mfilename ':: The input after ''legPosition'' must be a number with the position of the legend. [xPosition yPosition]']);  
                            end
                            
                        case 'linestyle'
                            
                            if iscellstr(propertyValue)
                                obj.inputs.lineStyle = propertyValue;
                            else
                                error([mfilename ':: The input after ''lineStyle'' must be a cellstr']);
                            end

                        case 'plottype'

                            if ischar(propertyValue)
                                obj.inputs.plotType = lower(propertyValue);
                            else
                                error([mfilename ':: The input after the ''plotType'' property must be a string with the plot type. See the documentation of class nb_graph_ts for info on plot types.'])
                            end 
                            
                        case {'title','titleofplot'} 

                            if ischar(propertyValue)
                                obj.inputs.title = propertyValue;
                            else
                                error([mfilename ':: The input after the ''title'' property must be a string with the title of the graph.'])
                            end      
                             
                        case 'xlabel'

                            if ischar(propertyValue)
                                obj.inputs.xLabel = propertyValue;
                            else
                                error([mfilename ':: The input after the ''xLabel'' property must be a string with the x-label of the graph.'])
                            end        
                            
                        case 'ylabel'

                             if ischar(propertyValue)
                                obj.inputs.yLabel = propertyValue;
                             else
                                error([mfilename ':: The input after the ''yLabel'' property must be a string with the y-label of the graph.'])
                             end  
                             
                        case 'ylabelright'

                             if ischar(propertyValue)
                                obj.inputs.yLabelRight = propertyValue;
                             else
                                error([mfilename ':: The input after the ''yLabelRight'' property must be a string with the y-label of the graph.'])
                             end      

                        case 'ylim'

                            if isnumeric(propertyValue)
                                if size(propertyValue,2) == 2 || isempty(propertyValue)
                                    obj.inputs.yLim = propertyValue;
                                else
                                    error([mfilename ':: The input after the ''yLim'' property must be a double vector of size 2. E.g. [lowerBound upperBound].'])
                                end
                            else
                                error([mfilename ':: The input after the ''yLim'' property must be a number with the limits on the y-axis.'])
                            end 
                            
                        case 'ylimright'

                            if isnumeric(propertyValue)
                                if size(propertyValue,2) == 2 || isempty(propertyValue)
                                    obj.inputs.yLimRight = propertyValue;
                                else
                                    error([mfilename ':: The input after the ''yLimRight'' property must be a double vector of size 2. E.g. [lowerBound upperBound].'])
                                end
                            else
                                error([mfilename ':: The input after the ''yLimRight'' property must be a number with the limits on the right y-axis when using the method graphYY.'])
                            end    

                        case 'yspacing'

                            if isnumeric(propertyValue)
                                obj.inputs.ySpacing = propertyValue;
                            else
                                error([mfilename ':: The input after the ''ySpacing'' property must be a number. (the spacing between y-ticks.)'])
                            end

                        case 'yspacingright'

                            if isnumeric(propertyValue)
                                obj.inputs.ySpacingRight = propertyValue;
                            else
                                error([mfilename ':: The input after the ''ySpacingRight'' property must be a number. (the spacing between y-ticks of '...
                                                 'the right axes when using the method graphYY.)'])
                            end    
                            
                        otherwise
                            
                            error([mfilename ':: The method graphInfoStruct() has no option ''' graphInfoStructInputs{jj} '''.'])
                    end

                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Test the 'variableToPlot' property
        -------------------------------------------------------------------
        %}
        function testVariablesToPlot(obj)
        
            if ~iscellstr(obj.variablesToPlot)
                error([mfilename ':: The ''variablesToPlot'' input must be a cellstr.'])
            end
            
            if ~iscellstr(obj.variablesToPlotRight)
                error([mfilename ':: The ''variablesToPlotRight'' input must be a cellstr.'])
            end
            
            variables = [obj.variablesToPlot obj.variablesToPlotRight];
            
            %--------------------------------------------------------------
            % If you want some graph some expressions, we must calculate
            % them and add them as seperate timeseries
            %--------------------------------------------------------------
            notFound = zeros(1,length(variables));
            for ii = 1:length(variables)
                notFound(ii) = isempty(find(strcmp(variables{ii},obj.DB.variables),1));
            end

            addedVars = variables(logical(notFound));
            if ~isempty(addedVars)
                obj.DB = obj.DB.createVariable(addedVars,addedVars);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Shrink data to graph. Only include the variables in the cellstr
        'variablesToPlot' and 'variablesToPlotRight' and only the types
        given by the 'typesToPlot'
        -------------------------------------------------------------------
        %}
        function shrinkDataToGraph(obj)
             
            %--------------------------------------------------------------
            % Load the data
            %--------------------------------------------------------------
            evaluatedData = obj.DB.data;
            
            %--------------------------------------------------------------
            % Make the data to graph properties; 'dataToGraph' and 
            % 'dataToGraphRight'
            %--------------------------------------------------------------
            
            % The types to plot
            typeIndex = nan(1,size(obj.typesToPlot,2));
            for ii = 1:size(obj.typesToPlot,2)
                try
                    typeIndex(ii) = find(strcmp(obj.typesToPlot{ii},obj.DB.types));
                catch Err
                    if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                        error([mfilename ':: type ' obj.typesToPlot{ii} ' not found in the dataset']) 
                    else
                        rethrow(Err);
                    end
                end
            end
            
            % For horizontal bar plot we also allow for seperate types to
            % plot against the separate axes.
            typeIndexR = typeIndex;
            if ~isempty(obj.variablesToPlotRight)
                if strcmpi(obj.plotType,'grouped') && strcmpi(obj.barOrientation,'horizontal') && ~isempty(obj.typesToPlotRight)
                      
                    typeIndexR = nan(1,size(obj.typesToPlotRight,2));
                    for ii = 1:size(obj.typesToPlotRight,2)
                        try
                            typeIndexR(ii) = find(strcmp(obj.typesToPlotRight{ii},obj.DB.types));
                        catch Err
                            if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                                error([mfilename ':: type ' obj.typesToPlotRight{ii} ' not found in the dataset (typesToPlotRight)']) 
                            else
                                rethrow(Err);
                            end
                        end
                    end
                    
                end
            end 
            
            % Left axes variables
            varIndex = nan(1,size(obj.variablesToPlot,2));
            for ii = 1:size(obj.variablesToPlot,2)
                try
                    varIndex(ii) = find(strcmp(obj.variablesToPlot{ii},obj.DB.variables));
                catch Err
                    if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                        error([mfilename ':: variable ' obj.variablesToPlot{ii} ' not found in the dataset']) 
                    else
                        rethrow(Err);
                    end
                end
            end
            
            obj.dataToGraph = evaluatedData(typeIndex',varIndex,:)*obj.factor;
            
            % Right axes variables
            varIndexRight = nan(1,length(obj.variablesToPlotRight));
            for ii = 1:length(obj.variablesToPlotRight)
                try
                    varIndexRight(ii) = find(strcmp(obj.variablesToPlotRight{ii},obj.DB.variables));
                catch Err
                    if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                        error([mfilename ':: variable ' obj.variablesToPlot{ii} ' not found in the dataset']) 
                    else
                        rethrow(Err);
                    end
                end
            end
            
            obj.dataToGraphRight = evaluatedData(typeIndexR',varIndexRight,:)*obj.factor;
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the properties of the axes
        -------------------------------------------------------------------
        %}
        function setAxes(obj)
            
            % We only need to update the axes if plotType is set 
            % to 'radar'.
            if strcmpi(obj.plotType,'radar')
                obj.axesHandle.lineWidth = obj.axesLineWidth;
                obj.axesHandle.shading   = obj.shading;
                obj.axesHandle.update    = 'on';
                obj.axesHandle.updateAxes();
                return   
            elseif strcmpi(obj.plotType,'scatter')
                setScatterAxes(obj);
                return
            end
            
            switch obj.graphMethod
                
                case 'graphinfostruct'
                    
                    if isempty(obj.inputs.ySpacing)
                        yspacing = [];
                    else
                        yspacing = obj.inputs.ySpacing;
                    end
                    
                    if isempty(obj.inputs.ySpacingRight)
                        yspacingright = [];
                    else
                        yspacingright = obj.inputs.ySpacingRight;
                    end
                    
                    if isempty(obj.inputs.yLim)
                        ylim = [];
                    else
                        ylim = obj.inputs.yLim;
                    end
                    
                    if isempty(obj.inputs.yLimRight)
                        ylimright = [];
                    else
                        ylimright = obj.inputs.yLimRight;
                    end
                    
                otherwise
                    
                    ylim          = obj.yLim;
                    ylimright     = obj.yLimRight;
                    yspacing      = obj.ySpacing;
                    yspacingright = obj.ySpacingRight;
                    
            end
            
            % Find the x-axis limits
            %--------------------------------------------------------------
            if strcmpi(obj.plotType,'image')
                xlim = [0, size(obj.typesToPlot,2)];
            else
            
                xlim = [1, size(obj.typesToPlot,2)];

                % Evaluate the 'addSpace' property
                if obj.addSpace(1) ~= 0 || obj.addSpace(2) ~= 0

                    xlim = [xlim(1) - obj.addSpace(1), xlim(2) + obj.addSpace(2)];

                else

                    if any(strcmpi(obj.plotType,{'dec','stacked','grouped','candle'}))

                        if strcmpi(obj.xTickLabelAlignment,'middle')
                            xlim = [xlim(1), xlim(2) + 0.5];
                        else
                            xlim = [xlim(1) - 0.5, xlim(2) + 0.5];
                        end

                    elseif xlim(1) == xlim(2) || strcmpi(obj.plotType,'heatmap')

                        xlim = [xlim(1) - 0.5, xlim(2) + 0.5];

                    elseif ~isempty(obj.plotTypes)

                        ind1 = find(strcmpi('stacked',obj.plotTypes),1);
                        ind2 = find(strcmpi('grouped',obj.plotTypes),1);

                        if ~isempty(ind1) || ~isempty(ind2)

                            if strcmpi(obj.xTickLabelAlignment,'middle')
                                xlim = [xlim(1), xlim(2) + 0.5];
                            else
                                xlim = [xlim(1) - 0.5, xlim(2) + 0.5];
                            end

                        end

                    end

                end
                
            end
            
            % Find the corresponding type name of the mnemonics, if
            % given as a x-tick mark label.
            xTickMarkLabels = interpretXTickLabels(obj,obj.typesToPlot);
            if isempty(obj.variablesToPlotRight)
                obj.yDirRight   = obj.yDir;
                obj.yScaleRight = obj.yScale;
            end
            
            % Set the x-axis tick mark labels. Set the direction and limits 
            % of both the x-axis and y-axis. Also set the font and grid 
            % options.  
            %--------------------------------------------------------------
            obj.axesHandle.alignAxes            = obj.alignAxes;
            obj.axesHandle.fontName             = obj.fontName;
            obj.axesHandle.fontSize             = obj.axesFontSize;
            obj.axesHandle.fontSizeX            = obj.axesFontSizeX;
            obj.axesHandle.fontUnits            = obj.fontUnits;
            obj.axesHandle.fontWeight           = obj.axesFontWeight;
            obj.axesHandle.grid                 = obj.grid;
            obj.axesHandle.gridLineStyle        = obj.gridLineStyle;
            obj.axesHandle.language             = obj.language;
            obj.axesHandle.lineWidth            = obj.axesLineWidth;
            obj.axesHandle.normalized           = obj.normalized;
            obj.axesHandle.precision            = obj.axesPrecision;
            obj.axesHandle.shading              = obj.shading;
            obj.axesHandle.UIContextMenu        = obj.UIContextMenu;
            obj.axesHandle.update               = 'on';
            
            displayOff = false;
            if strcmpi(obj.barOrientation,'horizontal') && any(strcmpi(obj.plotType,{'grouped','stacked'}))
                     
                if ~strcmpi(obj.yDir,'normal')
                    warning('nb_graph_cs:YDirNotSupported',[mfilename ':: The ''yDir'' property is not supported when the property '...
                            '''barOrientation'' is set to ''horizontal''.'])
                end
                
                if isempty(obj.xSpacing)
                    xTick           = find(~cellfun('isempty',xTickMarkLabels));
                    xTickMarkLabels = xTickMarkLabels(xTick);
                else
                    xTick           = 1:obj.xSpacing:size(obj.dataToGraph,1);
                    xTickMarkLabels = xTickMarkLabels(xTick);
                end
                
                % For horizontal bar plot we allow for different types on the
                % different axes.
                xTickMarkLabelsR = {};
                xTickR           = [];
                if ~isempty(obj.variablesToPlotRight)
                    displayOff = true; % Display stuff not yet supported
                    if isempty(obj.typesToPlotRight)
                        xTickMarkLabelsR = xTickMarkLabels;
                        xTickR           = xTick;
                    else
                        xTickMarkLabelsR = interpretXTickLabels(obj,obj.typesToPlotRight);
                        if isempty(obj.xSpacing)
                            xTickR           = find(~cellfun('isempty',xTickMarkLabelsR));
                            xTickMarkLabelsR = xTickMarkLabelsR(xTickR);
                        else
                            xTickR           = 1:obj.xSpacing:size(obj.dataToGraph,1);
                            xTickMarkLabelsR = xTickMarkLabels(xTickR);
                        end
                    end
                end 

                obj.axesHandle.xLim                  = ylim;
                obj.axesHandle.xLimSet               = 1;
                obj.axesHandle.xScale                = obj.yScale;
                obj.axesHandle.xTickLabelInterpreter = obj.xTickLabelInterpreter;
                obj.axesHandle.yLim                  = xlim;
                obj.axesHandle.yLimSet               = 1;
                obj.axesHandle.yOffset               = obj.yOffset;
                obj.axesHandle.yTick                 = xTick;
                obj.axesHandle.yTickRight            = xTickR;
                obj.axesHandle.yTickRightSet         = 1;
                obj.axesHandle.yTickLabelRight       = xTickMarkLabelsR;
                obj.axesHandle.yTickLabelRightSet    = 1;
                obj.axesHandle.yTickSet              = 1;
                obj.axesHandle.yTickLabel            = xTickMarkLabels;
                obj.axesHandle.yTickLabelSet         = 1;
                obj.axesHandle.yTickLabelInterpreter = obj.yTickLabelInterpreter;
                
                if ~isempty(ylim)
                    obj.axesHandle.xLimSet = 1;
                end

                % Interpret the y-axis spacing option (Both (if nothing is 
                % plotted on the right side axes) or left)
                %--------------------------------------------------------------
                if ~isempty(yspacing)
                    yTick                   = ylim(1):yspacing:ylim(2);
                    obj.axesHandle.xTick    = yTick;
                    obj.axesHandle.xTickSet = 1;
                end
                
            else
                
                if strcmpi(obj.plotType,'image')
                    xTick = 0.5:1:size(obj.dataToGraph,1);
                else
                    if isempty(obj.xSpacing)
                        xTick           = find(~cellfun('isempty',xTickMarkLabels));
                        xTickMarkLabels = xTickMarkLabels(xTick);
                    else
                        xTick           = 1:obj.xSpacing:size(obj.dataToGraph,1);
                        xTickMarkLabels = xTickMarkLabels(xTick);
                    end
                end
                
                obj.axesHandle.xLim                  = xlim;
                obj.axesHandle.xLimSet               = 1;
                obj.axesHandle.xTick                 = xTick;
                obj.axesHandle.xTickSet              = 1;
                obj.axesHandle.xTickLabel            = xTickMarkLabels;
                obj.axesHandle.xTickLabelSet         = 1;
                obj.axesHandle.xTickLabelLocation    = obj.xTickLabelLocation;         
                obj.axesHandle.xTickLabelAlignment   = obj.xTickLabelAlignment;
                obj.axesHandle.xTickLabelInterpreter = obj.xTickLabelInterpreter;
                obj.axesHandle.xTickLocation         = obj.xTickLocation; 
                obj.axesHandle.xTickRotation         = obj.xTickRotation;
                obj.axesHandle.yTickLabelInterpreter = obj.yTickLabelInterpreter;
                
                if strcmpi(obj.plotType,'image')
                    
                    % Translate the y-axis tick mark labels
                    yTickMarkLabels = obj.variablesToPlot;
                    if ~isempty(obj.lookUpMatrix)
                        for ii = 1:length(yTickMarkLabels)
                            yTickMarkLabels{ii} = nb_graph.findVariableName(obj,yTickMarkLabels{ii});
                        end
                    end
                    if ~isempty(obj.localVariables)
                        for ii = 1:length(yTickMarkLabels)
                            yTickMarkLabels{ii} = nb_localVariables(obj.localVariables,yTickMarkLabels{ii});
                        end
                    end
                    for ii = 1:length(yTickMarkLabels)
                        yTickMarkLabels{ii} = nb_localFunction(obj,yTickMarkLabels{ii});
                    end
                    
                    % Set y-axis properties
                    obj.axesHandle.yLim          = [0,length(obj.variablesToPlot)];
                    obj.axesHandle.yLimSet       = 1;
                    obj.axesHandle.yTick         = 0.5:1:length(obj.variablesToPlot);
                    obj.axesHandle.yTickSet      = 1;
                    obj.axesHandle.yTickRight    = [];
                    obj.axesHandle.yTickSet      = 1;
                    obj.axesHandle.yTickLabel    = yTickMarkLabels;
                    obj.axesHandle.yTickLabelSet = 1;
                    
                else
                    
                    obj.axesHandle.yDir                 = obj.yDir;
                    obj.axesHandle.yDirRight            = obj.yDirRight;
                    obj.axesHandle.yLim                 = ylim;
                    obj.axesHandle.yLimRight            = ylimright;
                    obj.axesHandle.yOffset              = obj.yOffset;
                    obj.axesHandle.yScale               = obj.yScale;
                    obj.axesHandle.yScaleRight          = obj.yScaleRight;
                
                    if ~isempty(ylim)
                        obj.axesHandle.yLimSet = 1;
                    end
                    if ~isempty(ylimright)
                        obj.axesHandle.yLimRightSet = 1;
                    end
                    
                    % Interpret the y-axis spacing option (Both (if nothing is 
                    % plotted on the right side axes) or left)
                    %--------------------------------------------------------------
                    if ~isempty(yspacing)

                        if isempty(ylim)
                            ylim = findYLimitsLeft(obj.axesHandle);
                        else
                            if all(isnan(ylim))
                                ylim     = findYLimitsLeft(obj.axesHandle);
                            elseif isnan(ylim(1))
                                ylimTemp = findYLimitsLeft(obj.axesHandle);
                                ylim(1)  = ylimTemp(1);
                            elseif isnan(ylim(2))
                                ylimTemp = findYLimitsLeft(obj.axesHandle);
                                ylim(2)  = ylimTemp(2);
                            end
                        end

                        yTick = ylim(1):yspacing:ylim(2);
                        obj.axesHandle.yTick    = yTick;
                        obj.axesHandle.yTickSet = 1;

                        if isempty(obj.variablesToPlotRight)
                            yTickRight = ylim(1):yspacing:ylim(2);
                            obj.axesHandle.yTickRight    = yTickRight;
                            obj.axesHandle.yTickRightSet = 1;
                        end

                    end

                    % Interpret the y-axis spacing option (Only right)
                    % This option will have nothing to say if no variables are
                    % plotted against the right side axes.
                    %--------------------------------------------------------------
                    if ~isempty(yspacingright)

                        if isempty(ylimright)
                            ylimright = findYLimitsRight(obj.axesHandle);
                            if isempty(ylimright)
                                ylimright = findYLimitsLeft(obj.axesHandle);
                            end
                        else
                            if all(isnan(ylimright))
                                ylimright = findYLimitsRight(obj.axesHandle);
                                if isempty(ylimright)
                                    ylimright = findYLimitsLeft(obj.axesHandle);
                                end
                            elseif isnan(ylimright(1))
                                ylimTemp = findYLimitsRight(obj.axesHandle);
                                if isempty(ylimTemp)
                                    ylimTemp = findYLimitsLeft(obj.axesHandle);
                                end
                                ylimright(1) = ylimTemp(1);
                            elseif isnan(ylimright(2))
                                ylimTemp = findYLimitsRight(obj.axesHandle);
                                if isempty(ylimTemp)
                                    ylimTemp = findYLimitsLeft(obj.axesHandle);
                                end
                                ylimright(2) = ylimTemp(2);
                            end    

                        end

                        yTickRight = ylimright(1):yspacingright:ylimright(2);
                        obj.axesHandle.yTickRight    = yTickRight;
                        obj.axesHandle.yTickRightSet = 1;

                    end 
                    
                end
                
            end
            
            applyNotTickOptions(obj);
            
            % Special stuff for heatmap
            %--------------------------------------------------------------
            if strcmpi(obj.plotType,'heatmap')
                setHeatmapAxes(obj)
            end
            
            % Then update and plot the axes
            %--------------------------------------------------------------
            obj.axesHandle.updateAxes();
               
            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch
                dv = true;
            end
            if dv && ~displayOff
                [labX,labY] = getLabelVariables(obj);
                func        = @(src,event)nb_displayValue(src,event,labY,labX);
                addlistener(obj.axesHandle,'mouseOverObject',func);
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Set the properties of the scatter plot axes
        -----------------------------------------------------------
        %}
        function setScatterAxes(obj)
            
            % Find the y-axis limits
            %------------------------------------------------------
            ylim          = obj.yLim;
            ylimright     = obj.yLimRight;
            yspacing      = obj.ySpacing;
            yspacingright = obj.ySpacingRight;
            
            % Find the x-axis limits
            %------------------------------------------------------
            xlim          = obj.xLim;
            xspacing      = obj.xSpacing;
            
            % Find some direction properties
            %------------------------------------------------------
            if isempty(obj.scatterVariablesRight)
                obj.yDirRight   = obj.yDir;
                obj.yScaleRight = obj.yScale;
            end
            
            % Set the x-axis tick mark labels. Set the direction  
            % and limits of both the x-axis and y-axis. Also set  
            % the font and grid options.  
            %------------------------------------------------------
            obj.axesHandle.alignAxes            = obj.alignAxes;
            obj.axesHandle.fontName             = obj.fontName;
            obj.axesHandle.fontSize             = obj.axesFontSize;
            obj.axesHandle.fontUnits            = obj.fontUnits;
            obj.axesHandle.fontWeight           = obj.axesFontWeight;
            obj.axesHandle.grid                 = obj.grid;
            obj.axesHandle.gridLineStyle        = obj.gridLineStyle;
            obj.axesHandle.language             = obj.language;
            obj.axesHandle.lineWidth            = obj.axesLineWidth;
            obj.axesHandle.normalized           = obj.normalized;
            obj.axesHandle.precision            = obj.axesPrecision;
            obj.axesHandle.shading              = obj.shading;
            obj.axesHandle.update               = 'on'; 
            obj.axesHandle.xScale               = obj.xScale;
            obj.axesHandle.xTickLabelLocation   = obj.xTickLabelLocation;         
            obj.axesHandle.xTickLabelAlignment  = obj.xTickLabelAlignment;
            obj.axesHandle.xTickLocation        = obj.xTickLocation; 
            obj.axesHandle.xTickRotation        = obj.xTickRotation;
            obj.axesHandle.yDir                 = obj.yDir;
            obj.axesHandle.yDirRight            = obj.yDirRight;
            obj.axesHandle.yOffset              = obj.yOffset;
            obj.axesHandle.yScale               = obj.yScale;
            obj.axesHandle.yScaleRight          = obj.yScaleRight;

            % Set some x-axis properties
            %------------------------------------------------------
            if ~isempty(xlim)
                
                % Evaluate the 'addSpace' property
                %--------------------------------------------------
                if obj.addSpace(1) ~= 0 || obj.addSpace(2) ~= 0
                    xlim = [xlim(1) - obj.addSpace(1), xlim(2) + obj.addSpace(2)];
                end
                
                obj.axesHandle.xLim    = xlim;
                obj.axesHandle.xLimSet = 1;
            end
            
            % Interpret the x-axis spacing option
            if ~isempty(xspacing)

                xTick = xlim(1):xspacing:xlim(2);
                obj.axesHandle.xTick    = xTick;
                obj.axesHandle.xTickSet = 1;

            end
            
            % Set some y-axes properties
            %------------------------------------------------------
            if ~isempty(ylim)
                obj.axesHandle.yLim    = ylim;
                obj.axesHandle.yLimSet = 1;
            end
            
            if ~isempty(ylimright)
                obj.axesHandle.yLimRight    = ylimright;
                obj.axesHandle.yLimRightSet = 1;
            end

            % Interpret the y-axes spacing options (Both (if   
            % nothing is plotted on the right side axes) or left)
            if ~isempty(yspacing)

                yTick = ylim(1):yspacing:ylim(2);
                obj.axesHandle.yTick    = yTick;
                obj.axesHandle.yTickSet = 1;

                if isempty(obj.variablesToPlotRight)

                    yTickRight = ylim(1):yspacing:ylim(2);
                    obj.axesHandle.yTickRight    = yTickRight;
                    obj.axesHandle.yTickRightSet = 1;

                end

            end

            % Interpret the y-axis spacing option (Only right)
            % This option will have nothing to say if no variables are
            % plotted against the right side axes.
            %--------------------------------------------------------------
            if ~isempty(yspacingright)

                yTickRight = ylimright(1):yspacingright:ylimright(2);
                obj.axesHandle.yTickRight    = yTickRight;
                obj.axesHandle.yTickRightSet = 1;

            end 
            
            % Then update and plot the axes
            %--------------------------------------------------------------
            applyNotTickOptions(obj);
            obj.axesHandle.updateAxes();
            
            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch
                dv = true;
            end
            if dv
                [labX,labY] = getLabelVariables(obj);
                func        = @(src,event)nb_displayValue(src,event,labY,labX);
                addlistener(obj.axesHandle,'mouseOverObject',func);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add vertical line
        -------------------------------------------------------------------
        %}
        function addVerticalLine(obj)
            
            if any(strcmpi(obj.plotType,{'radar','image'}))
                return
            end
            
            if ~isempty(obj.verticalLine)

                numberOfVerLine = length(obj.verticalLine);
                numbOfColors    = size(obj.verticalLineColor,2);
                numbOfStyles    = size(obj.verticalLineStyle,2);
                
                if numberOfVerLine > numbOfColors
                    
                    % Set the default color of all the vertical lines
                    % which doesn't have a color
                    diff          = numberOfVerLine - numbOfColors;
                    defaultColors = cell(1,diff);
                    for ii = 1:diff
                        defaultColors{ii} = [1 0.5 0.2];
                    end
                    obj.verticalLineColor = [obj.verticalLineColor, defaultColors];
                    
                end
                
                % Ensure that the 'verticalLineStyle' property has the
                % same number of elements as the 'verticalLine' property
                %----------------------------------------------------------
                if numberOfVerLine > numbOfStyles
                    
                    % Set the default color of all the vertical lines
                    % which doesn't have a color
                    diff          = numberOfVerLine - numbOfStyles;
                    defaultStyles = cell(1,diff);
                    for ii = 1:diff
                        defaultStyles{ii} = '--';
                    end
                    obj.verticalLineStyle = [obj.verticalLineStyle, defaultStyles];
                    
                end
                
                for ii = 1:numberOfVerLine
                    
                    % Find out where to place the vertical
                    % forecast line
                    if isnumeric(obj.verticalLine{ii})
                        x0 = obj.verticalLine{ii};
                    elseif ischar(obj.verticalLine{ii})
                        x0 = find(strcmp(obj.verticalLine{ii},obj.typesToPlot));
                        if isempty(x0)
                            error([mfilename ':: The type you have given (' obj.verticalLine{ii} ') is not a listed in the ''typesToPlot'' property.'])
                        end
                    else
                        type1 = obj.verticalLine{ii}{1};
                        if isnumeric(type1)
                            x1 = type1;
                        else
                            x1 = find(strcmp(type1,obj.typesToPlot));
                        end
                        type2 = obj.verticalLine{ii}{2};
                        if isnumeric(type2)
                            x2 = type2;
                        else
                            x2 = find(strcmp(type2,obj.typesToPlot));
                        end
                        x0    = x1 + (x2 - x1)/2;
                        if isempty(x0)
                            error([mfilename ':: One of the types you have given is not listed in the ''typesToPlot'' property. (' type1 ' or ' type2 ')'])
                        end
                    end
                    
                    color = obj.verticalLineColor{ii};
                    style = obj.verticalLineStyle{ii};
                    
                    try
                        limits = obj.verticalLineLimit{ii};
                        if isempty(limits)
                            indicator = 0;
                        else
                            indicator = 1;
                        end
                    catch
                        indicator = 0;
                    end
                    
                    % Plot it
                    if strcmpi(obj.barOrientation,'horizontal')
                    
                        if indicator 
                            nb_line(limits,[x0,x0],...
                                    'cData',        color,...
                                    'parent',       obj.axesHandle,...
                                    'lineStyle',    style,...
                                    'linewidth',    obj.verticalLineWidth,...
                                    'legendInfo',   'off');
                        else
                            nb_horizontalLine(x0,...
                                              'cData',        color,...
                                              'parent',       obj.axesHandle,...
                                              'lineStyle',    style,...
                                              'linewidth',    obj.verticalLineWidth);
                        end
                        
                    else
                        
                        if indicator 
                            nb_line([x0,x0],limits,...
                                    'cData',        color,...
                                    'parent',       obj.axesHandle,...
                                    'lineStyle',    style,...
                                    'linewidth',    obj.verticalLineWidth,...
                                    'legendInfo',   'off');
                        else
                            nb_verticalLine(x0,...
                                            'cData',        color,...
                                            'parent',       obj.axesHandle,...
                                            'lineStyle',    style,...
                                            'linewidth',    obj.verticalLineWidth);
                        end
                        
                    end
                        
                end

            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add highlighted areas
        -------------------------------------------------------------------
        %}
        function addHighlightArea(obj)
            
            if any(strcmpi(obj.plotType,{'radar','image'}))
                return
            end
            
            if ~isempty(obj.highlight)
                
                if iscell(obj.highlight{1})
                    
                    if isempty(obj.highlightColor)
                        
                        numberOfPatches = length(obj.highlight);
                        obj.highlightColor = cell(1,numberOfPatches);
                        for ii = 1:numberOfPatches
                            obj.highlightColor{ii} = 'light blue';
                        end
                        
                    end
                    
                    if length(obj.highlightColor) ~= length(obj.highlight)
                    
                        error([mfilename ':: You have provided too few or too many highlight colors with the property ''highlightColor''. '...
                                         'You should have given (' int2str(length(obj.highlight)) ') but have given (' int2str(length(obj.highlightColor)) ')'])
                    end
                    
                    % Plot each patch
                    %------------------------------------------------------
                    for ii = 1:length(obj.highlight)
                        
                        tempHighlight = obj.highlight{ii};
                        
                        if isnumeric(tempHighlight{1})
                            startPeriod = tempHighlight{1};
                        else
                            startPeriod = find(strcmp(tempHighlight{1},obj.typesToPlot),1,'last');
                        end
                        
                        if isnumeric(tempHighlight{2})
                            endPeriod = tempHighlight{2};
                        else
                            endPeriod = find(strcmp(tempHighlight{2},obj.typesToPlot),1,'last');
                        end

                        % Plot the patch
                        %------------------------------------------------------
                        x = [startPeriod, endPeriod];
                        nb_highlight(x,...
                                     'cData',       obj.highlightColor{ii},...
                                     'legendInfo',  'off',...
                                     'parent',      obj.axesHandle);
                             
                    end
                    
                else
                    
                    if isempty(obj.highlightColor)
                        obj.highlightColor = 'light blue';
                    end
                    
                    if size(obj.highlightColor,1) ~= 1
                    
                        error([mfilename ':: You have provided too few or too many highlight colors with the property ''highlightColor''. '...
                                         'You should have given (1) but have given (' int2str(size(obj.highlightColor,1)) ')'])
                    end
                    
                    if isnumeric(obj.highlight{1})
                        startPeriod = obj.highlight{1};
                    else
                        startPeriod = find(strcmp(obj.highlight{1},obj.typesToPlot),1,'last');
                    end

                    if isnumeric(obj.highlight{2})
                        endPeriod = obj.highlight{2};
                    else
                        endPeriod = find(strcmp(obj.highlight{2},obj.typesToPlot),1,'last');
                    end

                    % Plot the patch
                    %------------------------------------------------------
                    x = [startPeriod, endPeriod];
                    nb_highlight(x,... 
                                 'cData',       obj.highlightColor,...
                                 'legendInfo',  'off',...
                                 'parent',      obj.axesHandle);
                
                end
            
            end
             
        end
        
        %{
        -------------------------------------------------------------------
        Plot lines
        -------------------------------------------------------------------
        %}
        function plotLines(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            if strcmpi(side,'left')
                
                if strcmpi(obj.graphMethod,'graphinfostruct')
                    
                    variables = obj.DB.dataNames;
                    for ii = 1:size(variables,2)
                        ind = strfind(variables{ii},'\');
                        if ~isempty(ind)
                            variables{ii} = variables{ii}(ind(end)+1:end);
                        end
                    end
                    
                else
                    
                    variables = obj.variablesToPlot;
                    
                end
                data      = obj.dataToGraph;
                col       = obj.colorOrder;    
            else
                data      = obj.dataToGraphRight;
                variables = obj.variablesToPlotRight;
                col       = obj.colorOrderRight;
            end
            
            if isempty(data)
                return
            end
            
            sData = size(data,2);
            
            % Set default options
            %--------------------------------------------------------------
            lineColor = nan(sData,3);
            lineStyle = cell(1,sData);
            lineW     = nan(1,sData);
            marker    = cell(1,sData);
            
            defaultLineStyle = '-';
            
            for ii = 1:sData
                lineStyle{ii}   = defaultLineStyle;
                lineW(ii)       = obj.lineWidth;
                marker{ii}      = 'none';
                lineColor(ii,:) = col(ii,:);
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = obj.lineStyles;
            for kk = 1:2:size(lineS,2)
                var    = lineS{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    lineStyle{locVar} = lineS{kk + 1};
                catch
                    
                    if strcmpi(side,'left')
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                        type            = 'variablesToPlot';
                    else
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                        type            = 'variablesToPlotRight';
                    end
                    if isempty(locVarOtherSide)
                        warning('nb_graph_cs:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineStyles'' property.'])
                    end
                    
                end    
            end
            
            lineWi = obj.lineWidths;
            for kk = 1:2:size(lineWi,2)
                var    = lineWi{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    lineW(locVar) = lineWi{kk + 1};
                catch
                    
                    if strcmpi(side,'left')
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                        type            = 'variablesToPlot';
                    else
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                        type            = 'variablesToPlotRight';
                    end
                    if isempty(locVarOtherSide)
                        warning('nb_graph_cs:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineWidths'' property.'])
                    end
                    
                end    
            end
            
            mark   = obj.markers;
            for kk = 1:2:size(mark,2)
                var    = mark{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    marker{locVar} = mark{kk + 1};
                catch
                    
                    if strcmpi(side,'left')
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                        type            = 'variablesToPlot';
                    else
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                        type            = 'variablesToPlotRight';
                    end
                    if isempty(locVarOtherSide)
                        warning('nb_graph_cs:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                    end
                    
                end

            end
            
            if strcmpi(obj.graphMethod,'graphInfoStruct')
                
                if ~isempty(obj.inputs.lineStyle)
                    lineStyle = obj.inputs.lineStyle;
                end
                
            end
                
            % Do the plotting
            %--------------------------------------------------------------
            numPer      = size(data,1);
            
            nb_plot(1:numPer,data,...
                    'cData',              lineColor,...
                    'lineStyle',          lineStyle,...
                    'lineWidth',          lineW,...
                    'marker',             marker,...
                    'markerFaceColor',    'auto',...
                    'markerSize',         obj.markerSize,...
                    'parent',             obj.axesHandle,...
                    'side',               side);
            
        end
        
        %{
        -------------------------------------------------------------------
        Create area plot
        -------------------------------------------------------------------
        %}
        function pieChart(obj)
            
            if isempty(obj.page)
                p = 1;
            else
                p = obj.page;
            end
            
            for ii = 1:obj.numberOfGraphs
                
                if obj.numberOfGraphs == 1
                    % The 'donut' supported more types in one graph!
                    data = obj.dataToGraph(:,:,p);
                else
                    data = obj.dataToGraph(ii,:,p);
                end
                
                %--------------------------------------------------
                % Initialize the figures and set the figure 
                % properties
                %--------------------------------------------------
                if isempty(obj.figurePosition)
                    inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
                else
                    inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
                end

                if obj.manuallySetFigureHandle == 0

                    if ~isempty(obj.plotAspectRatio)
                        inputs = [inputs 'advanced',obj.advanced]; %#ok
                        obj.figureHandle = [obj.figureHandle, nb_graphPanel(obj.plotAspectRatio,inputs{:})];
                    else
                        obj.figureHandle = [obj.figureHandle, nb_figure(inputs{:})];
                    end

                else
                    
                    if ~isempty(obj.axesHandle)
                        if isvalid(obj.axesHandle)
                            obj.axesHandle.deleteOption = 'all';
                            delete(obj.axesHandle);
                        end
                    end
                    
                end
                
                %--------------------------------------------------
                % Make the axes handle
                %--------------------------------------------------
                obj.axesHandle = nb_axes('parent',              obj.figureHandle(ii),...
                                         'position',            obj.position,...
                                         'UIContextMenu',       obj.UIContextMenu);
                
                %--------------------------------------------------
                % Find out which variables should explode
                %--------------------------------------------------
                pieExplodeLoc     = ismember(obj.variablesToPlot,obj.pieExplode);
                pieExplodeTextLoc = ismember(obj.variablesToPlot,obj.pieTextExplode);
                
                % EdgeColor
                if isempty(obj.pieEdgeColor)
                    edgeColor = 'none';
                    if strcmpi(obj.plotType,'donut')
                        if size(data,1) > 1
                            edgeColor = [0,0,0];
                        end
                    end
                else
                    edgeColor = obj.pieEdgeColor;
                end
                
                %--------------------------------------------------
                % Plot
                %--------------------------------------------------
                if strcmpi(obj.plotType,'pie')
                
                    nb_pie(data,...
                       'axisVisible',       obj.pieAxisVisible,...
                       'noLabels',          true,...
                       'cData',             obj.colorOrder,...
                       'explode',           pieExplodeLoc,...
                       'edgeColor',         edgeColor,...
                       'origoPosition',     obj.pieOrigoPosition,...
                       'parent',            obj.axesHandle,...
                       'textExplode',       pieExplodeTextLoc);
                   
                else
                    
                    nb_donut(data,...
                       'axisVisible',       obj.pieAxisVisible,...
                       'noLabels',          true,...
                       'cData',             obj.colorOrder,...
                       'explode',           pieExplodeLoc,...
                       'edgeColor',         edgeColor,...
                       'innerRadius',      obj.donutInnerRadius,...
                       'lineWidth',         obj.lineWidth,...
                       'origoPosition',     obj.pieOrigoPosition,...
                       'parent',            obj.axesHandle,...
                       'radius',           obj.donutRadius,...
                       'textExplode',       pieExplodeTextLoc);
                    
                end

                %--------------------------------------------------
                % Evaluate the axes options
                %--------------------------------------------------
                obj.axesHandle.set('shading',obj.shading);
                
                % Add listener so that values get displayed in window
                try
                    dv = obj.displayValue;
                catch
                    dv = true;
                end
                if dv
                    [labX, labY] = getLabelVariables(obj);
                    labX = labX(ii);
                    func = @(src,event)nb_displayValue(src,event,labY,labX);
                    addlistener(obj.axesHandle,'mouseOverObject',func);
                end
                
                %--------------------------------------------------
                % Add annotations
                %--------------------------------------------------
                addAnnotation(obj);
                
                %--------------------------------------------------
                % Evaluate the extra code if given
                %--------------------------------------------------
                if ~isempty(obj.code)
                    eval(obj.code);
                end
                
                %--------------------------------------------------
                % Evaluate legends of plot
                %--------------------------------------------------
                if strcmpi(obj.legLocation,'best')
                    obj.legLocation = 'east';
                end
                addLegend(obj);
                
                %--------------------------------------------------
                % Title of the plot if not the property 'noTitle'  
                % is set to 1
                %--------------------------------------------------
                addTitle(obj);
                
                %------------------------------------------------------
                % Add the x-label, if not 'none'
                %------------------------------------------------------
                addXLabel(obj);

                %------------------------------------------------------
                % Add the y-label, if not 'none'
                %------------------------------------------------------
                addYLabel(obj);
                
                %--------------------------------------------------
                % Add figure title and/or footer
                %--------------------------------------------------
                addAdvancedComponents(obj,obj.language);
                
                %--------------------------------------------------
                % Save it down to a file
                %--------------------------------------------------
                if ~isempty(obj.saveName)
                    saveFigure(obj,int2str(ii)); %
                end
                %--------------------------------------------------
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Create area plot
        -------------------------------------------------------------------
        %}
        function areaPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data      = obj.dataToGraph;
                col       = obj.colorOrder;
            else
                data      = obj.dataToGraphRight;
                col       = obj.colorOrderRight;
            end
            
            if isempty(data)
                return
            end
            
            xData = 1:size(data,1);
            if obj.areaAlpha < 1
                lineW = obj.lineWidth;
            else
                lineW = 1;
            end   
            
            % Do the plotting
            %--------------------------------------------------------------
            a = nb_area(xData,data,...
                        'abrupt',           obj.areaAbrupt,...  
                        'accumulate',       obj.areaAccumulate,...
                        'baseValue',        obj.baseValue,...
                        'cData',            col,...
                        'faceAlpha',        obj.areaAlpha,...
                        'lineStyle',        '-',...
                        'lineWidth',        lineW,...
                        'parent',           obj.axesHandle,...
                        'side',             side);

            % Remove the baseline
            %--------------------------------------------------------------
            set(a.baseline,'lineStyle','none','legendInfo','off');
            
        end
        
        %{
        -------------------------------------------------------------------
        Create bar plot
        -------------------------------------------------------------------
        %}
        function barPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data   = obj.dataToGraph;
                col    = obj.colorOrder;
                ylim   = obj.yLim;
            else
                data   = obj.dataToGraphRight;
                col    = obj.colorOrderRight;
                ylim   = obj.yLimRight;
            end
            
            if isempty(data)
                return
            end
            
            xData = 1:size(data,1);
            
            % Decide the shading
            %--------------------------------------------------------------
            if isempty(obj.barShadingTypes)
                shadedBars = zeros(size(data,1),1);
            else
                shadedBars = ismember(obj.typesToPlot,obj.barShadingTypes);  
            end
            
            if any(shadedBars)
                lineS = '-';
            else
                lineS = 'none';
            end
            
            if isempty(obj.barLineWidth)
                lineW = obj.lineWidth;
            else
                lineW = obj.barLineWidth;
                if lineW == 0
                    lineW = 1;
                    lineS = 'none';
                end
            end
               
            % Do the plotting
            %--------------------------------------------------------------
            if strcmpi(obj.barOrientation,'horizontal')
                
                b = nb_hbar(xData,data,...
                            'alpha1',        obj.barAlpha1,...
                            'alpha2',        obj.barAlpha2,...
                            'barWidth',      obj.barWidth,...
                            'baseValue',     obj.baseValue,...
                            'blend',         obj.barBlend,...
                            'cData',         col,...
                            'edgeColor',     'same',...
                            'lineStyle',     lineS,...
                            'lineWidth',     lineW,...
                            'parent',        obj.axesHandle,...  
                            'side',          side,... 
                            'style',         obj.plotType,...
                            'sumTo',         obj.sumTo,...
                            'direction',     obj.barShadingDirection,...
                            'shadeColor',    obj.barShadingColor,...
                            'shaded',        shadedBars);
                
            else
                
                % Fit to limits
                %---------------------
                if ~isempty(ylim)
                    if strcmpi(obj.plotType,'grouped')
                        if ~isnan(ylim(1))
                            data(data<ylim(1)) = ylim(1);
                        end
                        if ~isnan(ylim(2))
                            data(data>ylim(2)) = ylim(2);
                        end
                    end
                end 
            
                b = nb_bar(xData,data,...
                           'alpha1',        obj.barAlpha1,...
                           'alpha2',        obj.barAlpha2,...
                           'barWidth',      obj.barWidth,...
                           'baseValue',     obj.baseValue,...
                           'blend',         obj.barBlend,...
                           'cData',         col,...
                           'edgeColor',     'same',...
                           'lineStyle',     lineS,...
                           'lineWidth',     lineW,...
                           'parent',        obj.axesHandle,...
                           'side',          side,...                      
                           'style',         obj.plotType,...
                           'sumTo',         obj.sumTo,...
                           'direction',     obj.barShadingDirection,...
                           'shadeColor',    obj.barShadingColor,...
                           'shaded',        shadedBars);
                       
            end
             
            % Remove the baseline
            %--------------------------------------------------------------       
            set(b.baseline,'lineStyle','none','legendInfo','off'); 

        end
        
        %{
        -----------------------------------------------------------
        Create candle plot
        -----------------------------------------------------------
        %}
        function candlePlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %------------------------------------------------------
            data    = obj.DB.data;
            varSide = obj.DB.variables;
            if strcmpi(side,'left')
                
                if isempty(obj.colors)
                
                    if isempty(obj.colorOrder)
                        col = 'red';
                    else
                        if iscell(obj.colorOrder)
                            col = obj.colorOrder{1};
                        elseif isnumeric(obj.colorOrder)
                            col = obj.colorOrder(1,:);
                        else
                            col = obj.colorOrder;
                        end
                    end
                    
                else
                    
                    ind = find(strcmpi('candle',obj.colors),1,'last');
                    if isempty(ind)
                        col = 'red';
                    else
                        col = obj.colors{ind + 1};
                    end
                    
                end
                
            else
                
                if isempty(obj.colors)
                
                    if isempty(obj.colorOrderRight)
                        col = 'red';
                    else
                        if iscell(obj.colorOrderRight)
                            col = obj.colorOrderRight{1};
                        elseif isnumeric(obj.colorOrder)
                            col = obj.colorOrderRight(1,:);
                        else
                            col = obj.colorOrderRight;
                        end
                    end
                    
                else
                    
                    ind = find(strcmpi('candle',obj.colors),1,'last');
                    if isempty(ind)
                        col = 'red';
                    else
                        col = obj.colors{ind + 1};
                    end
                    
                end
                
            end
            
            xData = 1:size(data,1);
            
            % Parse the candle option
            %------------------------------------------------------
            candleVars = obj.candleVariables;
            if isempty(candleVars) 
                error([mfilename ':: If you want to create a candle plot you need to set the candleVariables property.'])
            else
                
                high      = [];
                low       = [];
                open      = [];
                close     = [];
                indicator = [];
                varsOP    = cell(1,size(candleVars,2)/2);
                kk        = 1;
                for ii = 1:2:size(candleVars,2)
                
                    type = candleVars{ii};
                    try
                        var = candleVars{ii + 1};    
                    catch     
                        error([mfilename ':: The candleVariables property must be a even cell array.'])
                    end
                        
                    switch lower(type)
                        
                        case 'open'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''open'' option of the candleVariables property.'])
                            end
                            open       = data(:,ind,:);
                            varsOP{kk} = var;
                            kk         = kk + 1;
                            
                        case 'close'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''close'' option of the candleVariables property.'])
                            end
                            close      = data(:,ind,:);
                            varsOP{kk} = var;
                            kk         = kk + 1;
                            
                        case 'high'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''high'' option of the candleVariables property.'])
                            end
                            high       = data(:,ind,:);
                            varsOP{kk} = var;
                            kk         = kk + 1;
                            
                        case 'low'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''low'' option of the candleVariables property.'])
                            end
                            low        = data(:,ind,:);
                            varsOP{kk} = var;
                            kk         = kk + 1;
                            
                        case 'indicator'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''indicator'' option of the candleVariables property.'])
                            end
                            indicator  = data(:,ind,:);
                            varsOP{kk} = var;
                            kk         = kk + 1;
                            
                        otherwise
                            
                            error([mfilename ':: The input ''' type ''' is not supported by the candle plot. Must be ''open'',''close'',''high'',''low'' or ''indicator''.'])
                            
                    end
                    
                end
                        
            end
            
            indicatorWidth = obj.candleWidth + obj.candleWidth/10; 
            
            % Do the plotting
            %------------------------------------------------------
            nb_candle(xData,high,low,open,close,...
                      'candleWidth',        obj.candleWidth,...
                      'cData',              col,...
                      'edgeColor',          'same',...
                      'hlLineWidth',        2.5,...
                      'indicator',          indicator,...
                      'indicatorColor',     obj.candleIndicatorColor,...
                      'indicatorLineStyle', obj.candleIndicatorLineStyle,...
                      'indicatorLineWidth', 4,...
                      'indicatorWidth',     indicatorWidth,...
                      'lineStyle',          '-',...
                      'lineWidth',          1,...
                      'marker',             obj.candleMarker,...
                      'parent',             obj.axesHandle,...
                      'side',               side);
                  
                  
             % Assign the variablesToPlot(Right) property for use 
             % later (It is important when it comes to saving the
             % data behind the figure to excel)
             if strcmpi(side,'left')
                 obj.variablesToPlot = varsOP;
             else
                 obj.variablesToPlotRight = varsOP;
             end

        end
        
        %{
        -------------------------------------------------------------------
        Create area plot
        -------------------------------------------------------------------
        %}
        function imagePlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data = obj.dataToGraph;
            else
                data = obj.dataToGraphRight;
            end
            
            if isempty(data)
                return
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            nb_image(data','parent', obj.axesHandle);
            
        end
        
        %{
        -------------------------------------------------------------------
        Create radar plot
        -------------------------------------------------------------------
        %}
        function plotRadar(obj)
            
            data   = obj.dataToGraph;
            col    = obj.colorOrder;
            
            if ~isempty(obj.dataToGraphRight)
                warning('nb_graph_cs:plotRadar:NotPossibleToPlotAginstRightAxes',[mfilename ':: It is not possible to plot any variables against the right axes when plotting radar plot.'])
            end
            
            if isempty(data)
                return
            end
            
            % Find the corresponding type name of the mnemonics, if
            % given as a x-tick mark label.
            labels = obj.typesToPlot;
            if ~isempty(obj.xTickLabels)
                
                try
                    checked = obj.xTickLabels(1:2:end);
                    new     = obj.xTickLabels(2:2:end);
                    datT    = strtrim(labels);
                    for ii = 1:length(checked)
                        ind      = find(strcmpi(checked{ii},datT),1,'last');
                        if ~isempty(ind)
                            labels{ind} = new{ii};
                        end
                    end
                catch Err
                    error([mfilename ':: Wrong input given to the xTickLabels property:: ' Err.message])
                end
                
            end
            
            if ~isempty(obj.lookUpMatrix)

                for ii = 1:length(labels)

                    labels{ii} = nb_graph.findVariableName(obj,labels{ii});

                end

            end
            
            % Interpret the local variables syntax
            if ~isempty(obj.localVariables)
                for ii = 1:length(labels)
                    labels{ii} = nb_localVariables(obj.localVariables,labels{ii});
                end
            end
            
            variables = obj.variablesToPlot;
            lineS     = repmat({'-'},1,size(data,2));
            for ii = 1:2:size(obj.lineStyles,2)
            
                var    = obj.lineStyles{ii};
                locVar = find(strcmp(var,variables),1);
                try
                    lineS{locVar} = obj.lineStyles{ii + 1};
                catch
                    
                    locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                    type            = 'variablesToPlot';
                    if isempty(locVarOtherSide)
                        warning('nb_graph_cs:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineStyles'' property.'])
                    end
                    
                end    
                
            end
                  
            % Do the plotting
            %--------------------------------------------------------------
            nb_radar(data,...
                     'cData',            col,...
                     'fontColor',        obj.radarFontColor,...
                     'fontName',         obj.fontName,...
                     'fontSize',         obj.axesFontSize,...
                     'fontUnits',        obj.fontUnits,...
                     'fontWeight',       obj.axesFontWeight,...
                     'labels',           labels,...
                     'lineStyle',        lineS,...
                     'lineWidth',        obj.lineWidth,...
                     'numberOfIsoLines', obj.radarNumberOfIsoLines,...
                     'parent',           obj.axesHandle,...
                     'rotate',           obj.radarRotate,...
                     'scale',            obj.radarScale);
                 
            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch
                dv = true;
            end
            if dv
                [labX,labY] = getLabelVariables(obj);
                func        = @(src,event)nb_displayValue(src,event,labY,labX);
                addlistener(obj.axesHandle,'mouseOverObject',func);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Create scatter plot
        -------------------------------------------------------------------
        %}
        function scatterPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            if strcmpi(side,'left')
                
                if isempty(obj.scatterVariables)
                    return
                end
                
                scVars  = obj.scatterVariables;
                if isempty(obj.scatterTypes)
                    try
                        obj.scatterTypes = obj.DB.types(1:2);
                    catch
                        error([mfilename ':: The given data must have at least two types when doing scatter plots.'])
                    end
                end
                scTypes = obj.scatterTypes;
                col     = obj.colorOrder;
                
            else
                
                if isempty(obj.scatterVariablesRight)
                    return
                end
                scVars  = obj.scatterVariablesRight;
                scTypes = obj.scatterTypesRight;
                col     = obj.colorOrderRight;
                
            end
            
            % Load the data to plot
            %------------------------------------------------------
            data      = obj.DB.double;
            vars      = obj.DB.variables;
            types     = obj.DB.types;
            
            % Find the variables to be plotted for each scatter
            %------------------------------------------------------
            indVars = cell(1,size(scVars,2)/2);
            if size(scVars,2) < 2
                error([mfilename ':: The property scatterVariables(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{''Var1'',''Var2'',...},...}'])
            end
            
            kk = 1;
            for ii = 2:2:size(scVars,2)
                
                if iscell(scVars{ii})
                    indVars{kk} = nb_cs.locateStrings(scVars{ii},vars);
                    kk          = kk + 1;
                else
                    error([mfilename ':: The property scatterVariables(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{''Var1'',''Var2'',...},...}'])
                end
                
            end
            
            % Find the types to be plotted for each scatter
            %------------------------------------------------------
            if size(scTypes,2) ~= 2
                error([mfilename ':: The property scatterTypes(Right) must have size 1x2 (with the types to plot).'])
            end
            indTypes = nb_cs.locateStrings(scTypes,types);
            
            numberOfGroups = size(indVars,2);
            
            % Get the data to plot
            %------------------------------------------------------
            for ii = 1:numberOfGroups
                
                % Get marker
                scTemp = scVars{ii*2 - 1};
                ind    = find(strcmpi(scTemp,obj.markers),1);
                if isempty(ind)
                   marker = 'o';  
                else
                   marker = obj.markers{ind + 1}; 
                end
                
                indVarsTemp  = indVars{ii};
                xData        = data(indTypes(1),indVarsTemp);
                yData        = data(indTypes(2),indVarsTemp);
               
                % Do the plotting
                %--------------------------------------------------
                nb_scatter(xData,yData,...
                           'cData',            col(ii,:),...
                           'marker',           marker,...
                           'lineStyle',        obj.scatterLineStyle,...
                           'lineWidth',        obj.lineWidth,...
                           'markerSize',       obj.markerSize,...
                           'parent',           obj.axesHandle,...
                           'side',             side);
                           
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Get the scatter plot sizes (represented as double vectors).
        
        Used to get the color order properties correct
        -----------------------------------------------------------
        %}
        function [tempData,tempDataRight] = getScatterSizes(obj)
            
            if isempty(obj.scatterVariables)
                tempData = nan(1,1);
            else
                s        = size(obj.scatterVariables,2)/2;
                tempData = nan(1,s);
            end
            
            if ~isempty(obj.scatterVariablesRight)
                s             = size(obj.scatterVariablesRight,2)/2;
                tempDataRight = nan(1,s);
            else
                tempDataRight = [];
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Plot variables with different plot types in a given plot.
        -------------------------------------------------------------------
        %}
        function addPlotTypes(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data = obj.dataToGraph;
                col  = obj.colorOrder;
                if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    variables = obj.DB.dataNames;
                else
                    variables = obj.variablesToPlot;
                end
            else
                data      = obj.dataToGraphRight;
                col       = obj.colorOrderRight;
                variables = obj.variablesToPlotRight;
            end
            
            if isempty(data)
                return
            end
            
            sData = size(data,2);
            xData = 1:size(data,1);
            
            % Get the plot types 
            %--------------------------------------------------------------
            plotT = cell(1,sData);
            for ii = 1:sData
                plotT{ii} = obj.plotType;
            end

            % Interpreter the inputs
            plotTs  = obj.plotTypes;
            for kk = 1:2:size(plotTs,2)
                var    = plotTs{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    plotT{locVar} = plotTs{kk + 1};
                catch
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''plotTypes'' property.'])
                        
                    else
                        
                        if strcmpi(side,'left')
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                            type            = 'variablesToPlot';
                        else
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                            type            = 'variablesToPlotRight';
                        end
                        if isempty(locVarOtherSide)
                            warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''plotTypes'' property.'])
                        end
                        
                    end
                    
                end
            end
            
            % Set default options for the lines
            %--------------------------------------------------------------
            index    = find(strcmpi(plotT,'line'));
            sLData   = size(find(index),2);
            lineVars = variables(index);
            
            if ~isempty(obj.lineWidths)
                
                warning('nb_graph_cs:addPlotTypes:lineWidthsNotAnOption',[mfilename ':: The property ''lineWidths'' will not be setting '...
                        'the width of the lines when lines are combined with other plotting types. Sorry that is not possible!'])
                    
            end
            
            lineStyle = cell(1,sLData);
            marker    = cell(1,sLData);
            
            for ii = 1:sLData
                lineStyle{ii}   = '-';
                marker{ii}      = 'none';
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = obj.lineStyles;
            for kk = 1:2:size(lineS,2)
                var    = lineS{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    lineStyle{locVar} = lineS{kk + 1};
                catch  %#ok<*CTCH>
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''lineStyles'' property.'])
                        
                    else
                    
                        if strcmpi(side,'left')
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                            type            = 'variablesToPlot';
                        else
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                            type            = 'variablesToPlotRight';
                        end
                        if isempty(locVarOtherSide)
                            warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''lineStyles'' property.'])
                        end
                        
                    end
                    
                end    
            end
            
            lineW  = ones(1,length(lineVars))*obj.lineWidth;
            lineWi = obj.lineWidths;
            for kk = 1:2:size(lineWi,2)
                var    = lineWi{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    lineW(locVar) = lineWi{kk + 1};
                catch %#ok<CTCH>
                    
                    if strcmpi(side,'left')
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                        type            = 'variablesToPlot';
                    else
                        locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                        type            = 'variablesToPlotRight';
                    end
                    if isempty(locVarOtherSide)
                        warning('nb_graph_data:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineWidths'' property.'])
                    end
                    
                end    
            end
            
            mark   = obj.markers;
            for kk = 1:2:size(mark,2)
                var    = mark{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    marker{locVar} = mark{kk + 1};
                catch 
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''markers'' property.'])
                        
                    else
                    
                        if strcmpi(side,'left')
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                            type            = 'variablesToPlot';
                        else
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                            type            = 'variablesToPlotRight';
                        end
                        if isempty(locVarOtherSide)
                            warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                        end
                        
                    end
                    
                end

            end
            
            % Decide the shading
            %--------------------------------------------------------------
            if isempty(obj.barShadingTypes)
                shadedBars = zeros(size(data,1),1);
            else
                shadedBars = ismember(obj.typesToPlot,obj.barShadingTypes);  
            end
            
            % Test some given properties
            %--------------------------------------------------------------
            if ~isempty(obj.sumTo)
                warning('nb_graph_cs:addPlotTypes:sumToNotAnOption',[mfilename 'The ''sumTo'' option is not supported for combination plots.'])
            end
            
            if any(shadedBars(:))
                edgeLineS = '-';
            else
                edgeLineS = 'none';
            end
            if isempty(obj.barLineWidth)
                edgeLineWidth = obj.lineWidth;
            else
                edgeLineWidth = obj.barLineWidth;
                if edgeLineWidth == 0
                    edgeLineWidth = 1;
                    edgeLineS     = 'none';
                end
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            nb_plotComb(xData,data,...
                        'abrupt',        obj.areaAbrupt,...
                        'alpha1',        obj.barAlpha1,...
                        'alpha2',        obj.barAlpha2,...
                        'barWidth',      obj.barWidth,...
                        'baseValue',     obj.baseValue,...
                        'blend',         obj.barBlend,...
                        'cData',         col,...
                        'edgeColor',     'same',...
                        'edgeLineStyle', edgeLineS,...
                        'edgeLineWidth', edgeLineWidth,...
                        'lineStyle',     lineStyle,...
                        'lineWidth',     lineW,...
                        'marker',        marker,...
                        'markerSize',    obj.markerSize,...
                        'parent',        obj.axesHandle,...
                        'side',          side,...
                        'direction',     obj.barShadingDirection,...
                        'shadeColor',    obj.barShadingColor,...
                        'shaded',        shadedBars,...
                        'types',         plotT);
                                           
        end
        
        %{
        -------------------------------------------------------------------
        Add fan chart
        -------------------------------------------------------------------
        %}
        function addFanChart(obj)
            
            if isempty(obj.variablesToPlot)
                return
            end
            
            if strcmp(obj.plotType,'line')
                
                if ~isempty(obj.fanDatasets)
                    
                    if isempty(obj.fanVariable)
                        % Default variable to plot the fan chart of is the
                        % last element of the 'variablesToPlot' property
                        obj.fanVariable = obj.variablesToPlot{1,end};
                        if isempty(obj.fanVariable)
                            return
                        end  
                    end
                    
                    foundLeft  = sum(strcmp(obj.fanVariable, obj.variablesToPlot));
                    foundRight = sum(strcmp(obj.fanVariable, obj.variablesToPlotRight));
                    if foundLeft
                        side      = 'left';
                    elseif foundRight
                        side      = 'right';
                    else
                        error([mfilename ':: Did not found the variable given by the property ''fanVariable'' in the ''variablesToPlot'' '...
                                        'or ''variablesToPlotRight'' properties.'])
                    end
                    
                    if isstruct(obj.fanData) && strcmpi(obj.graphMethod,'graphinfostruct')                        
                        ind   = regexp(obj.fieldName,'\d*$');
                        field = obj.fieldName(1:ind-1);
                        fData = obj.fanData.(field); 
                    else
                        fData = obj.fanData;
                    end
                        
                    if sum(strcmp(obj.fanVariable,fData.variables))
                        data = fData.window(obj.typesToPlot,obj.fanVariable);
                        data = reshape(data.data,data.numberOfTypes,data.numberOfDatasets,1);
                    else
                        try
                            data = createVariable(fData,obj.fanVariable,obj.fanVariable);
                            data = data.window(obj.typesToPlot,obj.fanVariable);
                            data = reshape(data.data,data.numberOfTypes,data.numberOfDatasets,1);
                        catch
                            data = [];
                        end
                    end
 
                else 
                    % Then there is nothing more to do here
                    return;
                end
                
                if ~isempty(data)
                
                    % Evaluate the factor option
                    %------------------------------------------------------
                    data = data*obj.factor;
                    
                    % If we plot on a nb_graphPanel we must make it
                    % robust when setting the yLim property
                    %----------------------------------------------
                    ylim = obj.yLim;
                    if ~isempty(ylim)
                        ind       = data < ylim(1);
                        data(ind) = ylim(1);
                        ind       = data > ylim(2);
                        data(ind) = ylim(2);
                    end

                    % Plot it
                    %------------------------------------------------------
                    if strcmpi(obj.fanMethod,'graded')
                        f = nb_gradedFanChart(1:size(data,1),data,...
                            'alpha',        obj.fanAlpha,...
                            'parent',       obj.axesHandle,...
                            'side',         side);
                    else
                        f = nb_fanChart(1:size(data,1),data,...
                            'cData',        obj.fanColor,...
                            'parent',       obj.axesHandle,...
                            'percentiles',  obj.fanPercentiles,...
                            'side',         side,...
                            'method',       obj.fanMethod);
                    end
                    % Remove the central line
                    %------------------------------------------------------
                    set(f.central,'lineStyle','none','legendInfo','off'); 
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Create the data for the bands of the fan chart(s)
        -------------------------------------------------------------------
        %}
        function constructBands(obj)
             
            if ~isempty(obj.fanDatasets)

                if iscell(obj.fanDatasets)
                    % This section can be use if the bands is in a different
                    % dataset. The data must be the fan layers absolute 
                    % value. The data must be loaded from excel or .mat
                    % files
                    obj.fanData = nb_cs(obj.fanDatasets);
                elseif isa(obj.fanDatasets,'nb_cs') || isstruct(obj.fanDatasets)
                    % Get the data which is used to calculate the 
                    % percentiles Here I assume that each page is one 
                    % simulations. 
                    obj.fanData = obj.fanDatasets;
                else
                    error([mfilename ':: The property ''fanDatasets '' must be given as a cell or a nb_cs object. For more see documentation.'])
                end
                if ~isstruct(obj.fanData)
                    obj.fanData = breakLink(obj.fanData);
                end
                
                % Assure that the fanData property has as least the
                % same timespan as the graph
                if isstruct(obj.fanDatasets)
                    fields = fieldnames(obj.fanData);
                    for ii = 1:length(fields)
                        obj.fanData.(fields{ii}) = expand(obj.fanData.(fields{ii}),obj.typesToPlot,'nan','off');
                    end
                else
                    obj.fanData = expand(obj.fanData,obj.typesToPlot,'nan','off');
                end

            end
            
        end
        
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to remove some plotting 
        % handles
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the plotter object
            copyObj.manuallySetFigureHandle = 0;
            copyObj.figureHandle            = [];
            copyObj.axesHandle              = [];
            copyObj.UIContextMenu           = [];
            copyObj.parent                  = [];
%             if isa(copyObj.localVariables,'nb_struct')
%                 copyObj.localVariables = copy(copyObj.localVariables);
%             end
            
            % Copy all the nb_annotation handles
            if iscell(copyObj.annotation)
            
                for ii = 1:length(copyObj.annotation)

                    copied                 = copyObj.annotation{ii};
                    copyObj.annotation{ii} = copied.copy;

                end
                
            elseif isa(copyObj.annotation,'nb_annotation')
                
                copyObj.annotation = copyObj.annotation.copy;
                
            end
            
            % Copy the figure title and footer handles
            if ~isempty(copyObj.figTitleObjectEng)
                copyObj.figTitleObjectEng = copy(copyObj.figTitleObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            if ~isempty(copyObj.footerObjectEng)
                copyObj.footerObjectEng = copy(copyObj.footerObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            
        end
        
    end
    
    %----------------------------------------------------------------------
    % Static subfunctions
    %----------------------------------------------------------------------
    methods (Static=true,Hidden=true)
        
        function [cellInput,message,ind] = checkTypes(cellInput,message,start,incr,varsOrTypes,string)
             
            ind = [];
            if ~isempty(cellInput)

                transBack = 0;
                if ~iscell(cellInput)
                    cellInput = {cellInput};
                    transBack = 1;
                end
                
                cInput = cellInput;
                ind    = true(1,length(cInput)/incr);
                for ii = start:incr:length(cInput)

                    types  = cInput{ii};
                    if ~iscell(types)
                        types   = {types};
                    end
                        
                    found  = ismember(types,varsOrTypes);
                    if ~all(found) 

                        ind(ii/incr) = false; 
                        newMessage = ['The type(s) ' nb_cellstr2String(types,', ',' and ') ' used by ' string ' is not found in the new data. '...
                                      'It will be deleted.'];
                        message = nb_addMessage(message,newMessage);  
                        
                    end

                end
                
                % Remove the elements that includes removed types
                ind       = repmat(ind,incr,1);
                ind       = ind(:)';
                cellInput = cInput(ind);

                if transBack
                    cellInput = cellInput{1};
                end
                
            end
            
        end
        
        function [s,message] = checkScatterOptions(obj,newDataSource,s,message)
            
            alreadyRemoved = 0;
            if ~isempty(obj.scatterTypes)
                    
                % If not both scatter types are found we must remove
                % the scatter options
                ind = ismember(obj.scatterTypes,newDataSource.types);
                if ~all(ind)

                    s.properties.scatterVariables = {};
                    s.properties.scatterTypes     = {};
                    alreadyRemoved                = 1;
                    if strcmpi(obj.plotType,'scatter')
                        newMessage = ['The given scatter types will be removed by your changes to the data; ' ...
                            nb_cellstr2String(obj.scatterTypes(~ind),', ',' and ') '. Nothing to plot!'];
                        message    = nb_addMessage(message,newMessage);
                    end

                end

            end

            alreadyRemovedRight = 0;
            if ~isempty(obj.scatterVariablesRight)

                % If not both scattervariables are found we must remove
                % the scatter options
                ind = ismember(obj.scatterTypesRight,vars);
                if all(~ind)

                    s.properties.scatterVariablesRight = {};
                    s.properties.scatterTypesRight     = {};
                    alreadyRemovedRight                = 0;
                    if strcmpi(obj.plotType,'scatter')
                        newMessage = ['The given scatter variables (right) will be removed by your changes to the data; ' ...
                            nb_cellstr2String(obj.scatterVariablesRight(~ind),', ',' and ') '. Nothing to plot!'];
                        message    = nb_addMessage(message,newMessage);
                    end

                end
                
            end
            
            if ~isempty(obj.scatterVariables) || alreadyRemoved
                
                [cInput,ind,rmGroups] = checkScatterVariables(obj.scatterVariables,newDataSource);
                obj.scatterVariables  = cInput(ind);

                if ~isempty(rmGroups)
                    
                    if strcmpi(obj.plotType,'scatter')
                        newMessage = ['The given scatter groups will be removed by your changes to the data; ' ...
                            nb_cellstr2String(rmGroups,', ',' and ') '.'];
                        message    = nb_addMessage(message,newMessage);
                    end

                end
                
            end

            if ~isempty(obj.scatterVariablesRight) || alreadyRemovedRight

                [cInput,ind,rmGroupsRight] = checkScatterVariables(obj.scatterVariablesRight,newDataSource);
                obj.scatterVariablesRight  = cInput(ind);

                if ~isempty(rmGroupsRight)

                    if strcmpi(obj.plotType,'scatter')
                        newMessage = ['The given scatter groups (right) will be removed by your changes to the data; ' ...
                            nb_cellstr2String(rmGroupsRight,', ',' and ') '.'];
                        message    = nb_addMessage(message,newMessage);
                    end

                end
                
            end
            
            function [cInput,ind,rmGroups] = checkScatterVariables(cInput,newDataSource)
                
                ind    = true(1,length(cInput)/2);
                for ii = 2:2:length(cInput)

                    variables  = cInput{ii};
                    if ~iscell(variables)
                        variables   = {variables};
                    end

                    found  = ismember(variables,newDataSource.variables);
                    if all(~found) 
                        ind(ii/2) = false; % The scatter group are to be removed
                    else
                        cInput{ii} = variables(found);
                    end

                end

                rmGroups = cInput(1:2:end);
                rmGroups = rmGroups(~ind);
                ind      = repmat(ind,2,1);
                ind      = ind(:)';
                
            end
            
        end
        
        function obj = unstruct(s)
            
            obj    = nb_graph_cs();
            obj.DB = nb_cs.unstruct(s.DB);
            fields = fieldnames(s);
            for ii = 1:length(fields)
                
                switch fields{ii}
                
                    case 'annotation'

                        ann = s.annotation;
                        if isstruct(ann)
                            ann = nb_annotation.fromStruct(ann);
                        elseif iscell(ann)
                            for jj = 1:length(ann)
                                if isstruct(ann{jj})
                                    ann{jj} = nb_annotation.fromStruct(ann{jj});
                                else
                                    if isvalid(ann{jj})
                                        ann{jj} = nb_annotation.fromStruct(ann{jj});
                                    end
                                end
                            end
                        end
                        obj.annotation = ann;
                        
                    case 'DB'
                        % Already done
                    case 'fanDatasets'
                        if isstruct(s.fanDatasets) && isfield(s,'class')
                            obj.fanDatasets = nb_cs.unstruct(s.fanDatasets);
                        else
                            obj.fanDatasets = s.fanDatasets;
                        end
                    case 'figTitleObjectEng'
                        if isstruct(s.figTitleObjectEng)
                            obj.figTitleObjectEng = nb_figureTitle.unstruct(s.figTitleObjectEng);
                        end
                    case 'figTitleObjectNor'
                        if isstruct(s.figTitleObjectEng)
                            obj.figTitleObjectNor = nb_figureTitle.unstruct(s.figTitleObjectNor);
                        end
                    case 'footerObjectEng'
                        if isstruct(s.figTitleObjectEng)
                            obj.footerObjectEng = nb_footer.unstruct(s.footerObjectEng);
                        end
                    case 'footerObjectNor'
                        if isstruct(s.figTitleObjectEng)
                            obj.footerObjectNor = nb_footer.unstruct(s.footerObjectNor);
                        end
                    case {'manuallySetColorOrder','manuallySetColorOrderRight','manuallySetLegend'}
                        obj.(fields{ii}) = s.(fields{ii});
                    otherwise
                        
                        if isprop(obj,fields{ii})
                            obj.(fields{ii}) = s.(fields{ii});
                        end
                        
                end
                
            end
            
        end
        
        function obj = loadobj(s)
        % Overload how the object is loaded from a .mat file
        
            obj = nb_graph_cs.unstruct(s);
            
        end
        
    end    
    
end
