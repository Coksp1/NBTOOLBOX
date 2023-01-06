classdef (Abstract) nb_graph < nb_graph_obj
% Description:
%
% A abstract class.
%
% The class has some methods utilized by some of its subclasses.
%
% Superclasses:
%
% handle
% 
% Subclasses:
%
% nb_graph_ts, nb_graph_cs, nb_graph_data
%
% See also:
% nb_graph_ts, nb_graph_cs, nb_graph_data
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Save PDF to A4 portrait format. 0 or 1
        a4Portrait              = 0;
        
        % Set to false to prevent adding advanced components.
        addAdvanced             = true;
        
        % Align axes at a given base value. Must be set to a scalar double.
        % E.g. 0.
        alignAxes               = [];
        
        % Sets the plotted annotations of the graph.
        % 
        % Must be one or more nb_annotation objects. See the 
        % documentation of the nb_annotation class for more. If you give  
        % more objects they must be collected in a cell array. 
        %
        % Examples can be found here:
        %
        % \\NBTOOLBOX\Examples\Graphics\nb_annotationExamples.m
        annotation              = [];  
        
        % Sets the space before and/or after in the x direction of the  
        % graph [addedSpaceBefore addedSpaceAfter]. E.g. add one period  
        % before and after [1,1]. 
        addSpace                = [0 0];      
        
        % Set this property to true to make the areas abruptly 
        % finish when given as nan. Default is false.
        areaAbrupt              = false;
        
        % Set if the areas should be accumulated or not. Default is true.
        areaAccumulate          = true;
        
        % Sets the transparency of the area chart. A number between 
        % 0 and 1. 1 is opaque, while 0 is fully transparent.
        areaAlpha               = 1;
        
        % Set the if you want graphs to be produced fast with a loss of
        % functionality and look or not. When empty default for the graph
        % method is false, while for the graphSubPlots and graphInfoStruct
        % methods are true.
        axesFast                = [];
        
        % Sets the font size of the axes tick mark labels, default is 
        % 12. Must be a scalar.
        axesFontSize            = 12;               
        
        % Sets the font size of the x-axis tick mark labels, default is 
        % []. I.e. use the axesFontSize property instead. Must be a scalar.
        %
        % This property will not be sacaled when fontUnits are changed, as
        % is the case for axesFontSize.
        %
        % Caution: Will not set the x-axis font size when plotType is set
        %          to scatter.
        axesFontSizeX           = [];    
        
        % Sets the font weight of the axes tick mark labels. Must be a 
        % string. Default is 'normal'. Either 'normal', 'bold', 'light' 
        % or 'demi'        
        axesFontWeight          = 'normal';   
        
        % Sets the the line width of the axes, default is 0.5. Must be a 
        % set to a scalar double greater than 0.
        axesLineWidth            = 0.5; 
        
        % Sets the precision/format of the rounding of number on the axes.
        %
        % See the precision input to the nb_num2str function. Default is
        % [], i.e. to call num2str without additional inputs.
        axesPrecision           = [];
        
        % Scale line width to axes height. true or false (default). If
        % axesScaleFactor is set to a scalar number this will be the
        % scaling factor used instead of the automatic scaling factor.
        axesScaleLineWidth      = false;
        
        % Set the scaling factor used when axesScaleLineWidth is set 
        % to true.
        axesScaleFactor         = [];
        
        % Set the alpha blending parameter 1, when barBlend is set to
        % true. See nb_alpha. Default is 0.5
        barAlpha1               = 0.5;
        
        % Set the alpha blending parameter 2, when barBlend is set to
        % true. See nb_alpha. Default is 0.5
        barAlpha2               = 0.5;
        
        % Set to true to do alpha blending instead of shading if shading
        % options is used. Default is false.
        barBlend                = false;
        
        % Set the bar line width without affecting any other line widths.
        % Default is empty, i.e. use the lineWidth property.
        barLineWidth            = [];
        
        % The color shaded bars are interpolated with. Default is 
        % 'white'. Must either be a 1 x 3 double with the RGB colors or 
        % a string with the color name.  
        barShadingColor         = [1 1 1]; 
        
        % Sets the angle the shading should be vertical of. Either  
        % {'north'} | 'south' | 'west' | 'east'. As a string. Default is
        % 'north'.
        barShadingDirection     = 'north';          
        
        % Sets the width of the bar plot. As a scalar. Default is 0.45.
        barWidth                = 0.45;     
        
        % If 0 is given the base line will not be plotted, otherwise it 
        % will be plotted.
        baseLine                = 1;                
        
        % Sets the color of the base line. Must either be a 1 x 3 double  
        % with the RGB colors or a string with the color name. 
        baseLineColor           = [0, 0, 0];        
        
        % Sets the line style of the base line. As a string.  
        % Either {'-'} | '--' | '---' | ':' | '-.' | 'none'.
        baseLineStyle           = '-';              
        
        % Sets the width of the base line. Must be a scalar.
        baseLineWidth           = 1;                
        
        % Sets the base value used for bar and area plot. (Sest also the 
        % y-axis base value for the base line) 
        baseValue               = 0;   
        
        % Sets the color of the indicator of the candle. Must either be a  
        % 1 x 3 double with the RGB colors or a string with the color 
        % name.
        candleIndicatorColor    = [0 0 0];
        
        % Sets the line style of the indicator of the candle. Must be a    
        % string. Default is '-'.
        candleIndicatorLineStyle= '-';
        
        % Sets the marker of the indicator of the candle. Must be a   
        % string. Default is 'none'.
        candleMarker            = 'none';
        
        % Sets which variables are going to be plotted as open, close, 
        % high, low and indicator. Must be a cellstr. E.g.
        % 
        % {'open','var1','close','var2',...}
        % 
        % If a type (e.g. 'low') is not given it will not be plotted.
        % 
        % Meaning of each type:
        % 
        % > 'close'     : The lowest values of the plotted patches of 
        %                 the candle.
        % 
        % > 'high'      : The highest values of the plotted candles.
        % 
        % > 'indicator' : The value for where to plot a horizontal line
        %                 (across the patch). E.g. the mean value.   
        % 
        % > 'open'      : The highest values of the plotted patches of 
        %                 the candle.
        % 
        % > 'low'       : The lowest values of the plotted candles.
        candleVariables         = {};
        
        % Sets the width of the candle plot. As a scalar. Default is 
        % 0.45.
        candleWidth             = 0.45;
        
        % If you set this to a file name, this file will be evaluated
        % after all the plotting is done. Must be a string.
        % 
        % This could be nice for adding special annotation, lines and 
        % so on. In this file you can use any MATLAB function, but 
        % some strange error message can occur if you use local 
        % variables which is already defined (So use long and 
        % descriptive variable names in the provided code to prevent 
        % this).
        % 
        % This property is only an option for the method graph.
        % 
        % Nice to know:
        % 
        % > The current nb_figure object can be reached with 
        %  get(obj,'figureHandle')
        % 
        % > The current nb_axes object can be reached with 
        %  get(obj,'axesHandle')
        % 
        % Caution : Be aware that the name of the file must be unique
        %           and cannot be a MATLAB function or a local variable.
        % 
        % Caution : The file must be a MATLAB .m file
        % 
        code                    = '';
        
        % Sets the colormap used when plotType is set to 'image' and
        % fanMethod is set to 'graded'. Must be given as n x 3 double or 
        % the path to a .mat file that contain the colormap. Default is  
        % given by nb_axes.defaultColorMap.
        %
        % For an example of a supported MAT file see:
        % - ...\Examples\Graphics\colorMapNB.mat
        colorMap                = [];
        
        % Sets the color order of the plotted data (Left axes). Either 
        % a cellstr with the color names (size; 1xM) or a double with 
        % RGB colors (Size; Mx3). Where M is the number of plotted 
        % variables against the left axes.        
        colorOrder              = [];  
        
        % Sets the color order of the plotted data (Right axes). Either 
        % a cellstr with the color names (size; 1xM) or a double with 
        % RGB colors (Size; Mx3). Where M is the number of plotted 
        % variables against the right axes.
        colorOrderRight         = [];               
        
        % Sets the colors of the given variable(s). Must be a cell 
        % array on the form: {'var1', 'black', 'var2', [0.2 0.2 0.2],...}.  
        % Here we set the colors of the variables 'var1' and 'var2' 
        % to 'black'  and [0.2 0.2 0.2] (RGB color) respectively. The   
        % variables given must be included in the variablesToPlot or 
        % variablesToPlotRight properties.
        %
        % Caution: For the graphInfoStruct() method you need to select
        %          the variables from obj.DB.dataNames instead!
        colors                  = {};
        
        % Sets the how the figure is saved to .pdf and other figure 
        % formats. If 1 is given the output file will be cropped. 
        % Default is not to crop (i.e. set to 0).         
        crop                    = 0; 
        
        % Set to false to not display observation values when holding the
        % mouse over the graph. Defualt is true.
        displayValue            = true;
        
        % If you want a extended footer to the graph in the excel
        % spreadsheet produced by the nb_graph_package.saveData method,
        % this property can be used. The default is to include the same
        % footer as in the graph. English version.
        excelFooterEng          = '';
        
        % If you want a extended footer to the graph in the excel
        % spreadsheet produced by the nb_graph_package.saveData method,
        % this property can be used. The default is to include the same
        % footer as in the graph. Norwegian version.
        excelFooterNor          = '';
        
        % If you want a custom title to the graph in the excel spreadsheet
        % produced by the nb_graph_package.saveData method, this property
        % can be used. The default is to use the same title as in the
        % graph (panel if multiple graphs). English version.
        excelTitleEng          = '';

        % If you want a custom title to the graph in the excel spreadsheet
        % produced by the nb_graph_package.saveData method, this property
        % can be used. The default is to use the same title as in the
        % graph (panel if multiple graphs). Norwegian version.
        excelTitleNor          = '';        
        
        % Set this property to multiply the data with a given factor. 
        % Must be a scalar.        
        factor                  = 1;                
        
        % Set this property if you want to add a legend of none plotted 
        % variable. You can set this property. Must be a cell on the 
        % form: {'legendName', settings,...}, where the legendName will 
        % be text of the fake legend. And the settings input must also 
        % be a cell array with the optional inputs 
        % {...,'propertyName', propertyValue,...}. These settings will 
        % set the appearance of the fake legend. The following 
        % propetyNames are supported:
        % 
        % > 'type'      : Either 'line' or 'patch'.
        % 
        % > 'color'     : Sets the color of the fake legend. Default is 
        %                 'black'. Must either be a 1 x 3 double with 
        %                 the RGB colors or a string with the color 
        %                 name. If shaded patch is wanted it must be
        %                 2 x 3 double with the RGB colors or a 1 x 2
        %                 cellstr with the color names to use.
        % 
        % > 'direction' : Sets the direction of the shading. Either  
        %                 {'north'} | 'south' | 'west' | 'east'. As a 
        %                 string. Default is 'north'. Only an option 
        %                 when 'type' is set to 'patch'.                
        % 
        % > 'edgeColor' : Sets the color of the edge of the patch. 
        %                 Default is the same as the 'color' option. 
        %                 Only an option when 'type' is set to 'patch'.
        % 
        % > 'lineStyle' : Sets the line style of the fake legend. As a 
        %                 string. Either {'-'} | '--' | '---' | ':' | 
        %                 '-.' | 'none'. Default is a normal line.
        %               
        %                 Will set the edge line style if the 'type'
        %                 is set to 'patch'.
        % 
        % > 'lineWidth' : Sets the line width of the fake legend. 
        %                 Default is 2.5. Must be a scalar.
        % 
        % > 'marker'    : Sets the marker of the fake legend. Default is 
        %                 'none'. Only an option when 'type' is set to 
        %                 'line'. Lookup LineSpec in the MATLAB help
        %                 meny for more on the supported marker types.
        % 
        % Caution : Even if you don't want to set any of the optional 
        %           input. The settings input must be given. I.e an 
        %           empty cell, i.e. {}.        
        fakeLegend              = {};               
        
        % Color of the figure as a 1x3 double. Default is
        % [1 1 1].
        figureColor             = [1 1 1];
        
        % Position of the figure as a 1x4 double. Default is
        % []. I.e. use the MATLAB default. In characters.
        figurePosition          = [];
        
        % Sets the name of figure (only in MATLAB), default is no name.
        figureName              = 'none';           
        
        % Sets if figure titles is wanted on the figures when using 
        % the method graphInfoStuct. The fieldnames of the 
        % GraphStruct property will be used as figure title.
        % Default is 0 (not include).
        %
        % If set to a one line char this property can be used for the
        % plotting method graphSubPlots.
        figureTitle             = 0;
        
        % Sets the save file format. Either  'eps', 'jpg', 'pdf' or 
        % 'png'. 'pdf' is default.        
        fileFormat              = 'pdf';            
        
        % Sets the method used for finding the axis limits, and y-ticks.
        % 
        % > 1:  Uses the floor and ceil methods. (Give problem when 
        %       graphing small number)
        % > 2:  Add some space in both direction of the y-axis. (The 
        %       limits will seldom be nice numbers.)
        % > 3:  Uses the submethod findClosestNiceNumber of the class 
        %       to decide on the limits. (Also this method have can 
        %       have problems with data which is not symmetric around 
        %       the zero line.) 
        % > 4 : Uses the MATLAB algorithm for finding the axis limits.        
        findAxisLimitMethod     = 4;   
        
        % For some reason the graph is sometimes flipped and sometimes not.
        % If the graph is flipped use this property to flip it back.
        flip                    = 0;
        
        % Sets the name of font used. Default is 'arial'.
        fontName                = 'Arial';          
        
        % Sets the parameter that scales all the font sizes of the 
        % graphs. Must be scalar. Default is 1 (do not scale).
        fontScale               = 1;
        
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
        fontUnits               = 'points'; 
        
        % Sets the information on which variables and how to plot them 
        % when using the graphInfoStruct(...) method of this class.
        % 
        % Must be an .m-file with the code on how the structure of 
        % graphing information should be initialized or as a structure 
        % with the graphing information. 
        % 
        % Only the graphInfoStruct(...) method uses this property. 
        % See the documentation of the NB toolbox for more on this 
        % input.        
        GraphStruct = struct();
        
        % Sets the graphing style of the plots. Give 'mpr' if you want 
        % the MPR looking style, or 'presentation' for 
        % graphs for the presentation (see nb_Presentation). If you 
        % don't want the grey shaded background you can use 'mpr_white'
        % and 'presentation_white' instead. 
        % 
        % You can also add your own graph style setting through a .m
        % file. I.e. give the filename (without extension) as a string.
        % 
        % E.g. In the file you can type in somthing like:
        % 
        % set(obj,'titleFontSize',12,'legInterpreter','tex');
        % 
        % Caution: If you give this as the first input to the set method
        %          it is possible to overrun some of the default 
        %          settings if that is wanted. E.g. font size of the  
        %          text, the shading of the plot and so on.        
        graphStyle              = 'normal';         
        
        % Set it to 'on' if grid lines are wanted otherwise set it to 
        % 'off'. Default is 'off'.        
        grid                    = 'off';            
        
        % Sets the line style of the grid lines. Either '-', '--', ':' 
        % or '-.'.        
        gridLineStyle           = '--';             
        
        % If you want to include some extra horizontal lines, beside the 
        % base line, you can set this property. Must be set to a scalar 
        % or a double vector with the y-axis value(s) on where to place 
        % the horizontal line(s).        
        horizontalLine          = [];               
        
        % Sets the color(s) of the given horizontal line(s). 
        % 
        % Must either be an M x 3 double with the RGB color(s) or a 
        % 1 x M cell array of strings with the color name(s). Where M 
        % must be less than the number of plotted horizontal lines. 
        % 
        % If less or no color(s) is/are set by this property the default 
        % colors for the rest or all the horizontal line(s) is/are 
        % [0 0 0], i.e. MATLAB black.        
        horizontalLineColor     = {};               
        
        % Sets the style(s) of the given horizontal line(s). 
        % 
        % Must either be a string or a 1 x M cell array of strings with  
        % the style(s). Where M must be less than the number of plotted 
        % horizontal lines. 
        % 
        % If less or no style(s) is/are set by this property the default 
        % lines for the rest or all the horizontal line(s) is/are '-'.        
        horizontalLineStyle     = '-';              
        
        % Sets the line width of the horizontal line(s). Must be a 
        % scalar. Default is 1.
        horizontalLineWidth     = 1; 
        
        % Sets the language styles of the graphs. Must be a string with 
        % either 'norsk' or 'english'. 'english' is default. I.e. axis
        % settings differs between norwegian and english graphs.        
        language                = 'english';        
        
        % 'on' | {'off'}. As a string.
        % 
        % > 'on'  : The strings given through the fakeLegend and 
        %           patch properties are automatically added to the 
        %           legend. 
        % 
        % > 'off' : The strings given through the fakeLegend and 
        %           patch properties are not automatically added to the 
        %           legend. Which means that you must provide all the 
        %           legend information through the legends property. The 
        %           patch descriptions must be given first and the fake 
        %           legend description must be given last in the legends 
        %           property. Default.        
        legAuto                 = 'off';             
        
        % Set if a box should be drawn around the legend. Either
        % {'on'} | 'off'.
        %
        % Caution : When removing the box you make it impossible to move 
        %           it around afterwards.     
        legBox                  = 'on';             
        
        % Sets the color of the background of the box of the legend. 
        % Either as 1x3 double with the RGB or as a string). 
        % Default is 'none', i.e. transparent.       
        legColor                = 'none';          

        % Sets the number of columns of the legends. Must be a scalar.        
        legColumns              = 1; 
        
        % Sets the width of the columns of the legend. Default is to let 
        % MATLAB find the width itself. If given it must be a scalar 
        % with the width of all columns of the legend or a 1 x legColumns
        % double with the width of each individual column.
        % 
        % Should be between 0 and 1. Use the try and fail method to find 
        % out what fits.
        legColumnWidth          = [];               

        % Give the legends of the plot. Must be given as a cell array 
        % of strings.
        % 
        % Default (it depends on the method you use):
        % 
        % > 'graph'           : The variable names are used as the 
        %                       default legends. (Given by the 
        %                       variableToPlot and variableToPlotRight 
        %                       properties)
        % 
        % > 'graphSubPlot'    : The dataset names are used as the 
        %                       default legends. (Given by the 
        %                       dataNames of the DB property.)
        % 
        % > 'graphInfoStruct' : The dataset names are used as the 
        %                       default legends. (Given by the 
        %                       dataNames of the DB property.)  
        %
        % Caution : The ordering of the legends is as follows:
        %
        %    - patch                : See the patch property (only when 
        %                             legAuto is set to 'off')
        %
        %    - variablesToPlot      : Then the all the variablesToPlot
        %                             variables. When You have splitted
        %                             lines, i.e. either using the 
        %                             dashedLine property or the  
        %                             lineStyles property, these can be set 
        %                             after all the variablesToPlot. Have 
        %                             in mind that the ordering is kept.
        %
        %    - variablesToPlotRight : Then the comes all the variables
        %                             provided by the variablesToPlotRight.
        %                             Then the splitted lines.
        %
        %    - fakeLegend           : Then you can provide the legend text
        %                             for the fake legend. (only when 
        %                             legAuto is set to 'off')
        %
        % Example:
        %
        % data    = nb_ts.rand('2012',10,2);
        % plotter = nb_graph_ts(data);
        % plotter.set('variablesToPlot',{'Var1'},...
        %             'variablesToPlotRight',{'Var2'},...
        %             'lineStyles',{'Var1',{'-','2014','--'},...
        %                           'Var2',{'-','2014','--'},...
        %             'legends',{'Test','Test (--)','Test2','Test2 (--)'});
        % plotter.graph()
        legends                 = {}; 
        
        % Sets the legend(s) of the given variable(s). Must be a cell 
        % array on the form: {'var1', 'Name', 'var2', 'Name2',...}.  
        % Here we set the legends of the variables 'var1' and 'var2' 
        % to 'Name'  and 'Name2' respectively. (The rest will be given the 
        % variable names as default). 
        %   
        % To give a legend to a splitted line (second part) give;
        % {...,'Var1(second)','LegendSplitted',...} (Is case sensitiv)
        %
        % Caution : legAuto should be set to 'on'. Which is not default.
        %           This is only important if the patch or fakeLegend
        %           property is used.
        %
        % Caution : When given this property will overwrite the legends
        %           property
        %
        % Caution : If the variable, scattergroup or candle is not found
        %           no error will occure!
        %
        % Caution : If you have used the patch or fakeLegend property these
        %           can be translated as well with this property
        legendText              = {};
        
        % Sets the font color(s) of the legend text. Must either be a 
        % 1x3 double or a string with the color name of all legend text 
        % objects, or a M x 3 double or a cellstr array with size
        % 1 x M with color names to use of each legend text object.
        legFontColor            = [0,0,0];
        
        % Sets the font size of the legend. Must be a scalar default is 
        % 10.        
        legFontSize             = 10;               
        
        % Sets the interpreter of the legend text. Must be a string.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        legInterpreter          = 'none';           
        
        % Sets the location of the legend, must be string. The 
        % location can be:
        % 
        % > 'Best'      : Same as 'NorthWest'.
        % > 'NorthWest'
        % > 'North'
        % > 'NorthEast'
        % > 'SouthEast'
        % > 'South'
        % > 'SouthWest'
        % > 'below'     : Below the plot (when many subplots, it will 
        %                 place the legend below all of them)
        % > 'middle'    : Could only be use for 2 x 2 subplot, and then 
        %                 it places the legend between the upper and 
        %                 lower subplots.  
        %
        % Location that only works for the graph() method:
        % > 'outsideright'    : Legend is placed outside the axes on the
        %                       right side, and the axes is resized, so
        %                       the axes and legend does not take up more
        %                       space than the axes did in the first place.
        %                       The legend is vertically centered.
        % > 'outsiderighttop' : Same as 'outsideright', but placed 
        %                       vertically top.
        legLocation             = 'Best';           
           
        % Sets the position of the legend. Must be a 1x2 double. Where 
        % the first element is the x-axis location and the second is the 
        % y-axis location. [xPosition yPosition]
        % 
        % Caution : Both elements must be between 0 and 1. And where we 
        %           have that [0, 0] will be the bottom left location of 
        %           the axes and [1, 1] is the top right position of the 
        %           axes. (This position will be the top left 
        %           position of the legend itself.) 
        %   
        % Caution : This option overruns the legLocation property.
        legPosition             = [];               
        
        % Set this property to reoder the legend. Either a string
        % with {'default'} | 'inverse' or a double with how to reorder
        % the legend. E.g. if you have 3 legends to plot the default   
        % index will be [1,2,3], the inverse ('inv') will be [3,2,1].
        % If you want to decide that the 3. legend should be first, then 
        % the 1. and 2., you can type in [3,1,2].
        % 
        % Caution : If a double is given it must have as many elements
        %           as there is plotted legends. I.e. if you give a  
        %           empty string to one of the legends it will be 
        %           excluded. Say you provide the property
        %           legends as {'s','','t','f'} then the double
        %           must have size 1x3.        
        legReorder              = 'default';
        
        % The vertical space between the texts of the legend. Must be a 
        % scalar. Default is 0. 
        legSpace                = 0; 
        
        % Sets the line styles of the given variable(s). Must be a cell 
        % array on the form: {'var1', '-', 'var2', '---',...}. Here we 
        % set the line styles of the variables  'var1' and 'var2' to '-' 
        % and '---' respectively. The variables given must be included 
        % in the variablesToPlot or variablesToPlotRight properties.
        % 
        % Supported line styles are '-','--',':','.-','---'  
        %
        % Caution : For nb_graph_ts and nb_graph_data it is possible to
        % split the plotted line using the following syntax;
        % {'var1',{'-','2000Q1','--'}} and {'var1',{'-',2,'--'}}
        % respectively
        lineStyles              = {};               
        
        % Sets the line with of the line plots. Must be a scalar. 
        % Default is 2.5.         
        lineWidth               = 2.5;              
        
        % Sets the line widths of the given variables. Must be a cell 
        % array on the form: {'var1', 1, 'var2', 1.5,...}. Here we set 
        % the line widths of the variables  'var1' and 'var2' to 1 and 
        % 1.5 respectively. The variables given must be included in the 
        % variablesToPlot or variablesToPlotRight properties.        
        lineWidths              = {};               
        
        % A nb_struct with the local variables of the nb_graph 
        % object. I.e. a field with name 'test' can be reach with
        % the string input %#test.
        localVariables          = [];
        
        % Sets how the given mnemonics (variable and type names) should 
        % map to different languages. Must be cell array on the form:
        % 
        % {'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'};
        % 
        % Or a .m file name, as a string. The .m file must include
        % (and only include) what follows:
        % 
        % obj.lookUpMatrix = {
        % 'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'};  
        lookUpMatrix            = {}; 
        
        % Sets the markers of the given variables. Must be a cell array 
        % on the form: {'var1', '^', 'var2', 'o',...}. Here we set the 
        % markers of the variables  'var1' and 'var2' to '^' and 'o' 
        % respectively. The variables given must be included in the 
        % variablesToPlot or variablesToPlotRight properties.
        % 
        % See the table below on which markers that are supported.
        %
        % '+' : Plus sign
        % 'o' : Circle
        % '*' : Asterisk
        % '.' : Point
        % 'x' : Cross
        % 's' : Square
        % 'd' : Diamond
        % '^' : Upward-pointing triangle
        % 'v' : Downward-pointing triangle
        % '>' : Right-pointing triangle
        % '<' : Left-pointing triangle
        % 'p' : Five-pointed star (pentagram)
        % 'h' : Six-pointed star (hexagram)
        markers                 = {};               
        
        % Sets the size of the all markers. Must be a scalar. Default 
        % is 8.        
        markerSize              = 8; 
        
        % Set it to 1 if no legend is wanted, otherwise set it to 0. 
        % Default is 0.        
        noLegend                = 0;                
        
        % Set it to 1 if no label(s) is/are wanted on the graphs, 
        % otherwise set it to 0. Both on the y-axis and x-axis. 
        % Default is 0. This is of course only have an effect if the 
        % nb_graph object have been given the xLabel or yLabel 
        % properties. (These are empty by default.)        
        noLabel                 = 0;                
        
        % Set to true (1) to remove tick marks and tick marks label of 
        % axes. Default is false (0). 
        noTickMarkLabels        = 0;
        
        % Set to true (1) to remove tick marks and tick marks label of 
        % the left side of the axes. Default is false (0). 
        noTickMarkLabelsLeft    = 0;
        
        % Set to true (1) to remove tick marks and tick marks label of 
        % the right side of the axes. Default is false (0). 
        noTickMarkLabelsRight   = 0;
        
        % If the font should be normalized to the figure or axes.
        % Either 'figure' or 'axes'.
        normalized              = 'figure';
        
        % Set it to 1 if you don't want title(s) of the graphs, 
        % otherwise set it to 0. Default is 0. 
        %
        % Set it to 2 if you want the dataNames{ii} as the title of the
        % graph when using the graph method.
        noTitle                 = 0;                
        
        % Number of graph produced by the graph methods. Not settable.        
        numberOfGraphs          = [];               
        
        % Sets the page of the data object to plot. Only an option 
        % for graph() method. Default is [], i.e. plot all pages
        % in seperate figures.
        page                    = [];
        
        % A struct with the parameters that can be used in evaluation of
        % expressions in the graphSubPlots and graphInfoStruct methods.
        parameters              = struct();
        
        % Sets the patch property of the object. If set this will
        % add a patch (color fill) between two variables. 
        % 
        % Only one patch :
        % 
        % {'patchName','var1','var2',color}
        % 
        % More patches :
        % 
        % {'patchName1','var1Patch1','var2Patch1',color1 ,...
        % 'patchName2','var1Patch2','var2Patch2',color2,...}
        % 
        % Where the the color option(s) must either be a 1 x 3 double
        % with the RGB colors or a string with the color name.
        % 
        % The first input will be the legend text of the patch. I.e.
        % 'patchName', 'patchName1' and 'patchName2' will be the 
        % description text included in the legend. (If not the property 
        % legAuto is set to 'off'.)        
        patch                   = {};  
        
        % Sets the transparency of the patches. A number between 0 and 1.
        % 1 is opaque, while 0 is fully transparent.
        patchAlpha              = 1;
        
        % Set it to 1 if you want store all the created graphs produced 
        % in one pdf file. Must be use in combination with the saveName 
        % property.
        pdfBook                 = 0;                
        
        % Sets the plot aspect ratio. Either [] or '[4,3]'. Default
        % is [].
        %
        % When set to '[4,3]' the aspect ratio of the figure is
        % 4 to 3, or when '[16,9]' the aspect ratio of the figure 
        % is 16 to 9
        plotAspectRatio         = [];
        
        % Sets the position of the axes, must be an 1x4 double. 
        % [leftMostPoint lowestPoint width height]. Only an option for 
        % the graph() method. Default is [0.1 0.1 0.8 0.8].  
        %
        % For the graph method graphSubPlots the position input can be
        % given a 1 x N cell array, where each element is a 1x4 double.
        % N = obj.subPlotSize(1)*obj.subPlotSize(2).
        position                = [0.1 0.1 0.8 0.8];               
        
        % Sets the saved file name. If not given, no file(s) is/are 
        % produced. Must be a string. 
        % 
        % Default is to save each graph produced in separate files. Set 
        % the pdfBook property to 1 if you want to save all the produced 
        % graphs in one pdf file. (To save all figures in one file is 
        % only possible for pdf files. I.e. the fileFormat property
        % must be 'pdf'.)         
        saveName                = '';   
        
        % The shading option of the axes background:
        % - 'grey' : Shaded grey background 
        % - 'none' : Background color given by the color property.
        % - A n x m x 3 double with the background color. n is the
        % number of horizontal pixels, m is the number of vertical
        % pixels and 3 means the RGB colors.       
        shading                 = 'none'; 
        
        % Sets the number of subplots per figure. Must be a 1 x 2 double 
        % with the number of subplot rows as the first element and the 
        % number of subplot columns as the second element. Only an 
        % option of the graphSubPlots() and graphInfoStruct() methods.
        % 
        % Default is [2, 2].        
        subPlotSize             = [2,2]; 
        
        % Set it to 1 if you want the 1x2 and 2x1 subplots to better
        % fit for usage in presentations. Default is 0, i.e. use MATLAB
        % default positions. 
        % 
        % When set to 1 this class uses the nb_subplotSpecial instead 
        % of nb_subplot to find the positions of the subplots.        
        subPlotSpecial          = 0;
        
        % Sets a number which the area or the stacked bar plot should 
        % sum to. Must be a scalar. I.e. if 100 is given. The sizes of 
        % the bars will be the percentage share of the total sum.        
        sumTo                   = [];    
        
        % Used by the nb_graph_subplot class to locate the nb_graph
        % object in the subplot. Should not be used. Use userData
        % instead.
        tag                     = 1;
        
        % Sets the title of the plot. Must be a char. Only an option 
        % for the graph(...) method.        
        title                   = '';               
        
        % Sets the figure title text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        titleAlignment          = 'center'; 
        
        % Sets the font size of the titles which is placed above the 
        % (sub)plot(s). Must be scalar. Deafult is 14.        
        titleFontSize           = 14;               
        
        % Sets the font weight of the titles which is placed above the 
        % (sub)plot(s). Must be a string. Default is 'bold'.
        % 
        % Either 'bold', 'normal', 'demi' or 'light'.        
        titleFontWeight         = 'bold';           
        
        % Sets the interpreter used for the given string given by the 
        % title property.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        titleInterpreter        = 'none';  
        
        % Sets the placement of the title. {'center'} | 'left' | 'right' |
        % 'leftaxes'.
        titlePlacement          = 'center';
        
        % User data, can be set to anything you want.
        userData                = '';
        
        % Sets the variables to plot against the left (or both) axes. 
        % Must be a cell array of strings with the variable names. I.e. 
        % {'var1', 'var2',...}. 
        % 
        % Not an option for the graphInfoStruct(...), which use the 
        % property GraphStruct instead.        
        variablesToPlot         = {};               
        
        % Sets the variables to plot against the right axes. Must be 
        % a cell array of strings with the variable names. I.e. 
        % {'var1', 'var2',...}. 
        % 
        % Not an option for the graphInfoStruct(...), which use the 
        % property GraphStruct instead.
        variablesToPlotRight    = {};  
        
        % Sets (add) the text of the x-axis label. Must be a string.      
        xLabel                  = '';               
        
        % Sets the x-axis label text alignment, default is 'center'. You 
        % also have 'left' and 'right'.
        xLabelAlignment         = 'center'; 
        
        % Sets the font size of the x-axis label. Must be scalar. 
        % Default is 12.        
        xLabelFontSize          = 12;               
        
        % Sets the font weight of the x-axis label. Must be string.
        % Either 'bold', 'normal', 'demi' or 'light'.        
        xLabelFontWeight        = 'bold';          
        
        % The interpreter used for the given string given by the xLabel 
        % property.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        xLabelInterpreter       = 'none'; 
        
        % Sets the placement of the x-axis label. {'center'} | 'left' | 
        % 'right' | 'leftaxes'.
        xLabelPlacement         = 'center';
        
        % Sets the x-axis tick mark labels. To translate the default tick
        % mark label 'Var1' and 'Var2' you can use;
        %
        % {'Var1','Label1','Var2','Label2'} 
        % 
        % If given as a empty cell, default x-axis tick marks will be 
        % used, which is default.
        % 
        % This property can be used to create multi-lined x-axis tick 
        % mark labels. To do this give a multi-row char to the labels
        % you want to make multi-lined.
        xTickLabels             = {};
        
        % Sets (add) the text of the y-axis label. Must be a string.
        yLabel                  = '';               
       
        % Sets the font size of the y-axis label. Must be scalar. 
        % Default is 12.        
        yLabelFontSize          = 12;               
        
        % Sets the font weight of the y-axis label. Must be string.
        % Either 'bold', 'normal', 'demi' or 'light'.        
        yLabelFontWeight        = 'bold';           
       
        % The interpreter used for the given string given by the xLabel 
        % property.
        % 
        % > 'latex' : For mathematical expression 
        % > 'tex'   : Latex text interpreter,
        % > 'none'  : Do nothing        
        yLabelInterpreter       = 'none';           
        
        % Sets the text of the y-axis label. (Only on the right side.) 
        % Must be a string. Takes the same font option as the yLabel 
        % property        
        yLabelRight             = ''; 
        
    end
    
    properties (Access=public,Hidden=true)
        
        % The parent as an nb_GUI object. Needed for default 
        % settings
        parent                  = [];
        
    end

    properties(Access=protected)
        
        advanced                    = 0;                % Sets if the nb_graph object is used in an nb_graph_adv object or not.
        axesHandle                  = [];               % Handle to the current nb_axes object
        endIndex                    = [];               % The index of last graphing date. Not settable.
        dataToGraph                 = [];               % Manipulated data to graph. Not settable. 
        dataToGraphRight            = [];               % Manipulated data to graph of the right axes of a plot. Not settable.
        fieldIndex                  = [];               % Row index of the current field of the property 'graphinfostruct' being graph by the method graphInfoStruct. Not settable.
        fieldName                   = '';               % Name of current field of the property 'graphinfostruct' being graph by the method graphInfoStruct. Not settable.
        figTitleObjectEng           = [];               % Handle to a nb_figureTitle object added to the graph (English)
        figTitleObjectNor           = [];               % Handle to a nb_figureTitle object added to the graph (Norwegian)
        figureHandle                = [];               % The handle to the all the nb_figure handles
        footerObjectEng             = [];               % Handle to a nb_footer object added to the graph (English)
        footerObjectNor             = [];               % Handle to a nb_footer object added to the graph (Norwegian)
        graphMethod                 = '';               % Name og plot method used. Not settable
        inputs                      = struct();         % Parsed optional inputs for the graphInfoStruct() method 
        manuallySetColorOrder       = 0;                % Indicator if the colorOrder has been set manually
        manuallySetColorOrderRight  = 0;                % Indicator if the colorOrderRight has been set manually
        manuallySetFigureHandle     = 0;                % Indicator if the figureHandle has been set manually
        manuallySetLegend           = 0;                % Indicator if the legend has been set manually
        plotTypesInterpreted        = {};               % The interpretation of the 'plotTypes' property
        labelVariablesX             = {};               % A nested cell array to store the plotted identifiers in the first dim of each children. used by the nb_plotLabels annotation object
        labelVariablesY             = {};               % A nested cell array to store the plotted identifiers in the second dim of each children. used by the nb_plotLabels annotation object
        legendObject                = [];
        listeners                   = [];               % A vector of listeners to annotation objects.
        
        % When the properties startGraph, endGraph, stopStrip, xTickStart, 
        % barShadingDate and defaultFans are assign with local variables 
        % the notation obj. will return the interpreted value when returnLocal, 
        % is set to 0, otherwise the local variable syntax is returned.
        returnLocal                 = 0;   
        startIndex                  = [];               % Index of the fist graphing date. Not settable.
        subPlotIndex                = [];               % Subplot index. Not settable.
        UIContextMenu               = [];               % Context menu related to the nb_axes object 
        xTick                       = [];               % Integer ticks of the graph. Not settable.
        
    end
    
    properties (Hidden=true)
        
        % Set to true to add tooltip, excel title and footer to graph.
        % Used by nb_grapg_package.writePDFExtended. See
        % nb_graph.addAdvancedComponents.
        addExtraText            = false;
        
        % Stores the name of the current template in use by the object.  
        % Used in the nb_graphGUI class.
        currentTemplate         = '';
        
        % Set to true to add Figur 1.1 to the first line of figureTitleNor
        % and Chart 1.1 to figureTitleEng.
        defaultFigureNumbering  = false;
        
        % Set to true during writing to .eps or .pdf to fix error in
        % writing en-dash and em-dash to the file formats.
        printing2PDF            = false;
        
        % Local template used in the nb_graphGUI class.
        template                = [];
        
        % Used in the case that addExtraText is set to true. See
        % nb_graph.addAdvancedComponents. Should be be assign from the
        % nb_graph_adv.tooltipEng.
        tooltipEng              = '';
        
        % Used in the case that addExtraText is set to true. See
        % nb_graph.addAdvancedComponents. Should be be assign from the
        % nb_graph_adv.tooltipNor.
        tooltipNor              = '';
        
    end
    
    events
        
        % Event triggered when the graph is updated
        updatedGraph
        
        % Event triggered when the graph style is changed
        updatedGraphStyle
        
    end
    
    methods (Hidden=true)
       
        function graph(obj)  %#ok<MANU>
            
        end
        
        function getData(obj) %#ok<MANU>
            
        end
        
        function clean(obj)
        % Will remove the advanced components, as figure titles and
        % footers
            
            obj.figTitleObjectNor = [];
            obj.figTitleObjectEng = [];
            obj.footerObjectNor   = [];
            obj.footerObjectEng   = [];
            obj.noTitle           = 0;
            
        end
        
        function notifyUpdatedGraph(obj,~,~)
            notify(obj,'updatedGraph');
        end
        
        function notifyLegendPositionChanged(obj,legend,~)
            obj.legPosition = legend.position;
        end
            
    end
        
    methods (Access=public,Hidden=true)
        
        function s = struct(obj)
            
            s     = struct();
            props = properties('nb_graph');
            for ii = 1:length(props)
                
                switch lower(props{ii})
                    
                    case 'annotation'
                        
                        if isa(obj.annotation,'nb_annotation')
                            if isvalid(obj.annotation)
                                ann = struct(obj.annotation);
                            else
                                ann = [];
                            end
                        elseif isempty(obj.annotation)
                            ann = [];
                        else
                            
                            tAnn = obj.annotation;
                            sAnn = length(tAnn);
                            ann  = cell(1,sAnn);
                            kk   = 1;
                            for jj = 1:sAnn
                                if isvalid(tAnn{jj})
                                    ann{kk} = struct(tAnn{jj});
                                    kk      = kk + 1;
                                end
                            end
                            
                            % Remove empty cell (Due to invalid annotation
                            % objects)
                            ind = ~cellfun('isempty',ann);
                            ann = ann(ind);
                            
                        end
                        
                        s.annotation = ann;
  
                    otherwise                        
                        s.(props{ii}) = obj.(props{ii});
                end
                
            end
            
            % Do the protected properties we need to keep as well
            %-----------------------------------------------------
            figTitleObjectE = obj.figTitleObjectEng;
            if isa(figTitleObjectE,'nb_figureTitle')
                figTitleObjectE = struct(figTitleObjectE);
            end
            s.figTitleObjectEng = figTitleObjectE;
            
            figTitleObjectN = obj.figTitleObjectNor;
            if isa(figTitleObjectN,'nb_figureTitle')
                figTitleObjectN = struct(figTitleObjectN);
            end
            s.figTitleObjectNor = figTitleObjectN;
            
            footerObjectE = obj.footerObjectEng;
            if isa(footerObjectE,'nb_footer')
                footerObjectE = struct(footerObjectE);
            end
            s.footerObjectEng = footerObjectE;
            
            footerObjectN = obj.footerObjectNor;
            if isa(footerObjectN,'nb_footer')
                footerObjectN = struct(footerObjectN);
            end
            s.footerObjectNor = footerObjectN;
            
            % Hidden or protected properties that needs to saved
            s.advanced                   = obj.advanced;
            s.manuallySetColorOrder      = obj.manuallySetColorOrder;
            s.manuallySetColorOrderRight = obj.manuallySetColorOrderRight;
            s.manuallySetLegend          = obj.manuallySetLegend;
            s.labelVariablesX            = obj.labelVariablesX;
            s.labelVariablesY            = obj.labelVariablesY;
            s.template                   = obj.template;
            s.currentTemplate            = obj.currentTemplate;
            
        end
        
        function graphUpdate(obj,~,~)
        % Callback function listening to the changedGraph event
        
            if strcmpi(obj.graphMethod,'graphInfoStruct')
                graphInfoStruct(obj);
            elseif strcmpi(obj.graphMethod,'graphSubPlots')
                graphSubPlots(obj);
            else
                graph(obj);
            end
            
            % Notify listeners
            notify(obj,'updatedGraph');
             
        end
        
        function graphStyleUpdate(obj,~,~)
        % Callback function listening to the changedGraph event
        
            if strcmpi(obj.graphMethod,'graphInfoStruct')
                graphInfoStruct(obj);
            elseif strcmpi(obj.graphMethod,'graphSubPlots')
                graphSubPlots(obj);
            else
                graph(obj);
            end
            
            % Notify listeners
            notify(obj,'updatedGraphStyle');
            notify(obj,'updatedGraph');
             
        end
        
        function axesPropertiesGUI(obj,~,~)
        % Set properties of the axes in a GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_axesGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function lookUpGUI(obj,~,~)
        % Set the property look up matrix

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_lookUpGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function setPageGUI(obj,~,~)
        % Set properties of the axes in a GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_setPageGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function spreadsheetGUI(obj,~,~)
        % Create simple spreadsheet of data behind figure    

            if isempty(obj.DB)
                nb_errorWindow('The data of the graph is empty and cannot be displayed.')
                return
            end

            if isa(obj.parent,'nb_GUI')
                if any(strcmpi(obj.graphMethod,{'','graph'}))
                    gui = nb_spreadsheetAdvGUI(obj.parent,obj.DB,1);
                    addlistener(gui,'saveToGraph',@obj.resetDataCallback);
                    set(gui,'page',obj.page);
                else
                    nb_spreadsheetSimpleGUI(obj.parent,obj.DB);
                end
            else
                nb_spreadsheetSimpleGUI(obj.parent,obj.DB);
            end

        end
        
        function spreadsheetSubplotGUI(obj,hObject,~)
        % Create simple spreadsheet of data behind a subplot    
        
            if strcmpi(obj.graphMethod,'graphSubPlots')

                var = get(hObject,'tag');
                if isa(obj,'nb_graph_cs')
                    data = obj.DB.window({},{var}); 
                else
                    data = obj.DB.window('','',{var});        
                end

            else

                userD          = get(hObject,'userData');
                [fName,fIndex] = deal(userD{:}); 
                expression     = obj.GraphStruct.(fName){fIndex,1};

                % Get plotted variables in subplot
                ind = strfind(expression,'[');
                if isempty(ind)
                    vars      = {expression};
                else
                    vars      = regexp(expression,',','split');
                    vars{1}   = vars{1}(2:end);
                    vars{end} = vars{end}(1:end-1);
                end 

                % Some may have to be created?
                data = obj.DB;
                ind  = ismember(vars,data.variables);
                data = createVariable(data,vars(~ind),vars(~ind));
                if isa(obj,'nb_graph_cs')
                    data = data.window({},vars); 
                else
                    data = data.window('','',vars);        
                end 

            end
            nb_spreadsheetSimpleGUI(obj.parent,data);

        end
        
        function spreadsheetFanDataGUI(obj,~,~)
        % Create simple spreadsheet of data behind figure    

            fData = get(obj,'fanData');
            if isempty(fData)
                nb_errorWindow('The fan data of the graph is empty and cannot be displayed.')
                return
            end
            nb_spreadsheetSimpleGUI(obj.parent,fData);

        end
        
        function resetDataCallback(obj,hObject,~)
        % hObject: A nb_spreadsheetAdvGUI object   
            
            % Check that the graph window is not closed
            f = get(obj,'figureHandle');
            if ~isa(f,'nb_figure')
                nb_errorWindow(['The figureHandle returned an object of class ' class(f),...
                    '. Please contact the DAG development team for fixing the problem.'])
                return
            end
            if ~ishandle(f.figureHandle)
                nb_errorWindow('You have closed the graph window, so the changes cannot be applied')
                return
            end
            
            newData         = hObject.data;
            [message,err,s] = updatePropsWhenReset(obj,newData);
            if err
                nb_errorWindow(message);
                return
            end
            
            if isempty(message)
                message = 'Are you sure you want to save the updated data to the graph?';
            else
                message = char(message,'');
                message = char(message,'Are you sure you want to proceed?'); 
            end
            
            nb_confirmWindow(message,@notUpdateCurrent,{@updateCurrent,obj,s,hObject},'Reset data');
            
            function updateCurrent(hObject,~,obj,s,spreadsheetGUI)

                % Close confirm window
                close(get(hObject,'parent'));
                
                % Here I update the properties given the possible loss of data
                % or observations
                props  = s.properties;
                fields = fieldnames(props);
                for ii = 1:length(fields)
                    if any(strcmpi(fields{ii},{'startGraph','endGraph'}))
                        set(obj,fields{ii},props.(fields{ii}));
                    else
                        obj.(fields{ii}) = props.(fields{ii});
                    end
                end
                
                % Check that the spreadsheet is not closed
                if isa(spreadsheetGUI,'nb_spreadsheetGUI')
                    if ~isvalid(spreadsheetGUI)
                        nb_errorWindow('You closed the spreadsheet window, so the changes cannot be applied.')
                        return
                    end
                end
                
                % Reset data
                nData  = spreadsheetGUI.data;
                obj.DB = nData;
               
                % Update graph
                try
                    graphUpdate(obj,[],[])
                    if isa(spreadsheetGUI,'nb_spreadsheetGUI')
                        delete(spreadsheetGUI.figureHandle);
                        delete(spreadsheetGUI)
                    end
                catch ErrT
                    nb_errorWindow('Graph could not be updated with your data changes. MATLAB error:: ', ErrT)
                end

            end

            function notUpdateCurrent(hObject,~)

                % Close confirm window
                close(get(hObject,'parent'));

            end
            
        end
        
        function updateGUI(obj,~,~)
        % Update data of graph and replot

            if isempty(obj.DB)
                nb_errorWindow('The graph is empty and cannot be updated.')
                return
            end
            
            if ~isempty(obj.stopUpdate)
                now  = str2double(nb_clock());
                stop = str2double(obj.stopUpdate);
                if now >= stop 
                    nb_errorWindow(['The stop update date has been pasted; ' obj.stopUpdate '.'])
                    return
                end      
            end

            oldDB = obj.DB;
            if obj.DB.isUpdateable()

                try
                    newDB = oldDB.update('off','on');
                catch Err
                    message = ['The data couldn''t be updated.',nb_newLine(2), ...
                               'Either the link to the data source is broken, or you don''t have access to the',nb_newLine(1),...
                               'relevant databases.',nb_newLine(2),...
                               'MATLAB error: '];
                    nb_errorWindow(char(message), Err)
                    return
                end

                h.data = newDB;
                try
                    resetDataCallback(obj,h,[])
                catch Err
                    nb_errorWindow('Something went wrong when resetting the plotting options of the graph. This may lead to a fatal error:: ',Err)
                end

            else
                nb_errorWindow('The data of the graph is not updateable. No link to the data source.')
            end

        end
        
        function selectPlotTypeGUI(obj,~,~)
            
            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
            
            % Make GUI
            gui = nb_selectPlotTypeGUI(obj);
            addlistener(gui,'graphStyleChanged',@obj.graphStyleUpdate);
            
        end
        
        function selectVariableGUI(obj,~,~)
        % Select variable GUI    

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_selectVariableGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function patchGUI(obj,~,~)
        % Make dialog box for adding patch between two variables

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            gui = nb_patchGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function legendGUI(obj,~,~)
        % Set properties of the legend GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_legendGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function addAxesTextGUI(obj,hObject,~)
        % Callback function for open up a dialog box for editing axes text
        % components as title and labels.

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            type = get(hObject,'tag');
            gui  = nb_axesTextGUI(obj,type);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function generalPropertiesGUI(obj,~,~)
        % Set properties with the general properties GUI

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_generalGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function reorderGUI(obj,~,~,type)
        % Open up a new window to reorder the variables, types or dates GUI
        
            if isa(obj,'nb_graph_cs')
                
                if strcmpi(type,'left')
                    reorderGUIObj = nb_reorderGUI(obj.variablesToPlot,'Reorder variables');
                elseif strcmpi(type,'right')
                    reorderGUIObj = nb_reorderGUI(obj.variablesToPlotRight,'Reorder variables (right axes)'); 
                elseif strcmpi(type,'typesright')
                    if strcmpi(obj.plotType,'grouped') && strcmpi(obj.barOrientation,'horizontal') && ~isempty(obj.variablesToPlotRight)
                        reorderGUIObj = nb_reorderGUI(obj.typesToPlotRight,'Reorder types (right)');
                    else
                        nb_errorWindow(['Reordering of the right axis types is only supported for horizontal grouped '...
                                        'bar plots with some selected right hand side variables.'])
                    end
                else
                    reorderGUIObj = nb_reorderGUI(obj.typesToPlot,'Reorder types');
                end
                
            elseif isa(obj,'nb_graph_ts')
                
                if isempty(obj.datesToPlot)
                    if strcmpi(type,'left')
                        reorderGUIObj = nb_reorderGUI(obj.variablesToPlot,'Reorder variables');
                    else
                        reorderGUIObj = nb_reorderGUI(obj.variablesToPlotRight,'Reorder variables (right axes)');    
                    end
                else
                    if strcmpi(type,'left')
                        reorderGUIObj = nb_reorderGUI(obj.variablesToPlot,'Reorder variables');
                    else
                        reorderGUIObj = nb_reorderGUI(obj.datesToPlot,'Reorder dates');
                    end
                    
                end
                
            else % nb_graph_data
                
                if strcmpi(type,'left')
                    reorderGUIObj = nb_reorderGUI(obj.variablesToPlot,'Reorder variables');
                else
                    reorderGUIObj = nb_reorderGUI(obj.variablesToPlotRight,'Reorder variables (right axes)');    
                end
                
            end
                    
            addlistener(reorderGUIObj,'reorderingFinished',@obj.reorderCallback);

        end
        
        function reorderCallback(obj,hObject,~)
        % hObject : An object of class nb_reorderGUI
        
            if ~isempty(strfind(hObject.name,'variables (right axes)'))
                type = 'variables right';
            elseif ~isempty(strfind(hObject.name,'variables'))
                type = 'variables';
            elseif ~isempty(strfind(hObject.name,'dates'))
                type = 'dates';
            elseif ~isempty(strfind(hObject.name,'types (right)'))
                type = 'types right';
            else
                type = 'types';
            end
        
            reordered = hObject.cstr';
            if isempty(reordered)
                return
            end
            switch type
                
                case 'variables right'
                    obj.variablesToPlotRight = reordered;
                case 'variables'
                    obj.variablesToPlot = reordered;
                case 'types right'
                    obj.typesToPlotRight = reordered;
                case 'types'
                    obj.typesToPlot = reordered;
                case 'dates'
                    obj.datesToPlot  = reordered;
            end
            
            % Update the graph and notify listeners
            graphUpdate(obj,[],[]);
        
        end
            
        function lineGUI(obj,~,~,type)
        % Make dialog box for vertical, horizontal and normal line 
        % objects

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            gui = nb_lineGUI(obj,type);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function highlightGUI(obj,~,~)
        % Make dialog box for adding highlight area objects

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            gui = nb_highlightGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function addTextBox(obj,~,~)
        % Add text box to current figure

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            % Create an text box object 
            ann = nb_textBox('string',  'text',...
                             'xData',   0.5,...
                             'yData',   0.5,...
                             'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addCurlyBrace(obj,~,~)
        % Add text box to current figure

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            % Create an text box object 
            ann = nb_curlyBrace('xData',   [0.5,0.6],...
                                'yData',   [0.5,0.6],...
                                'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addDrawLinesAnnotation(obj,~,~)
        % Add rectangle/circle to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end

            % Create an text box object 
            ann = nb_drawLine('xData',[0;1],'yData',[0;1],'units','normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addRegressionLinesAnnotation(obj,~,~)
        % Add rectangle/circle to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end

            % Create an text box object 
            ann = nb_regressLine();

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addDrawPatch(obj,hObject,~)
        % Add rectangle/circle to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            if strcmpi(get(hObject,'Label'),'circle')
                curvature = [1,1];
            else
                curvature = [0,0];
            end

            % Create an text box object 
            ann = nb_drawPatch(...
                    'position',[0.5,0.5 0.05 0.05],...
                    'units',   'normalized',...
                    'curvature',curvature);

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addArrow(obj,~,~)
        % Add arrow to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            % Create an default arrow object 
            ann = nb_arrow(...
                    'xData',   [0.5,0.6],...
                    'yData',   [0.5,0.6],...
                    'units',   'normalized');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        function addTextArrow(obj,~,~)
        % Add text arrow to the current graph

            if isempty(obj.DB)
                nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
                return
            end
        
            % Create an default arrow object 
            ann = nb_textArrow(...
                    'xData',   [0.5,0.6],...
                    'yData',   [0.5,0.6],...
                    'units',   'normalized',...
                    'string',  'Text');

            % Assign it to the plotter object
            old = obj.annotation;
            new = [old,{ann}];
            obj.annotation = new;
            obj.graph();
            
            % Notify listeners
            notify(obj,'updatedGraph');

        end
        
        varargout = addBarAnnotation(varargin)
        varargout = addColorBarAnnotation(varargin)
        varargout = addPlotLabelsAnnotation(varargin)
        varargout = applyTemplate(varargin)
        varargout = deleteBarAnnotation(varargin)
        varargout = getTemplateProperty(varargin)
        varargout = editBarAnnotation(varargin)
        varargout = editNotes(varargin)
        varargout = enableUIComponents(varargin)
        varargout = getCurrentTemplate(varargin)
        varargout = saveTemplate(varargin)
        varargout = updateLegendInformation(varargin)
        
    end

    methods(Access=protected)
        
        varargout = addAdvancedComponents(varargin)
        varargout = addAnnotation(varargin)
        varargout = addBaseLine(varargin)
        varargout = addFigureTitle(varargin)
        varargout = addHorizontalLine(varargin)
        varargout = addLegend(varargin)
        varargout = addPatch(varargin)
        varargout = addTitle(varargin)
        varargout = addXLabel(varargin)
        varargout = addYLabel(varargin)
        varargout = adjustFontSize(varargin)
        varargout = applyNotTickOptions(varargin)
        varargout = copySubplotCallback(varargin)
        varargout = getDataOfField(varargin)
        varargout = getLabelVariables(varargin) 
        varargout = interpretColorsProperty(varargin) 
        varargout = revertFontSize(varargin)
        varargout = scaleFontSize(varargin)
        varargout = setDefaultSettings(varargin)
        varargout = setFontSize(varargin)
        varargout = updateLabelIndices(varargin)
             
    end
    
%     methods (Static=true)
        
%         varargout = setOnePropHandle(varargin)
    
%     end

    methods (Static=true,Hidden=true)
        
        varargout = findClosestNiceNumber(varargin)        
        varargout = findVariableName(varargin)
        varargout = getTemplateProps(varargin)
        varargout = getDefaultTemplate(varargin)
        varargout = interpolateData(varargin)
        varargout = scaledata(varargin) 
        varargout = splitData(varargin)
        varargout = stripData(varargin)
        
        function dispMethods(className)
            
            disp(' ')
            disp(['The methods of the ' className ' class are:'])
            
            meths  = methods(className);
            hMeths = methods('handle');
            meths  = setdiff(meths,hMeths);
            for ii = 1:length(meths)
                disp(nb_createLinkToClassProperty(className,meths{ii}));
            end
            disp(' ');
            
        end
        
        function groups = dispTableGeneric()
            
            groups = {
                'Annotation properties:',   {'annotation','baseLine','baseLineColor','baseLineStyle',...
                                             'baseLineWidth','baseValue','horizontalLine','horizontalLineColor',...
                                             'horizontalLineStyle','horizontalLineWidth','patch','patchAlpha'}
                'Axes properties:',         {'alignAxes','addSpace','axesFontSize','axesFontSizeX','axesFast'...
                                             'axesFontWeight','axesLineWidth','axesPrecision','axesScaleLineWidth',...
                                             'axesScaleFactor','findAxisLimitMethod','grid','gridLineStyle',...
                                             'noTickMarkLabels','noTickMarkLabelsLeft','noTickMarkLabelsRight',...
                                             'position','shading'} 
                'Candle properties:',       {'candleIndicatorColor','candleIndicatorLineStyle','candleMarker',...
                                             'candleVariables','candleWidth'} 
                'Colors properties:',       {'colorOrder','colorOrderRight','colors'}
                'Data properties:',         {'factor'}
                'Figure properties:',       {'figureColor','figurePosition','figureName','figureTitle','plotAspectRatio'}
                'Font properties:',         {'fontName','fontScale','fontUnits','normalized'}
                'Label properties:',        {'noLabel','xLabel','xLabelAlignment','xLabelFontSize','xLabelFontWeight',...
                                             'xLabelInterpreter','xLabelPlacement','xTickLabels','yLabel',...
                                             'yLabelFontSize','yLabelFontWeight','yLabelInterpreter','yLabelRight'}
                'Legend properties:',       {'fakeLegend','legAuto','legBox','legColor','legColumns','legColumnWidth',...
                                             'legends','legendText','legFontColor','legFontSize','legInterpreter',...
                                             'legLocation','legPosition','legReorder','legSpace','noLegend'}
                'Plot properties:',         {'areaAbrupt','areaAccumulate','areaAlpha','barAlpha1','barAlpha2','barBlend',...
                                             'barLineWidth','barShadingColor','barShadingDirection','barWidth','lineStyles',...
                                             'lineWidth','lineWidths','markers','markerSize','sumTo','variablesToPlot',...
                                             'variablesToPlotRight'}   
                'Saving properties:',       {'a4Portrait','crop','fileFormat','flip','pdfBook','saveName'}
                'Title properties:',        {'noTitle','title','titleAlignment','titleFontSize','titleFontWeight',...
                                             'titleInterpreter','titlePlacement'}
            };
            
        end

        function groups = mergeDispTables(group1,group2)

            % Combine equal groups
            newGroup = false(size(group1,1),1);
            for ii = 1:size(group1,1)
                ind = strcmp(group1{ii,1},group2(:,1));
                if any(ind)
                    group2{ind,2} = unique([group1{ii,2},group2{ind,2}]);
                else
                    newGroup(ii) = true;
                end
            end

            % Merge all groups
            groups = [group1(newGroup,:);group2];

            % Sort by group names
            [~,sortInd] = sort(groups(:,1));
            groups      = groups(sortInd,:);

            % Sort each group
            for ii = 1:size(groups,1)
                groups{ii,2} = sort(groups{ii,2});
            end

        end
        
    end
    
    methods(Sealed=true)
        
        varargout = set(varargin)
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = helpFileCallback(varargin)
        
        varargout = setOnePropHandle(varargin)
        varargout = setPropChar2Cellstr(varargin)
        varargout = setPropCode(varargin)
        varargout = setPropColorOrder(varargin)
        varargout = setPropFigureHandle(varargin)
        varargout = setPropFontUnits(varargin)
        varargout = setPropGraphStruct(varargin)
        varargout = setPropGraphStyle(varargin)
        varargout = setPropLegColor(varargin)
        varargout = setPropLegends(varargin)
        varargout = setPropLegendText(varargin)
        varargout = setPropLocalVariables(varargin)
        varargout = setPropLookUpMatrix(varargin)
        varargout = setPropPage(varargin)
        varargout = setPropPlotType(varargin)
        
    end
    
end
