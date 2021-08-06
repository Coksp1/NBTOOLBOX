classdef nb_graph_data < nb_graph
% Syntax:
%     
% obj = nb_graph_data(data)
% 
% Superclasses:
% 
% handle, nb_graph
%     
% Description:
%     
% This is a class for making dataseries graphics.
% 
% Constructor:
%     
%     obj = nb_graph_data(data)
%     
%     Input:
% 
%     - data : 
%
%        The input must be one of the following:
% 
%          > An object of class nb_data. E.g. nb_graph_data(data)
%
%          > A excel spreadsheet which could be read by the nb_data 
%            class. E.g. nb_graph_data('excelName')
%
%     Output:
% 
%     - obj : An object of class nb_graph_data
%     
% See also:
% nb_graph, nb_graph_ts, nb_graph_cs, nb_graph_adv, nb_graph_subplot
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
             
        % The periods for where to plot the bar. E.g 3 or [3,4]. Only an
        % option for the graphSubPlots() method. The lineStop must be
        % set to make this option work. Default is [].
        barPeriods              = [];
        
        % Sets the date from which the bar plot should be shaded. As 
        % an integer. Default is [].  
        barShadingObs           = [];          
               
        % A string with the color specification to use for the bars 
        % when the line with bars at the end plot type is triggered. 
        % One of 'nb' | 'red' | 'green' | 'yellow' | ''. Default is 'nb'.
        % Use the lineStop and barPeriods properties to trigger this plot
        % type.
        colorBarAtEnd           = 'nb'; 
        
        % All the dates of the plot as a cellstr. Not settable.        
        obs                     = {};               
        
        % Sets the date at which all the plotted lines will be dashed. 
        % Must be given as an integer with the obs (or a double when the
        % variableToPlotX is given)      
        dashedLine              = [];          
        
        % All the data given to the nb_graph_data object collected in a 
        % nb_data object. Should not be set using obj.DB = data! Instead   
        % see the nb_graph_data.resetDataSource method.                                                        
        DB                      = nb_data;                      
        
        % The width of the bars when the line with bars at the end plot 
        % type is triggered. Use the lineStop and barPeriods properties 
        % to trigger this plot type. Deault is 3.
        endBarWidth             = 3.
        
        % Sets the end obs of the graph. Either as an integer. If the given 
        % obs is after the end obs of the data, the data will be appended 
        % with nan values. I.e. the graph will be blank for these obs. 
        %
        % Not used when variableToPlotX property is set, use xLim instead.
        endGraph                = [];          
          
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
        
        % If highlighted area between two observations of the graph is  
        % wanted set this property.
        % 
        % One highlighted area: 
        % A cell array on the form {obs1, obs2}
        % 
        % More highlighted areas: 
        % A nested cell array on the form 
        % {{obs1(1), obs2(1)},{obs1(2), obs2(2)},...} 
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
        
        % The period that the line should be stopped. E.g. 2. This will
        % trigger the plot type line with bars at end. See also the
        % barPeriods property. Default is [].
        lineStop                = [];
        
        % Set how to interpret missing observations. Must be a string.
        % Either;
        % 
        % > 'interpolate' : Linearly interpolate the missing values. 
        %
        % > 'none'        : No interpolation (default)
        missingValues           = 'none';           
        
        % Sets the max/min y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this setting only sets the left y-axis limits. 
        % 
        % Only an option for the graphInfoStruct(...) method. 
        mYLim                   = [];               
        
        % If setted this property would make the graph blank after the 
        % provided obs, but the x-axis would still keeps its axis 
        % limits. Must be an integer.   
        %
        % Caution: Not possible to combine with variablesToPlotX
        nanAfterObs             = '';               
        
        % If setted this property would make the graph blank before the 
        % provided obs, but the x-axis would still keeps its axis 
        % limits. Must be an integer.
        %
        % Caution: Not possible to combine with variablesToPlotX
        nanBeforeObs            = '';               
        
        % Sets the nan option for individual variables. Must be given 
        % as a cell. I.e. {'var1', {2, 4}, ...
        % 'var2', {2, 4},...}. This will make both 'var1' and 'var2' 
        % variables blank before 2 and after 4 (Not including.)
        % in the given graph.  
        %
        % Caution: Not possible to combine with variablesToPlotX
        nanVariables            = {};                    
                     
        % Sets the plot type. Either:
        % 
        % > 'line'        : If line plot(s) is wanted. Default. 
        % 
        % > 'stacked'     : If stacked bar plot(s) is wanted. Not an 
        %                   option for the graphSubPlots(...) method. 
        % 
        % > 'grouped'     : If grouped bar plot(s) is wanted. 
        % 
        % > 'dec'         : If decomposition plot(s) is wanted. Which is 
        %                   a bar plot with also a line with the sum of 
        %                   the stacked bars. Not an option for the
        %                   graphSubPlots(...) method.
        % 
        % > 'area'        : If area plot(s) is wanted.
        % 
        % > 'candle'      : If candle plot(s) is wanted.
        % 
        % > 'scatter'     : If scatter plot(s) is wanted.      
        plotType                = 'line';           
        
        % Sets the plot type of the given variables. Must be a cell 
        % array on the form: {'var1', 'line', 'var2', 'grouped',...}. 
        % Here we set the plot type of the variables 'var1' and 'var2' 
        % to 'line' and 'grouped' respectively. The variables given 
        % must be included in the variablesToPlot or 
        % variablesToPlotRight properties.
        % 
        % See the property plotType above on which plot types that are 
        % supported.        
        plotTypes               = {};               

        % Sets the scatter line style. Must be string. See 'lineStyles'
        % for supported inputs. (Sets the line style of all scatter plots)
        scatterLineStyle        = 'none';
        
        %   Sets the start and end to be used for the scatter plot plotted  
        %   against the left axes. Must be a nested cell array. The obs 
        %   can be given as integers. E.g:
        %
        %   {'scatterGroup1',{'startObs1','endObs1'},...
        %    'scatterGroup2',{'startObs2','endObs2'},...}
        %
        %   Caution  : This property must be provided to produce
        %              a scatter plot! (Or of course scatterObsRight)
        %
        %   Be aware : Each obs will result in one point in the 
        %              scatter.
        scatterObs              = {};
        
        %   Sets the start and end to be used for the scatter plot plotted  
        %   against the right axes. Must be a nested cell array. The obs 
        %   can be given as integers. E.g:
        %
        %   {'scatterGroup1',{'startObs1','endObs1'},...
        %    'scatterGroup2',{'startObs2','endObs2'},...}
        %
        %   Caution  : This property must be provided to produce
        %              a scatter plot! (Or of course scatterObs)
        %
        %   Be aware : Each obs will result in one point in the 
        %              scatter.
        scatterObsRight       = {};

        %   The variables used for the scatter plot. Must be a 1x2 cellstr 
        %   array. The first element will be the variable plotted against 
        %   the x-axis, while the second element will be the variable 
        %   plotted against the left y-axis. E.g:
        %
        %   {'var1','var2'}
        scatterVariables        = {};

        %   The variables used for the scatter plot. Must be a 1x2 cellstr 
        %   array. The first element will be the variable plotted against 
        %   the x-axis, while the second element will be the variable 
        %   plotted against the right y-axis. E.g:
        %
        %   {'var1','var2'}
        scatterVariablesRight   = {};           
        
        % Sets the x-ticks spacing. Must be an integer (or a double when
        % variableToPlotX is used)     
        spacing                 = [];               
        
        % Sets the start obs of the graph. Must be a string or an 
        % integer. If this obs is before the start obs of the data, the  
        % data will be expanded with nan (blank values) for these periods. 
        %
        % Not used when variableToPlotX property is set, use xLim instead.
        startGraph              = [];          
           
        % Set the variable to use as the x-axes variable. I.e. when you 
        % want to plot one or more variables againts this one. As a string.
        %
        % If the graphSubPlots method is used this intput can be set to 
        % cellstr with the same size as the variablesToPlot input.
        % You can use this to set individual domains for each subplot.
        variableToPlotX         = '';
        
        % Sets the obs(s) of where to place a vertical line(s). 
        % (Dotted orange line is default). Must be a number or a cell 
        % array of numbers with the obs(s) for where to place the 
        % vertical line(s). I.e. obs1 or {obs1,obs2,...} 
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
        % Only an option when the plotType property is set to 'scatter'
        % or when variableToPlotX is used.
        xLim                    = [];

        % Sets the scale of the x-axis. Either {'linear'} | 'log'.
        %
        % Only an option when plotType is set to 'scatter' or when 
        % variableToPlotX is used.
        xScale                  = 'linear'; 
                     
        % The location of the x-axis tick marks labels. Either  
        % {'bottom'} | 'top' | 'baseline'. 'basline' will only work in 
        % combination with the xtickLocation property set to a double
        % with the basevalue.        
        xTickLabelLocation      = 'bottom'; 

        % The alignment of the x-axis tick marks labels. {'normal'} | 
        % 'middle'.        
        xTickLabelAlignment     = 'normal';
        
        % The location of the x-axis tick marks. Either {'bottom'} | 
        % 'top' | double. If given as a double the tick marks will be 
        % placed at this value (where the number represent the y-axis
        % value).
        xTickLocation           = 'bottom'; 

        % Sets the rotation of the x-axis tick mark labels. Must be a 
        % scalar with the number of degrees the labels should be 
        % rotated. Positive angles cause counterclockwise rotation.        
        xTickRotation           = 0;            
        
        % Sets the start obs of where to start the x-tick mark labels.
        % Must be an integer (a double when variableToPlotX is used).       
        xTickStart              = [];                   
        
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
        
        alreadyAdjusted             = 0;                % An indicator of font size beeing adjusted. 
        fanData                     = [];               % A property which temporary stores the data for fan charts
        fanVariableIndex            = [];               % Not settable. 
        obsOfGraph                  = {};               % X-tick observations of graph. Not settable.  
        manuallySetEndGraph         = 0;                % Indicator if the endGraph property has been set manually
        manuallySetStartGraph       = 0;                % Indicator if the startGraph property has been set manually
              
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_graph_data(varargin)
            
            obj = obj@nb_graph;
            
            if nargin ~= 0 % Makes it possible to initilize an empty object
           
                switch class(varargin{1})

                    case 'nb_data'

                        obj.DB = varargin{1};

                    case 'char'

                        obj.DB = nb_data(varargin{1});

                    otherwise

                        error([mfilename ':: The input to this function must be a object of class nb_data.'])

                end

                % Set some default properties
                obj.startGraph      = obj.DB.startObs;
                obj.endGraph        = obj.DB.endObs;
                obj.variablesToPlot = obj.DB.variables;
                
            end
                
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
                            
                        case 'manuallysetendgraph'
                            
                            obj.manuallySetEndGraph = propertyValue;
                            
                        case 'manuallysetstartgraph'
                            
                            obj.manuallySetStartGraph = propertyValue;
                            
                        case 'plotaspectratio'
                            
                            obj.plotAspectRatio = propertyValue;
                            
                        case 'returnlocal'
                            
                            obj.returnLocal = propertyValue;
                            
                        case 'uicontextmenu'
                            
                            obj.UIContextMenu = propertyValue;
                            
                        case 'variablestoplot'
                            
                            obj.variablesToPlot = propertyValue;
                            
                        otherwise
                            
                            error([mfilename ':: The class nb_graph_data has no property ''' propertyName ''' or you have no access to set it.'])
                    end

                end
            end

        end
        
        function disp(obj)
            
            link = nb_createLinkToClass(obj);
            disp([link, ' with:'])
            disp(['   <a href="matlab: nb_graph.dispMethods(''' class(obj) ''')">Methods</a>']);
            
            groups = {
                'Annotation properties:',   {'highlight','highlightColor','verticalLine','verticalLineColor',...
                                             'verticalLineLimit','verticalLineStyle','verticalLineWidth'}
                'Axes properties:',         {'endGraph','mYLim','obs','startGraph','spacing','xLim',...
                                             'xScale','xTickLabelLocation','xTickLabelAlignment','xTickLocation',...
                                             'xTickRotation','xTickStart','yDir','yDirRight','yLim','yLimRight',...
                                             'yOffset','yScale','yScaleRight','ySpacing','ySpacingRight'}
                'Data properties:',         {'DB'}
                'Fan chart properties:',    {'fanColor','fanDatasets','fanLegend','fanLegendFontSize',...
                                             'fanLegendLocation','fanLegendText','fanMethod',...
                                             'fanPercentiles','fanVariable'}
                'Missing data properties:', {'missingValues','nanAfterObs','nanBeforeObs','nanVariables'}                             
                'Plot properties:',         {'barPeriods','barShadingObs','colorBarAtEnd','dashedLine','endBarWidth',...
                                             'lineStop','plotType','plotTypes','variableToPlotX'} 
                'Scatter plot properties:', {'scatterObs','scatterObsRight','scatterLineStyle','scatterVariables',...
                                             'scatterVariablesRight'}                       
            };
            groups = nb_graph.mergeDispTables(groups,nb_graph.dispTableGeneric());
            remove = {'numberOfGraphs'};
            type   = 'properties';
            disp(nb_createDispTable(obj,groups,remove,type));
            
        end
        
        varargout = get(varargin)
        varargout = graph(varargin)
        varargout = graphSubPlots(varargin)
        varargout = graphInfoStruct(varargin)
        varargout = timespan(varargin)
        varargout = update(varargin)
        varargout = saveData(varargin)
        
        %==========================================================
        % Overloaded get methods (So it is robust to locally
        % defined variables)
        %==========================================================
        
        function out = get.barShadingObs(obj)
            
            if ischar(obj.barShadingObs) && ~obj.returnLocal
                ind = strfind(obj.barShadingObs,'%#');
                if isempty(ind)
                    out = obj.barShadingObs;
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.barShadingObs);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end
                end
                
            elseif iscell(obj.barShadingObs) && ~obj.returnLocal
                
                out = obj.barShadingObs;
                for ii = 2:2:length(out)
                
                    if ischar(out{ii})
                    
                        ind = strfind(out{ii},'%#');
                        if ~isempty(ind)
                            
                            if isstruct(obj.localVariables)
                                out{ii} = nb_localVariables(obj.localVariables,out{ii});
                            else
                                error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                            end
                            
                            if ischar(out{ii})
                                out{ii} = str2double(out{ii});
                            end
                            
                        end
                        
                    end
                
                end    
                
            else
                out = obj.barShadingObs;
            end
            
            if ischar(out)
                out = str2double(out);
            end
            
        end
        
        function out = get.endGraph(obj)
            
            if ~obj.manuallySetEndGraph
                out = obj.DB.getRealEndObs();
            elseif ischar(obj.endGraph) && ~obj.returnLocal
                ind = strfind(obj.endGraph,'%#');
                if isempty(ind)
                    out = obj.endGraph;
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.endGraph);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                end
            else
                out = obj.endGraph;
            end
            
            if ischar(out)
                out = str2double(out);
            end
            
        end
        
        function out = get.startGraph(obj) 
            
            if ~obj.manuallySetStartGraph
                out = obj.DB.getRealStartObs();
            elseif ischar(obj.startGraph) && ~obj.returnLocal
                ind = strfind(obj.startGraph,'%#');
                if isempty(ind)
                    out = obj.startGraph;
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.startGraph);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                end
            else
                out = obj.startGraph;
            end
            
            if ischar(out)
                out = str2double(out);
            end
            
        end
        
        function out = get.xTickStart(obj) 
            
            if ischar(obj.xTickStart) && ~obj.returnLocal
                ind = strfind(obj.xTickStart,'%#');
                if isempty(ind)
                    out = obj.xTickStart;
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.xTickStart);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                end
            else
                out = obj.xTickStart;
            end
            
            if ischar(out)
                out = str2double(out);
            end
            
        end
        
    end
    
    methods (Access=public,Hidden=true)
        
        function variableToPlotXGUI(obj,~,~)
        % Set properties of the axes in a GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_variableToPlotXGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
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

            uimenu(propertiesMenu,'Label','Plot type','Callback',@obj.selectPlotTypeGUI);
            uimenu(propertiesMenu,'Label','Select variable','Callback',@obj.selectVariableGUI);
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Left axes variables','Callback',{@obj.reorderGUI,'left'});
                uimenu(reorderM,'Label','Right axes variables','Callback',{@obj.reorderGUI,'right'});
            uimenu(propertiesMenu,'Label','Patch','Callback',@obj.patchGUI);
            uimenu(propertiesMenu,'Label','Legend','Callback',@obj.legendGUI);
            uimenu(propertiesMenu,'Label','Title','tag','title','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','X-Axis Label','tag','xlabel','Callback',@obj.addAxesTextGUI);
            yLab = uimenu(propertiesMenu,'Label','Y-Axis Label','Callback','');
                uimenu(yLab,'Label','Left','tag','yLabel','Callback',@obj.addAxesTextGUI);
                uimenu(yLab,'Label','Right','tag','yLabelRight','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','Axes','Callback',@obj.axesPropertiesGUI);
            uimenu(propertiesMenu,'Label','X-Tick Variable','Callback',@obj.variableToPlotXGUI);
            uimenu(propertiesMenu,'Label','Look Up','Callback',@obj.lookUpGUI);  
            uimenu(propertiesMenu,'Label','General','Callback',@obj.generalPropertiesGUI);  

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
                message = 'Cannot plot the data type of the updated data in a dimensionless graph. Save it to a new dataset and graph that dataset!';
                return

            else
                
                % Check the obs properties
                %---------------------
                if get(obj,'manuallySetEndGraph')
                    if newDataSource.endObs < obj.endGraph
                        newMessage = ['The graphs end observation is after the end obs of the dataset (' int2str(newDataSource.endObs) '). Reset to ' int2str(newDataSource.endObs)];
                        message    = nb_addMessage(message,newMessage);
                        s.properties.endGraph = newDataSource.endObs;
                    elseif obj.endGraph < newDataSource.startObs
                        s.properties.endGraph = newDataSource.endObs;
                        newMessage = ['The graphs end observation is before the start obs of the dataset (' int2str(newDataSource.startObs) '). Reset to ' int2str(newDataSource.endObs)];
                        message    = nb_addMessage(message,newMessage);
                    end
                end

                if isnumeric(obj.barShadingObs)
                    [s.properties.barShadingObs,message] = nb_graph_data.checkObs(obj.barShadingObs,message,1,1,newDataSource,'bar shading obs');
                else
                    [s.properties.barShadingObs,message] = nb_graph_data.checkObs(obj.barShadingObs,message,2,2,newDataSource,'bar shading obs');
                end
                [s.properties.dashedLine,message]        = nb_graph_data.checkObs(obj.dashedLine,message,1,1,newDataSource,'dashed line start obs');
                [s.properties.highlight,message]         = nb_graph_data.checkObs(obj.highlight,message,1,1,newDataSource,'observations of the highlight areas');
                [s.properties.nanAfterObs,message]       = nb_graph_data.checkObs(obj.nanAfterObs,message,1,1,newDataSource,'nan after obs');
                [s.properties.nanBeforeObs,message]      = nb_graph_data.checkObs(obj.nanBeforeObs,message,1,1,newDataSource,'nan before obs');
                [s.properties.nanVariables,message]      = nb_graph_data.checkObs(obj.nanVariables,message,2,2,newDataSource,'nan variables');
                [s.properties.scatterObs,message]        = nb_graph_data.checkObs(obj.scatterObs,message,2,2,newDataSource,'observations of the scatter groups');
                [s.properties.scatterObsRight,message]   = nb_graph_data.checkObs(obj.scatterObsRight,message,2,2,newDataSource,'observations of the scatter groups (right)');

                if get(obj,'manuallySetStartGraph')
                    if newDataSource.endObs < obj.startGraph
                        s.properties.startGraph = newDataSource.startObs;
                        newMessage = ['The graphs start observation is after the end obs of the dataset (' int2str(newDataSource.startObs) '). Reset to ' int2str(newDataSource.startObs)];
                        message    = nb_addMessage(message,newMessage);
                    elseif obj.startGraph < newDataSource.startObs
                        newMessage = ['The graphs start observation is before the start obs of the dataset (' int2str(newDataSource.startObs) '). Reset to ' int2str(newDataSource.startObs)];
                        message    = nb_addMessage(message,newMessage);
                        s.properties.startGraph = newDataSource.startObs;
                    end
                end

                [s.properties.verticalLine,message] = nb_graph_data.checkObs(obj.verticalLine,message,1,1,newDataSource,'observations of the vertical lines');
                [s.properties.xTickStart,message]   = nb_graph_data.checkObs(obj.xTickStart,message,1,1,newDataSource,'X-axis tick mark start obs');

                % Check the variableToPlotX
                %--------------------------
                vars = newDataSource.variables;
                if ~isempty(obj.variableToPlotX)
                    ind  = any(strcmp(obj.variableToPlotX,vars));
                    if ~ind

                        s.properties.variableToPlotX = newDataSource.variables{1};
                        if ~strcmpi(obj.plotType,'scatter') && ~strcmpi(obj.plotType,'candle')
                            newMessage = ['The given X-axis variable selected is removed by your changes to the data; ' ...
                                obj.variableToPlotX '. Changed to ' newDataSource.variables{1}];
                            message    = nb_addMessage(message,newMessage);
                        end

                    end
                end
                
                % Check the variables properties
                %-------------------------------            
                if ~isempty(obj.scatterVariables)
                    
                    % If not both scattervariables are found we must remove
                    % the scatter options
                    ind = ismember(obj.scatterVariables,vars);
                    if ~all(ind)
                        
                        s.properties.scatterVariables = {};
                        s.properties.scatterObs       = {};
                        if strcmpi(obj.plotType,'scatter')
                            newMessage = ['The given scatter variables will be removed by your changes to the data; ' ...
                                nb_cellstr2String(obj.scatterVariables(~ind),', ',' and ') '. Nothing to plot!'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    end
                    
                end
                
                if ~isempty(obj.scatterVariablesRight)
                
                    % If not both scattervariables are found we must remove
                    % the scatter options
                    ind = ismember(obj.scatterVariablesRight,vars);
                    if all(~ind)
                        
                        s.properties.scatterVariablesRight = {};
                        s.properties.scatterObsRight       = {};
                        if strcmpi(obj.plotType,'scatter')
                            newMessage = ['The given scatter variables (right) will be removed by your changes to the data; ' ...
                                nb_cellstr2String(obj.scatterVariablesRight(~ind),', ',' and ') '. Nothing to plot!'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
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
                
                    varsTP = obj.variablesToPlot;
                    ind    = ismember(varsTP,vars);
                    varsTR = varsTP(~ind);
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
        
        function [lVarsXNew,lVarsYNew] = getLabelVariablesScatter(obj,type)
        % Get labels of scatter plot
        %
        % - type : > 1         : For nb_displayValue
        %          > otherwise : For nb_plotLabels
        
            lVarsXNew = {};
            lVarsYNew = {};
            if ~isempty(obj.scatterObs)
                
                scDates = obj.scatterObs;
                for ii = 2:2:size(scDates,2)
                    startTemp = scDates{ii}{1};
                    endTemp   = scDates{ii}{2};
                    periods   = startTemp:endTemp;
                    lVarsXNew = [lVarsXNew, {strtrim(cellstr(num2str(periods'))')}]; %#ok<AGROW>
                end
                
                scVars    = obj.scatterVariables;
                if type == 1
                    scVars = {[scVars{1} ',' scVars{2}]};
                end
                lVarsYNew = {scVars};
                lVarsYNew = lVarsYNew(1,ones(1,length(lVarsXNew)));
                
            end

            if ~isempty(obj.scatterObsRight)
                
                scDates = obj.scatterObsRight;
                for ii = 2:2:size(scDates,2)
                    startTemp = scDates{ii}{1};
                    endTemp   = scDates{ii}{2};
                    periods   = startTemp:endTemp;
                    lVarsXNew = [lVarsXNew, {strtrim(cellstr(num2str(periods'))')}]; %#ok<AGROW>
                end
                
                scVars = obj.scatterVariablesRight;
                if type == 1
                    scVars = {[scVars{1} ',' scVars{2}]};
                end
                lVarsYNewR = {scVars};
                lVarsYNew  = [lVarsYNew,lVarsYNewR(1,ones(1,length(lVarsXNew)))];
                
            end
            
        end
          
    end
    
    %{
    =======================================================================
    Protected methods
    =======================================================================
    %}
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

                        warning('nb_graph_data:graph:wrongColorOrderInput',[mfilename ':: The property ''colorOrder'' doesn''t '...
                                'match the number of plotted variables. Default colors will be used.'])
                        fail1 = 1;
                    else
                        fail1 = 0;
                    end

                    if isempty(obj.colorOrderRight)
                        fail2 = 1;
                    elseif size(obj.colorOrderRight,1) ~= size(tempDataRight,2)

                        warning('nb_graph_data:graph:wrongColorOrderRightInput',[mfilename ':: The property ''colorOrderRight'' doesn''t '...
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
                    
                    obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.scatterObs(1:2:end));
                    obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,obj.scatterObsRight(1:2:end));
                    
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
            for ii = 1:size(fields)
                
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
        Set the properties of the axes
        -------------------------------------------------------------------
        %}
        function setAxes(obj)
            
            if strcmpi(obj.plotType,'scatter')
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
                    
                    if ~isempty(obj.mYLim)
                        
                       if isempty(ylim)
                           ylim = [nan,nan];
                       end
                        
                       dat = obj.dataToGraph;
                       if strcmpi(obj.plotType,'area') || strcmpi(obj.plotType,'stacked') || strcmpi(obj.plotType,'dec')
                           dat = sum(dat,2);
                       end
                       
                       bot = min(dat);
                       if bot < obj.mYLim(1)
                           ylim(1) = obj.mYLim(1);
                       end
                       
                       top = max(dat);
                       if top > obj.mYLim(2)
                           ylim(2) = obj.mYLim(2);
                       end 
                       
                    end
                    
                    if isempty(obj.inputs.yLimRight)
                        ylimright = [];
                    else
                        ylimright = obj.inputs.yLimRight;
                    end
                    
                    % If we are plotting many subplots we need to 
                    % increase the default x-axis spacing
                    num = round(size(obj.GraphStruct.(obj.fieldName),1)/obj.subPlotSize(1));
                    if isempty(obj.spacing) && num > 2 && ~isempty(obj.xTick)
                        xT  = obj.xTick(1:2:end);
                        dat = obj.obsOfGraph(1:2:end);
                    else
                        xT  = obj.xTick;
                        dat = obj.obsOfGraph;
                    end
                    
                case 'graphsubplots'
                    
                    ylim          = obj.yLim;
                    ylimright     = obj.yLimRight;
                    yspacing      = obj.ySpacing;
                    yspacingright = obj.ySpacingRight;
                    
                    % If we are plotting many subplots we need to 
                    % increase the default x-axis spacing
                    if isempty(obj.spacing) && obj.subPlotSize(2) > 2 && ~isempty(obj.xTick)
                        xT  = obj.xTick(1:2:end);
                        dat = obj.obsOfGraph(1:2:end);
                    else
                        xT  = obj.xTick;
                        dat = obj.obsOfGraph;
                    end
                    
                otherwise
                    
                    dat           = obj.obsOfGraph;
                    ylim          = obj.yLim;
                    ylimright     = obj.yLimRight;
                    yspacing      = obj.ySpacing;
                    yspacingright = obj.ySpacingRight;
                    xT            = obj.xTick;
                    
            end
            
            % Find the x-axis limits
            %--------------------------------------------------------------
            if isempty(obj.variableToPlotX)
                
                xlim      = [obj.obs(1), obj.obs(end)];
                xtickset  = 1;
                xlabelset = 1;
                
            else
                
                xlim = obj.xLim;
                
                if isempty(xlim)
                    xlim = [nan,nan]; 
                end
                
                if isempty(dat)
                    xtickset  = 0;
                    xlabelset = 0;
                else
                    xtickset  = 0;
                    xlabelset = 0;
                end
                
                % And to makes things work later on (when getData is called)
                obj.startGraph = obj.DB.startObs;
                obj.endGraph   = obj.DB.endObs; 
                
            end
            
            % Evaluate the 'addSpace' property
            %--------------------------------------------------------------
            if ~isempty(obj.variableToPlotX)
            elseif obj.addSpace(1) ~= 0 || obj.addSpace(2) ~= 0
                xlim = [xlim(1) - obj.addSpace(1), xlim(2) + obj.addSpace(2)];
            else
                
                if strcmpi(obj.plotType,'dec') || strcmpi(obj.plotType,'stacked') || strcmpi(obj.plotType,'grouped') || strcmpi(obj.plotType,'candle')  
                    
                    if strcmpi(obj.xTickLabelAlignment,'middle')
                        xlim = [xlim(1), xlim(2) + 0.5];
                    else
                        xlim = [xlim(1) - 0.5, xlim(2) + 0.5];
                    end
                    
                elseif xlim(1) == xlim(2)
                    
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
            
            if isempty(obj.variablesToPlotRight)
                obj.yDirRight   = obj.yDir;
                obj.yScaleRight = obj.yScale;
            end
            
            if isnumeric(dat)
                dat = strtrim(cellstr(num2str(dat')));
            end
            
            % Translate x-tick labels
            if ~isempty(obj.xTickLabels)
                
                try
                    checked = obj.xTickLabels(1:2:end);
                    new     = obj.xTickLabels(2:2:end);
                    datT    = strtrim(dat);
                    for ii = 1:length(checked)
                        ind      = find(strcmpi(checked{ii},datT),1,'last');
                        if ~isempty(ind)
                            dat{ind} = new{ii};
                        end
                    end
                catch Err
                    error([mfilename ':: Wrong input given to the xTickLabels property:: ' Err.message])
                end
                
                if ~isempty(obj.lookUpMatrix)
                    for ii = 1:length(dat)
                        dat{ii} = nb_graph.findVariableName(obj,dat{ii});
                    end
                end
                
                % Interpret the local variables syntax
                if ~isempty(obj.localVariables)
                    for ii = 1:length(dat)
                        dat{ii} = nb_localVariables(obj.localVariables,dat{ii});
                    end
                end
                for ii = 1:length(dat)
                    dat{ii} = nb_localFunction(obj,dat{ii});
                end
                
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
            
            if isempty(obj.lineStop)
                obj.axesHandle.xLim             = xlim;  
                obj.axesHandle.xLimSet          = 1;
                obj.axesHandle.xTick            = xT;
                obj.axesHandle.xTickSet         = xtickset;
                obj.axesHandle.xTickLabel       = dat;
                obj.axesHandle.xTickLabelSet    = xlabelset;
            else
                barDXT  = obj.barPeriods(:)';
                barDXT  = barDXT(xlim(2)>=barDXT);
                barDL   = obj.lineStop + obj.endBarWidth + 1:obj.endBarWidth:obj.lineStop + size(barDXT,2)*obj.endBarWidth + 1;
                ind     = xT > obj.lineStop;
                xT(ind) = [];
                xT      = [xT,barDL];
                xT      = unique(xT);
                dat     = xT;
                for ii = length(barDXT):-1:1
                   ind      = barDL(ii) == dat;
                   dat(ind) = barDXT(ii);
                end
                %xlim(2) = obj.lineStop + size(obj.barPeriods(:),1);
                %obj.axesHandle.xLim          = xlim;  
                %obj.axesHandle.xLimSet       = 1;
                obj.axesHandle.xTick         = xT;
                obj.axesHandle.xTickSet      = 1;
                obj.axesHandle.xTickLabel    = strtrim(cellstr(int2str(dat')));
                obj.axesHandle.xTickLabelSet = 1;
            end
            
            obj.axesHandle.xTickLabelLocation   = obj.xTickLabelLocation;         
            obj.axesHandle.xTickLabelAlignment  = obj.xTickLabelAlignment;
            obj.axesHandle.xTickLocation        = obj.xTickLocation; 
            obj.axesHandle.xTickRotation        = obj.xTickRotation;
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
                        ylimTemp = findYLimitsLeft(obj.axesHandle);
                        ylim     = ylimTemp;
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
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright  = ylimTemp;
                    elseif isnan(ylimright(1))
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright(1)  = ylimTemp(1);
                    elseif isnan(ylimright(2))
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright(2)  = ylimTemp(2);
                    end    
                    
                end
                
                yTickRight = ylimright(1):yspacingright:ylimright(2);
                obj.axesHandle.yTickRight    = yTickRight;
                obj.axesHandle.yTickRightSet = 1;
                
            end 
            
            applyNotTickOptions(obj);
            
            % Then update and plot the axes
            %--------------------------------------------------------------
            obj.axesHandle.updateAxes();

            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch %#ok<CTCH>
                dv = true;
            end
            if dv
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
            xspacing      = obj.spacing;
            
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

                xtick = xlim(1):xspacing:xlim(2);
                obj.axesHandle.xTick    = xtick;
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
            catch %#ok<CTCH>
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
        Evaluate nan and multiplication options + shrink the data to the
        variables wanted
        -------------------------------------------------------------------
        %}
        function evaluateDataTransAndShrinkOptions(obj)
            
            %--------------------------------------------------------------
            % Load the data
            %--------------------------------------------------------------
            evaluatedData = obj.DB.data;
            
            %--------------------------------------------------------------
            % Evaluate the nan options
            %--------------------------------------------------------------
            if ~isempty(obj.nanVariables) && isempty(obj.variablesToPlotX)
                
                for ii=1:2:size(obj.nanVariables,2)
                    
                    nanIndex = strcmp(obj.nanVariables{ii},obj.DB.variables);
                    
                    if sum(nanIndex)==0
                       error([mfilename ':: did not find the variable, ' obj.nanVariables{ii} ', in the dataset']) 
                    end
                    
                    if size(obj.nanVariables{ii+1},2) ~= 2
                        error([mfilename ':: the property ''nanVariables'' must be in the following format: {''var1'',{nanBeforeObs,nanAfterObs},...}'])
                    end
                    
                    if isempty(obj.nanVariables{ii+1}{1})
                        sInd = 1;
                    else
                        obsT = obj.nanVariables{ii+1}{1};
                        sInd = obsT - obj.DB.startObs + 1;
                        if sInd < 0
                            sInd = 1;
                        elseif sInd > obj.DB.numberOfObservations
                            sInd = obj.DB.numberOfObservations;
                        end
                    end
                    
                    if isempty(obj.nanVariables{ii+1}{2})
                        eInd = obj.DB.numberOfObservations;
                    else
                        obsT = obj.nanVariables{ii+1}{2};
                        eInd = obsT - obj.DB.startObs + 1;
                        if eInd < 0
                            eInd = 1;
                        elseif eInd > obj.DB.numberOfObservations
                            eInd = obj.DB.numberOfObservations;
                        end
                    end
                    
                    tempData      = [nan(sInd-1,1,obj.DB.numberOfDatasets); obj.DB.data(sInd:eInd,nanIndex,:); nan(obj.DB.numberOfObservations-eInd,1,obj.DB.numberOfDatasets)];
                    evaluatedData = [evaluatedData(:,1:find(nanIndex)-1,:), tempData, evaluatedData(:,find(nanIndex)+1:end,:)];
                    
                end
                
            end
            
            if ~isempty(obj.nanAfterObs) && isempty(obj.variablesToPlotX)
                
                eInd = obj.nanAfterObs - obj.DB.startObs + 1;
                if not(eInd < 0 || eInd > obj.DB.numberOfObservations)
                    evaluatedData = [evaluatedData(1:eInd,:,:); nan(obj.DB.numberOfObservations-eInd,obj.DB.numberOfVariables,obj.DB.numberOfDatasets)];
                end
                
            end
            
            if ~isempty(obj.nanBeforeObs) && isempty(obj.variablesToPlotX)
                
                sInd = obj.nanBeforeObs - obj.DB.startObs + 1;
                if not(sInd < 0 || sInd > obj.DB.numberOfObservations)
                    evaluatedData = [nan(sInd-1,obj.DB.numberOfVariables,obj.DB.numberOfDatasets); evaluatedData(sInd:end,:,:)];
                end
                
            end
            
            %--------------------------------------------------------------
            % Scale data by the number given by factor, default is 1
            %--------------------------------------------------------------
            evaluatedData = evaluatedData*obj.factor;
            
            %--------------------------------------------------------------
            % Make the data to graph properties; 'dataToGraph' and 
            % 'dataToGraphRight'
            %--------------------------------------------------------------
            
            % Left axes variables
            varIndex = nan(1,length(obj.variablesToPlot));
            for ii = 1:length(obj.variablesToPlot)
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
            
            obj.dataToGraph = evaluatedData(obj.startIndex:obj.endIndex,varIndex,:);
            
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
            
            obj.dataToGraphRight = evaluatedData(obj.startIndex:obj.endIndex,varIndexRight,:);
            
        end
        
        %{
        -------------------------------------------------------------------
        Add vertical line
        -------------------------------------------------------------------
        %}
        function addVerticalLine(obj)
            
            if ~isempty(obj.verticalLine)

                verLine         = obj.interpretVerticalLine();
                numberOfVerLine = length(verLine);
                numbOfColors    = size(obj.verticalLineColor,2);
                numbOfStyles    = size(obj.verticalLineStyle,2);
                
                % Ensure that the 'verticalLineColor' property has the
                % same number of elements as the 'verticalLine' property
                %----------------------------------------------------------
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
                
                % Plot the vertical lines
                %----------------------------------------------------------
                for ii = 1:numberOfVerLine
                    
                    % Find out where to place the vertical
                    % forecast line
                    if isnumeric(verLine{ii})
                        x0 = verLine{ii};
                    elseif ischar(verLine{ii}) 
                        x0 = str2double(verLine{ii});
                    else
                        obs1 = verLine{ii}{1};
                        if ischar(obs1)
                            obs1 = str2double(obs1);
                        end
                        obs2 = verLine{ii}{2};
                        if ischar(obs2)
                            obs2 = str2double(obs2);
                        end
                        x0   = obs1 + (obs2 - obs1)/2; 
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
                    
                    if (min(obj.obs) <= x0) && (max(obj.obs) >= x0)

                        % Plot it
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
                        
                    else

                        % The vertical line date is outside the graphing range,
                        % and we do notting.
                        warning('nb_graph_data:addVerticalLine',['The vertical line obs given by the property ''verticalLine(' int2str(ii) ')'' is outside the graphing range and is not plotted.'])
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
            
            if ~isempty(obj.highlight)
                
                highlightT = interpretHighlight(obj);
                if iscell(highlightT{1})
                    
                    if isempty(obj.highlightColor)
                        
                        numberOfPatches = length(highlightT);
                        obj.highlightColor = cell(1,numberOfPatches);
                        for ii = 1:numberOfPatches
                            obj.highlightColor{ii} = 'light blue';
                        end
                        
                    end
                    
                    if length(obj.highlightColor) ~= length(highlightT)
                    
                        error([mfilename ':: You have provided too few or too many highlight colors with the property ''highlightColor''. '...
                                         'You should have given (' int2str(length(obj.highlight)) ') but have given (' int2str(length(obj.highlightColor)) ')'])
                    end
                    
                    % Plot each patch
                    %------------------------------------------------------
                    for ii = 1:length(highlightT)
                        
                        tempHighlight = highlightT{ii};
                        
                        if isnumeric(tempHighlight{1})
                            startPeriod = tempHighlight{1};
                        elseif ischar(tempHighlight{1})
                            startPeriod = str2double(tempHighlight{1});
                        else
                            error([mfilename ':: highlight is wrongly set. Be aware that only numerical values can be given as the limits!'])
                        end
                        
                        if isnumeric(tempHighlight{2})
                            endPeriod = tempHighlight{2};
                        elseif ischar(tempHighlight{2})
                            endPeriod = str2double(tempHighlight{2});
                        else
                            error([mfilename ':: highlight is wrongly set. Be aware that only numerical values can be given as the limits!'])
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
                    
                    if isnumeric(highlightT{1})
                        startPeriod = highlightT{1};
                    elseif ischar(highlightT{1})
                        startPeriod = str2double(highlightT{1});
                    else
                        error([mfilename ':: highlight is wrongly set. Be aware that only numerical values can be given as the limits!'])
                    end

                    if isnumeric(highlightT{2})
                        endPeriod = highlightT{2};
                    elseif ischar(highlightT{2})
                        endPeriod = str2double(highlightT{2});
                    else
                        error([mfilename ':: highlight is wrongly set. Be aware that only numerical values can be given as the limits!'])
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

                if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphsubplots')
                    
                    variables = obj.DB.dataNames;
                    if length(variables)== 1
                        variables = obj.DB.variables;
                    end
                    
                    for ii = 1:size(variables,2)
                        ind = strfind(variables{ii},'\');
                        if ~isempty(ind)
                            variables{ii} = variables{ii}(ind(end)+1:end);
                        end
                    end
                    
                else                    
                    variables = obj.variablesToPlot;                 
                end
 
                data = obj.dataToGraph;
                col  = obj.colorOrder;
                
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
            if isempty(obj.dashedLine)
                defaultLineStyle = {'-'};
            else
                defaultLineStyle = {{'-',obj.dashedLine,'--'}};
            end
            
            lineColor = nan(sData,3);
            lineStyle = repmat(defaultLineStyle,[1,sData]);
            lineW     = ones(1,sData)*obj.lineWidth;
            marker    = repmat({'none'},[1,sData]);
            for ii = 1:sData
                lineColor(ii,:) = col(ii,:);
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = interpretLineStyles(obj);
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
                        warning('nb_graph_data:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
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
                        warning('nb_graph_ts:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
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
                        warning('nb_graph_data:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                    end
                    
                end

            end
            
            if strcmpi(obj.graphMethod,'graphInfoStruct')
                
                if ~isempty(obj.inputs.lineStyle)
                    lineStyle = obj.inputs.lineStyle;
                end
                
            end
                
            % Decide if we have some splitted line styles
            %--------------------------------------------------------------
            for ii = 1:size(lineStyle,2)
               
                if iscell(lineStyle{ii})
                    
                    if size(lineStyle{ii},2) == 3
                    
                        % Find the split date and it index value
                        obsT = lineStyle{ii}{2};
                        if ischar(obsT)
                            obsT = str2double(obsT);
                        end
                        
                        if obsT >= obj.obs(1) && obsT <= obj.obs(end)
                        
                            splitInd = find(obsT <= obj.obs,1);
                            
                            if strcmpi(lineStyle{ii}{3},'none')
                                corr = 1;
                            else
                                corr = 0;
                            end
                            
                            % Split the data
                            [beforeSplit,afterSplit] = nb_graph.splitData(data(:,ii),splitInd,corr);
                            data(:,ii)               = beforeSplit; 
                            data                     = [data, afterSplit]; %#ok

                            % Assign the line properties for the line with 
                            % the second line style
                            lineColor = [lineColor; lineColor(ii,:)];    %#ok
                            lineStyle = [lineStyle lineStyle{ii}{3}];    %#ok
                            lineW     = [lineW     lineW(ii)];           %#ok
                            
                            % Check if a specific marker has been 
                            % given to the second line style of the
                            % splitted line
                            varLine = variables{ii};
                            indM2   = find(strcmp([varLine,'(2)'],obj.markers));
                            if isempty(indM2)
                                marker = [marker, marker{ii}];          %#ok
                            else
                                marker = [marker, obj.markers{indM2 + 1}];          %#ok
                            end

                            % Assign the properties for the line with the 
                            % first line style
                            lineStyle{ii} = lineStyle{ii}{1};
                            
                        else
                            
                            per = obsT - obj.obs(1);
                            if per > 0
                                % Only the first line style is plotted
                                lineStyle{ii} = lineStyle{ii}{1};
                            else
                                % Only the second line style is plotted
                                lineStyle{ii} = lineStyle{ii}{3};
                            end
                               
                        end
                        
                    else
                        error([mfilename ':: If the line style for one line is a cell it must be of size 3. E.g. {''-'',2,''--''}.'])
                    end
                end
                
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            if isempty(obj.lineStop)
                nb_plot(obj.obs,data,...
                        'cData',              lineColor,...
                        'lineStyle',          lineStyle,...
                        'lineWidth',          lineW,...
                        'marker',             marker,...
                        'markerFaceColor',    'auto',...
                        'markerSize',         obj.markerSize,...
                        'parent',             obj.axesHandle,...
                        'side',               side);
            else
                
                move = -(obj.DB.startObs - 1);
                nb_plotBarAtEnd(obj.obs + move,data,...
                        'barPeriods',         obj.barPeriods + move,...
                        'cData',              lineColor,...
                        'cDataBar',           obj.colorBarAtEnd,...
                        'endBarWidth',        obj.endBarWidth,...
                        'lineStop',           obj.lineStop + move,...
                        'lineStyle',          lineStyle,...
                        'lineWidth',          lineW,...
                        'marker',             marker,...
                        'markerFaceColor',    'auto',...
                        'markerSize',         obj.markerSize,...
                        'parent',             obj.axesHandle,...
                        'side',               side);
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
                data   = obj.dataToGraph;
                col    = obj.colorOrder;
            else
                data   = obj.dataToGraphRight;
                col    = obj.colorOrderRight;
            end
            
            if isempty(data)
                return
            end
            if obj.areaAlpha < 1
                lineW = obj.lineWidth;
            else
                lineW = 1;
            end 
            
            % Do the plotting
            %--------------------------------------------------------------
            a = nb_area(obj.obs,data,...
                        'abrupt',           obj.areaAbrupt,... 
                        'accumulate',       obj.areaAccumulate,...
                        'baseValue',        obj.baseValue,...
                        'cData',            col,...
                        'faceAlpha',        obj.areaAlpha,...
                        'lineStyle',        '-',...
                        'lineWidth',        lineW,...
                        'parent',           obj.axesHandle,...
                        'side',             side,...
                        'sumTo',            obj.sumTo);

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
                data  = obj.dataToGraph;
                col   = obj.colorOrder;
                ylim  = obj.yLim;
            else
                data   = obj.dataToGraphRight;
                col    = obj.colorOrderRight;
                ylim  = obj.yLimRight;
            end
            
            if isempty(data)
                return
            end
            
            % Decide the shading
            %--------------------------------------------------------------
            if isempty(obj.barShadingObs)
                shadedBars = zeros(size(data,1),1);
            else
                
                if isnumeric(obj.barShadingObs)
                    shadedBars = obj.barShadingObs <= obj.obs;
                else
                    
                    if strcmpi(side,'left')
                        vars = obj.variablesToPlot;
                    else
                        vars = obj.variablesToPlotRight;
                    end
                    
                    shadedBars = zeros(size(data));
                    for ii = 1:2:length(obj.barShadingObs)
                        
                        var = obj.barShadingObs{ii};
                        ind = find(strcmpi(var,vars));
                        if ~isempty(ind)
                            bObs    = obj.barShadingObs{ii+1};
                            periods = bObs - obj.startGraph;
                            left    = obj.endGraph - bObs + 1;
                            
                            if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                                shadedBars(:,ind) = [zeros(periods,1); ones(left,1)];
                            elseif periods <= 0
                                shadedBars(:,ind) = ones(size(data,1),1);
                            else
                                shadedBars(:,ind) = zeros(size(data,1),1);
                            end
                        end
                        
                    end
                    
                end
            end
                
            if any(any(shadedBars))
                lineS = '-';
            else
                lineS = 'none';
            end
            
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
            b = nb_bar(obj.obs,data,...
                       'alpha1',        obj.barAlpha1,...
                       'alpha2',        obj.barAlpha2,...
                       'barWidth',      obj.barWidth,...
                       'baseValue',     obj.baseValue,...
                       'blend',         obj.barBlend,...
                       'cData',         col,...
                       'direction',     obj.barShadingDirection,...
                       'edgeColor',     'same',...
                       'lineStyle',     lineS,...
                       'lineWidth',     lineW,...
                       'parent',        obj.axesHandle,...
                       'side',          side,...
                       'shadeColor',    obj.barShadingColor,...
                       'shaded',        shadedBars,...
                       'style',         obj.plotType,...
                       'sumTo',         obj.sumTo);
             
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
                            kk         = kk + 1;
                            
                        case 'close'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''close'' option of the candleVariables property.'])
                            end
                            close      = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'high'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''high'' option of the candleVariables property.'])
                            end
                            high       = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'low'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''low'' option of the candleVariables property.'])
                            end
                            low        = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'indicator'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''indicator'' option of the candleVariables property.'])
                            end
                            indicator  = data(:,ind,:);
                            kk         = kk + 1;
                            
                        otherwise
                            
                            error([mfilename ':: The input ''' type ''' is not supported by the candle plot. Must be ''open'',''close'',''high'',''low'' or ''indicator''.'])
                            
                    end
                    
                end
                        
            end
            
            indicatorWidth = obj.candleWidth + obj.candleWidth/10; 
            
            % Do the plotting
            %------------------------------------------------------
            nb_candle(obj.obs,high,low,open,close,...
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
                
                if isempty(obj.scatterObs)
                    return
                end
                
                scObs  = obj.interpretScatterObs;
                
                if isempty(obj.scatterVariables)
                    try
                        obj.scatterVariables = obj.DB.variables(1:2);
                    catch  %#ok<CTCH>
                        error([mfilename ':: The given data must have at least two variables when doing scatter plots.'])
                    end
                end
                
                scVars = obj.scatterVariables;
                col    = obj.colorOrder;
                
            else
                
                if isempty(obj.scatterObsRight)
                    return
                end
                
                scObs = obj.interpretScatterObsRight;
                
                if isempty(obj.scatterVariablesRight)
                    try
                        obj.scatterVariablesRight = obj.DB.variables(1:2);
                    catch %#ok<CTCH>
                        error([mfilename ':: The given data must have at least two variables when doing scatter plots.'])
                    end
                end
                
                scVars  = obj.scatterVariablesRight;
                col     = obj.colorOrderRight;
                
            end
            
            % Load the data to plot
            %------------------------------------------------------
            data      = obj.DB.double;
            vars      = obj.DB.variables;
            start     = obj.DB.startObs;
            finish    = obj.DB.endObs;
            
            % Find the dates to be plotted for each scatter group
            %------------------------------------------------------
            indObs = cell(1,size(scObs,2)/2);
            
            if size(scObs,2) < 2
                error([mfilename ':: The property scatterObs(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{1,2},...}'])
            end
            
            kk = 1;
            for ii = 2:2:size(scObs,2)
                
                if iscell(scObs{ii})
                    
                    if size(scObs{ii},2) ~= 2
                        error([mfilename ':: The property scatterObs(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{1,2},...}'])
                    end
                    
                    startTemp = scObs{ii}{1};
                    endTemp   = scObs{ii}{2};
                    
                    indStart  = startTemp - start + 1;
                    indEnd    = endTemp - start + 1;
                    
                    if indStart < 1
                        error([mfilename ':: The start obs (' int2str(startTemp) ') of the scatter group nr. ' int2str(ii) ' must be greater then or '...
                                         'equal to the start obs of the data (' int2str(start) ').'])
                    end
                    
                    if indEnd > obj.DB.numberOfObservations
                        error([mfilename ':: The end obs (' int2str(endTemp) ') of the scatter group nr. ' int2str(ii) ' must be less then or '...
                                         'equal to the end obs of the data (' int2str(finish) ').'])
                    end
                    
                    if indStart > indEnd
                        error([mfilename ':: The start obs (' int2str(startTemp) ') of the scatter group nr. ' int2str(ii) ' must be less then or '...
                                         'equal to the end obs of of the scatter group (' int2str(endTemp) ').'])
                    end
                    
                    indObs{kk} = indStart:indEnd;
                    kk = kk + 1;
                    
                else
                    error([mfilename ':: The property scatterObs(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{1,2},...}'])
                end
                
            end
            
            % Find the variables to be plotted for each scatter
            % group
            %------------------------------------------------------
            if size(scVars,2) ~= 2
                error([mfilename ':: The property scatterVariables(Right) must have size 1x2 (with the variables to plot).'])
            end
            indVars = nb_cs.locateStrings(scVars,vars);
            
            numberOfGroups = size(indObs,2);
            
            % Get the data to plot
            %------------------------------------------------------
            startTot     = finish;
            endTot       = start;
            for ii = 1:numberOfGroups
                
                % Get marker
                scTemp = scObs{ii*2 - 1};
                ind    = find(strcmpi(scTemp,obj.markers),1);
                if isempty(ind)
                   marker = 'o';  
                else
                   marker = obj.markers{ind + 1}; 
                end
                
                indObsTemp = indObs{ii};
                xData      = data(indObsTemp,indVars(1));
                yData      = data(indObsTemp,indVars(2));
               
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
                       
                % Add variables to the allVariables variable
                %--------------------------------------------------
                startTemp = start + indObsTemp(1) - 1;
                if startTemp < startTot
                    startTot = startTemp;
                end
                
                endTemp = start + indObsTemp(end) - 1;
                if endTemp > endTot
                    endTot = endTemp;
                end
                
            end
            
            % Set the some properties which is important when 
            % saving the data of the object.
            %------------------------------------------------------
            obj.startGraph = startTot;
            obj.endGraph   = endTot;
            
        end
        
        %{
        -----------------------------------------------------------
        Get the scatter plot sizes (represented as double vectors).
        
        Used to get the color order properties correct
        -----------------------------------------------------------
        %}
        function [tempData,tempDataRight] = getScatterSizes(obj)
            
            if isempty(obj.scatterObs)
                tempData = nan(1,1);
            else
                s        = size(obj.scatterObs,2)/2;
                tempData = nan(1,s);
            end
            
            if ~isempty(obj.scatterObsRight)
                s             = size(obj.scatterObsRight,2)/2;
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
                data   = obj.dataToGraph;
                col    = obj.colorOrder;
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
                catch  %#ok<CTCH>
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''ploTypes'' property.'])
                        
                    else
                    
                        if strcmpi(side,'left')
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlotRight),1);
                            type            = 'variablesToPlot';
                        else
                            locVarOtherSide = find(strcmp(var,obj.variablesToPlot),1);
                            type            = 'variablesToPlotRight';
                        end
                        if isempty(locVarOtherSide)
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''ploTypes'' property.'])
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
                
                warning('nb_graph_data:addPlotTypes:lineWidthsNotAnOption',[mfilename ':: The property ''lineWidths'' will not be setting '...
                        'the width of the lines when lines are combined with other plotting types. Sorry that is not possible!'])
                    
            end
            
            lineStyle = cell(1,sLData);
            marker    = cell(1,sLData);
            
            if isempty(obj.dashedLine)
                defaultLineStyle = '-';
            else
                defaultLineStyle = {'-',obj.dashedLine,'--'};
            end
            
            for ii = 1:sLData
                lineStyle{ii}   = defaultLineStyle;
                marker{ii}      = 'none';
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = interpretLineStyles(obj);
            for kk = 1:2:size(lineS,2)
                var    = lineS{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    lineStyle{locVar} = lineS{kk + 1};
                catch %#ok<CTCH>
                    
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
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
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
                catch  %#ok<CTCH>
                    
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
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                        end
                        
                    end
                    
                end

            end
            
            % Decide if we have some splitted line styles
            %--------------------------------------------------------------
            for ii = 1:size(lineStyle,2)
               
                if iscell(lineStyle{ii})
                    
                    if size(lineStyle{ii},2) == 3
                    
                        locVar = find(strcmp(lineVars{ii},variables),1);
                        obsT   = lineStyle{ii}{2};
                        dat    = data(:,locVar); 
                        
                        if obj.obs(1) <= obsT &&  obsT <= obj.obs(end)
                        
                            splitInd = find(obsT <= obj.obs,1);
                            
                            if strcmpi(lineStyle{ii}{3},'none')
                                corr = 1;
                            else
                                corr = 0;
                            end
                            
                            % Split the data
                            [beforeSplit,afterSplit] = nb_graph.splitData(dat,splitInd,corr);
                            data(:,locVar)           = beforeSplit; 
                            data                     = [data, afterSplit];  %#ok
                            plotT                    = [plotT {'line'}];    %#ok
                            
                            % Assign the line properties for the line with 
                            % the second line style
                            lineStyle = [lineStyle lineStyle{ii}{3}];    %#ok
                            col       = [col;      col(locVar,:)];    %#ok
                            lineW     = [lineW, lineW(ii)]; %#ok<AGROW>
                            
                            % Check if a specific marker has been 
                            % given to the second line style of the
                            % splitted line
                            indM2   = find(strcmp([lineVars{ii},'(2)'],obj.markers));
                            if isempty(indM2)
                                marker = [marker, marker{ii}];          %#ok
                            else
                                marker = [marker, obj.markers{indM2 + 1}];          %#ok
                            end
                            
                            % Assign the properties for the line with the 
                            % first line style
                            lineStyle{ii} = lineStyle{ii}{1};
                            
                        elseif obsT > obj.obs(end)
                            
                            % Only the first line style is plotted
                            lineStyle{ii} = lineStyle{ii}{1};
                            
                        else%if obj.obs(1) > obsT
                            
                            % Only the second line style is plotted
                            lineStyle{ii} = lineStyle{ii}{3};
                            
                        end
                        
                    else
                        error([mfilename ':: If the line style for one line is a cell it must be of size 3. E.g. {''-'',4,''--''}.'])
                    end
                end
                
            end
            
            % Decide the shading
            %--------------------------------------------------------------
            bInd = strcmpi(plotT,'grouped') | strcmpi(plotT,'stacked');
            nBar = sum(bInd);
            if isempty(obj.barShadingObs)
                shadedBars = zeros(size(data,1),1);
            else
                
                if isnumeric(obj.barShadingObs)
                
                    shadedBars = obj.barShadingObs <= obj.obs;
                    
                else % A cell {'Var1',dat1,...}
                    
                    if strcmpi(side,'left')
                        vars = obj.variablesToPlot(bInd);
                    else
                        vars = obj.variablesToPlotRight(bInd);
                    end
                    
                    shadedBars = zeros(size(data,1),nBar);
                    for ii = 1:2:length(obj.barShadingObs)
                        
                        var = obj.barShadingObs{ii};
                        ind = find(strcmpi(var,vars));
                        if ~isempty(ind)
                            bObs    = obj.barShadingObs{ii+1};
                            periods = bObs - obj.startGraph;
                            left    = obj.endGraph - bObs + 1;
                            
                            if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                                shadedBars(:,ind) = [zeros(periods,1); ones(left,1)];
                            elseif periods <= 0
                                shadedBars(:,ind) = ones(size(data,1),1);
                            else
                                shadedBars(:,ind) = zeros(size(data,1),1);
                            end
                        end
                        
                    end
                
                end
  
            end
            
            % Test some given properties
            %--------------------------------------------------------------
            if ~isempty(obj.sumTo)
                warning('nb_graph_data:addPlotTypes:sumToNotAnOption',[mfilename 'The ''sumTo'' option is not supported for combination plots.'])
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
            nb_plotComb(obj.obs,data,...
                        'abrupt',        obj.areaAbrupt,...
                        'alpha1',        obj.barAlpha1,...
                        'alpha2',        obj.barAlpha2,...
                        'barWidth',      obj.barWidth,...
                        'baseValue',     obj.baseValue,...
                        'blend',         obj.barBlend,...
                        'cData',         col,...
                        'direction',     obj.barShadingDirection,...
                        'edgeColor',     'same',...
                        'edgeLineStyle', edgeLineS,...
                        'edgeLineWidth', edgeLineWidth,...
                        'lineStyle',     lineStyle,...
                        'lineWidth',     lineW,...
                        'marker',        marker,...
                        'markerSize',    obj.markerSize,...
                        'parent',        obj.axesHandle,...
                        'shadeColor',    obj.barShadingColor,...
                        'shaded',        shadedBars,...
                        'side',          side,...
                        'types',         plotT);
            
        end

        %{
        -------------------------------------------------------------------
        Create x-ticks of the graphs
        -------------------------------------------------------------------
        %}
        function createxTickOfGraph(obj)

            if isempty(obj.variableToPlotX)
                
                % Find the start and end obs
                start  = obj.startGraph;
                finish = obj.endGraph;

                % Find the spacing between ticks if not given
                if isempty(obj.spacing)
                    space = nb_graph_ts.findXSpacing(start,finish); 
                else
                    space = obj.spacing;
                end

                % Find the x-tick marks
                xTickObs  = obj.startGraph:obj.endGraph;
                if ~isempty(obj.xTickStart)

                    startX = obj.xTickStart;
                    if startX < start
                        startX = start;
                    end

                else
                    startX = start;
                end
                
                % Find the final x-ticks marks given the spacing and assign 
                % the properties of the object
                obj.xTick      = startX:space:xTickObs(end);
                obj.obsOfGraph = obj.xTick;
                obj.obs        = xTickObs;
                
            else
                
                % Find the X-axis variable
                ind = find(strcmp(obj.variableToPlotX,obj.DB.variables));
                if isempty(ind)
                    error([mfilename ':: The variableToPlotX property assign a non-existing variable ' obj.variableToPlotX])
                else
                    if strcmpi(obj.graphMethod,'graphSubPlots')
                        xTickObs = obj.DB.data(:,ind,1); % Only using the x-values from the first page
                    else
                        xTickObs = obj.DB.data(:,ind,:); 
                    end
                end
                
                % Find the start and end obs
                start  = min(xTickObs);
                finish = max(xTickObs);

                % Find the spacing between ticks if not given
                if isempty(obj.spacing)
                    
                    % Here I make MATLAB choose the spacing and limits
                    % on the fly when the plotting is done
                    obj.xTick      = [];
                    obj.obsOfGraph = {};
                    obj.obs        = xTickObs;
                    
                    if ~isempty(obj.xTickStart)
                        warning([mfilename ':: The use of xTickStart when the variablesToPlotX property is used is not supported.'])
                    end
                    
                    return
                    
                end
                
                % Find the x-tick marks
                if ~isempty(obj.xTickStart)
                    startX = obj.xTickStart;
                    if startX < start
                        startX = start;
                    end
                else
                    startX = start;
                end
                
                % Find the final x-ticks marks given the spacing and assign 
                % the properties of the object
                space          = obj.spacing;
                obj.obsOfGraph = startX:space:finish;
                obj.xTick      = startX:space:finish;
                obj.obs        = xTickObs;
                                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Function which interpret the missing observations
        
        Either strip or interpolate the missing observations.
        -------------------------------------------------------------------
        %}
        function [obj,data] = interpretMissingData(obj,data)
            
            if nargin < 3
                updateObs = 1; %#ok<NASGU>
            end
              
            if strcmpi(obj.missingValues,'interpolate')

                % Interpolate the data
                data = nb_interpolate(data,'linear');

            elseif strcmpi(obj.missingValues,'strip') || strcmpi(obj.missingValues,'both')
                error([mfilename ':: ''strip'' and ''both'' is not an option for the missingValues property for the class nb_graph_data.'])
            end
              
        end
        
        function out = interpretScatterObs(obj)
            
            out = obj.scatterObs;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    try
                        
                        temp = out{ii*2};
                        
                        obsT = temp{1};
                        if ischar(obsT)
                            
                            inp = obsT;
                            if nb_contains(obsT,'%#')                                    
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property scatterObs with local variable notation (%' inp ').'])
                                end
                            end
                            temp{1} = obsT;
                            
                        end
                        
                        obsT = temp{2};
                        if ischar(obsT)
                            
                            inp = obsT;
                            if nb_contains(obsT,'%#')  
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property scatterObs with local variable notation (%' inp ').'])
                                end
                            end
                            temp{2} = obsT;
                            
                        end
                        
                        out{ii*2} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME)
                        else
                            error([mfilename ':: Wrong input given to the scatterObs property. Must be a cell array on the format '...
                                             '{''scatterGroup1'',{startObs1,endObs1},''scatterGroup2'',{startObs2,endObs2},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretScatterObsRight(obj)
            
            out = obj.scatterObsRight;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    try
                        
                        temp = out{ii*2};
                        
                        obsT = temp{1};
                        if ischar(obsT)
                            
                            inp = obsT;
                            if nb_contains(obsT,'%#')
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property scatterObsRight with local variable notation (%' inp ').'])
                                end
                            end
                            temp{1} = obsT;
                            
                        end
                        
                        obsT = temp{2};
                        if ischar(obsT)
                            
                            inp = obsT;
                            if nb_contains(obsT,'%#')  
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property scatterObsRight with local variable notation (%' inp ').'])
                                end
                            end
                            temp{2} = obsT;
                            
                        end
                        
                        out{ii*2} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME)
                        else
                            error([mfilename ':: Wrong input given to the scatterObsRight property. Must be a cell array on the format '...
                                             '{''scatterGroup1'',{startObs1,endObs1},''scatterGroup2'',{startObs2,endObs2},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretVerticalLine(obj)
            
            out = obj.verticalLine;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)

                    try
                        
                        temp = out{ii};
                        if iscell(temp)
                        
                            obsT = temp{1};
                            if ischar(obsT)
                                inp = obsT;
                                if nb_contains(obsT,'%#') 
                                    obsT = nb_localVariables(obj.localVariables,obsT);
                                    if ~isnumeric(obsT)
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property verticalLine with local variable notation (%' inp ').'])
                                    end
                                end
                                temp{1} = obsT;
                            end
                            
                            obsT = temp{2};
                            if ischar(obsT)
                                inp = obsT;
                                if nb_contains(obsT,'%#')     
                                    obsT = nb_localVariables(obj.localVariables,obsT);
                                    if ~isnumeric(obsT)
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property verticalLine with local variable notation (%' inp ').'])
                                    end
                                end
                                temp{2} = obsT;
                            end
                            
                        else
                            
                            obsT = temp;
                            if ischar(obsT)
                                inp = obsT;
                                if nb_contains(obsT,'%#') 
                                    obsT = nb_localVariables(obj.localVariables,obsT);
                                    if ~isnumeric(obsT)
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property scatterObsRight with local variable notation (%' inp ').'])
                                    end
                                end
                                temp = obsT;
                            end
                            
                        end
                        out{ii} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME);
                        else
                            error([mfilename ':: Wrong input given to the verticalLine property. Must be a cell array on the format '...
                                             '{obs1,obs2,{obs1,obs2},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretHighlight(obj)
            
            out = obj.highlight;
            
            if isstruct(obj.localVariables)
                
                if ~iscell(out{1})
                    out = {out};
                end
                
                try
                
                    for ii = 1:size(out,2)

                        temp = out{ii};
                        obsT = temp{1};
                        if ischar(obsT)
                            inp = obsT;
                            if nb_contains(obsT,'%#')   
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property highlight with local variable notation (%' inp ').'])
                                end
                            end
                            temp{1} = obsT;
                        end

                        obsT = temp{2};
                        if ischar(obsT)
                            inp = obsT;
                            if nb_contains(obsT,'%#') 
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property highlight with local variable notation (%' inp ').'])
                                end
                            end
                            temp{2} = obsT;
                        end
                        out{ii} = temp;

                    end
                        
                catch ME

                    if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                        rethrow(ME);
                    else
                        error([mfilename ':: Wrong input given to the highlight property. Must be a cell array on the format '...
                                         '{{obs1,obs2},{obs1,obs2},...}']);
                    end

                end
                
            end
            
        end
       
        function out = interpretLineStyles(obj)
        % Interpret the lineStyles property. I.e. check for use
        % of local variables
            
            out = obj.lineStyles;
            
            if isa(obj,'nb_graph_cs')
                return
            end
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    if iscell(out{ii*2})

                        temp = out{ii*2};
                        obsT = temp{2};
                        
                        if ischar(obsT)
                            inp = obsT;
                            if nb_contains(obsT,'%#')
                                obsT = nb_localVariables(obj.localVariables,obsT);
                                if ~isnumeric(obsT)
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported input of type ' class(obsT) ' given to the property lineStyles with local variable notation (%' inp ').'])
                                end
                            end
                            temp{2}   = obsT;
                        end
                        out{ii*2} = temp;

                    end

                end
                
            end
            
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
                        data = fData.window(obj.startGraph,obj.endGraph,obj.fanVariable);
                        data = reshape(data.data,data.numberOfObservations,data.numberOfDatasets,1);
                    else
                        try
                            data = createVariable(fData,obj.fanVariable,obj.fanVariable);
                            data = data.window(obj.startGraph,obj.endGraph,obj.fanVariable);
                            data = reshape(data.data,data.numberOfObservations,data.numberOfDatasets,1);
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
                        f = nb_gradedFanChart(obj.startGraph:obj.endGraph,data,...
                            'alpha',        obj.fanAlpha,...
                            'parent',       obj.axesHandle,...
                            'side',         side);
                    else
                        f = nb_fanChart(obj.startGraph:obj.endGraph,data,...
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
                    obj.fanData = nb_data(obj.fanDatasets);
                elseif isa(obj.fanDatasets,'nb_data') || isstruct(obj.fanDatasets)
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
                        obj.fanData.(fields{ii}) = expand(obj.fanData.(fields{ii}),obj.startGraph,obj.endGraph,'nan','off');
                    end
                else
                    obj.fanData = expand(obj.fanData,obj.startGraph,obj.endGraph,'nan','off');
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
                    copyObj.annotation{ii} = copy(copied);
                end
                
            elseif isa(copyObj.annotation,'nb_annotation')
                copyObj.annotation = copy(copyObj.annotation);
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
    % Subfunctions
    %----------------------------------------------------------------------
    methods (Static=true,Hidden=true)
        
        function [cellInput,message] = checkObs(cellInput,message,start,incr,dataSource,propertyName)
            
            if ~isempty(cellInput)

                transBack = 0;
                if ~iscell(cellInput)
                    cellInput = {cellInput};
                    transBack = 1;
                end
                
                cInput = cellInput;
                for ii = start:incr:length(cInput)

                    trans  = 0;
                    obsT   = cInput{ii};
                    if ~iscell(obsT)
                        obsT   = {obsT};
                        trans = 1;
                    end
                      
                    for jj = 1:length(obsT)
                        
                        tested  = obsT{jj};
                        if tested < dataSource.startObs 
                      
                            obsT{jj}    = dataSource.startObs;                            
                            newMessage = ['The ' propertyName ' (or one of them) starts/ends before the start obs of the new data. Reset to ' int2str(dataSource.startObs) '.'];
                            message    = nb_addMessage(message,newMessage);  
                            
                        elseif tested > dataSource.endObs
                            
                            obsT{jj}    = dataSource.endObs;
                            newMessage = ['The ' propertyName ' (or one of them) starts/ends after the end obs of the new data. Reset to ' int2str(dataSource.endObs) '.'];
                            message    = nb_addMessage(message,newMessage);

                        end
                        
                    end

                    if trans 
                        obsT = obsT{1};
                    end
                    
                    cInput{ii} = obsT;

                end
                cellInput = cInput;

                if transBack
                    cellInput = cellInput{1};
                end
                
            end
            
        end

        function obj = unstruct(s)
            
            obj    = nb_graph_data();
            obj.DB = nb_data.unstruct(s.DB);
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
                        
                    case 'barShadingObs'
                        
                        if  ischar(s.barShadingObs)
                            ind = strfind(s.barShadingObs,'%#');
                            if isempty(ind)
                                obj.barShadingObs = str2double(s.barShadingObs);
                            else
                                obj.barShadingObs = s.barShadingObs;
                            end
                        elseif isnumeric(s.barShadingObs)
                             obj.barShadingObs = s.barShadingObs;
                        else
                            bObs = s.barShadingObs;
                            for jj = 2:2:length(bObs)
                                if ischar(bObs{jj})
                                    ind = strfind(bObs{jj},'%#');
                                    if isempty(ind)
                                        bObs{jj} = str2double(bObs{jj},frequency);
                                    end
                                end
                            end
                            obj.barShadingObs = bObs;
                        end
                        
                    case 'DB'
                        % Already done
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
                    case {'manuallySetColorOrder','manuallySetColorOrderRight','manuallySetLegend','manuallySetEndGraph','manuallySetStartGraph'}
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
        
            obj = nb_graph_data.unstruct(s);
            
        end
        
    end
    
    methods (Access=protected,Hidden=true)
       
        varargout = setPropEndGraph(varargin)
        varargout = setPropStartGraph(varargin)
        
    end
    
end

