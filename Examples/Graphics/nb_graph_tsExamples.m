%% Get help on this example

help nb_graph_ts
properties(nb_graph_ts)

%% Intializing an object of class nb_graph_ts

% Reading data from a excel spreadsheet
data = nb_ts('example_ts_quarterly');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('title','test','titleFontSize',14);

% Plot the object
plotter.graph

%% Save the figure down to pdf

data    = nb_ts('example_ts_quarterly');
plotter = nb_graph_ts(data);
plotter.set('title','test','titleFontSize',14,...
            'figurePosition',[40   15  186.4   43]);

% Set the saveName property to save it to a pdf
plotter.set('saveName','simpleFigure','crop',1);

% Plot the object
plotter.graph

%% Set the plot type

% Adding data to an object of class nb_ts
data    = nb_ts([2,2;1,3;3,2],'','2012',{'Var1','Var2'});

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Set the plotType to line
plotter.set('plotType','line');

% Plot the object
plotter.graph

% Set the plotType to stacked
plotter.set('plotType','stacked');

% Plot the object
plotter.graph

% Set the plotType to grouped
plotter.set('plotType','grouped');

% Plot the object
plotter.graph

% Set the plotType to dec
plotter.set('plotType','dec');

% Plot the object
plotter.graph

% Set the plotType to area
plotter.set('plotType','area');

% Plot the object
plotter.graph


%% Candle plot

data = nb_ts([1,2,3,4,2.9;1,2,3,4,2.5;1,2,3,4,2.5],'',...
             '2012',{'var1','var2','var3','var4','var5'});
plotter = nb_graph_ts(data);

plotter.set('candleVariables',{'close','var2','open','var3'},...
            'plotType',             'candle',...
            'yLim',                 [0 5]);
plotter.graph();        

plotter.set('candleVariables',{'low','var1','high','var4'},...
            'plotType',             'candle',...
            'yLim',                 [0 5]);
plotter.graph();   
        
plotter.set('candleVariables',{'low','var1','close','var2',...
            'open','var3','high','var4','indicator','var5'},...
            'plotType',             'candle',...
            'yLim',                 [0 5],...
            'legends',              {'Candle'});
plotter.graph();
        
plotter.set('candleVariables',{'low','var1','close','var2',...
            'open','var3','high','var4','indicator','var5'},...
            'plotType',             'candle',...
            'yLim',                 [0 5],...
            'legends',              {'Candle'},...
            'candleIndicatorColor', 'blue',...
            'colorOrder',           {'green'})
plotter.graph();  

%% Scatter plot

data = nb_ts(rand(10,4),'','2010',{'var1','var2','var3','var4'});

plotter = nb_graph_ts(data);
plotter.set('plotType','scatter');
plotter.graph()

% Set the scatter group
plotter.set('plotType',         'scatter',...
            'legends',          'Scatter group',...
            'scatterDates',     {'ScatterGroup',{'2012','2016'}},...
            'scatterVariables', {'var1','var4'});
plotter.graph()

% Plot two scatter groups
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterDates',     {'ScatterGroup1',{'2010','2014'},...
                                 'ScatterGroup2',{'2015','2019'}},...
            'scatterVariables', {'var1','var4'});
plotter.graph()

% Set x-limits (Which is only possible when plotType is set to
% 'scatter')
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterDates',     {'ScatterGroup1',{'2010','2014'},...
                                 'ScatterGroup2',{'2015','2019'}},...
            'scatterVariables', {'var1','var4'},...
            'xLim',             [0,1],...
            'yLim',             [0,1]);
plotter.graph()

% Plot two scatter groups against different axes
plotter.set('plotType',                 'scatter',...
            'legends',                  {'Scatter group 1',...
                                         'Scatter group 2'},...
            'scatterDates',             {'ScatterGroup',...
                                         {'2010','2014'}},...
            'scatterDatesRight',        {'ScatterGroup',...
                                         {'2015','2019'}},...
            'scatterVariables',         {'var1','var4'},...
            'scatterVariablesRight',    {'var1','var2'});
        
plotter.graph()

%% Dates vs dates plot

data    = nb_ts('example_ts_quarterly_mat');
plotter = nb_graph_ts(data);
plotter.set('datesToPlot',  {'2000Q1','2000Q2'},...
            'plotType',     'grouped');

% Plot the object
plotter.graph

%% Save the data of the graph

% Reading data from a excel spreadsheet
data = nb_ts('example_ts_quarterly_mat');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('variablesToPlot',{'Var1','Var2'},...
            'startGraph','2001Q1');

% Plot the object
plotter.graph

% Save the data of the plot to a excel file
plotter.saveData('test')

%% Change the legend

% Reading data from a excel spreadsheet
data = nb_ts('example_ts_quarterly_mat');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Set the text of the legend
plotter.set('legends',{'First','Second','Third'});

% Set the legend position
plotter.set('legPosition',[0.175 0.04],'legColumns',3); %

% Plot the object
plotter.graph


%% Add labels

% Adding data to an object of class nb_ts
data    = nb_ts([2,2;1,3;3,2],'','2012',{'Var1','Var2'});

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Add a x-axis label
plotter.set('xLabel','x-axis');

% Add a y-axis label left
plotter.set('yLabel','y-axis left');

% Add a y-axis label right
plotter.set('yLabelRight','y-axis right');

% Plot the object
plotter.graph


%% Set the spacing between the x-axis tick mark labels

data    = nb_ts(rand(40,2),'','2012Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property spacing to do this
plotter.set('spacing',8);

% Graph
plotter.graph

%% Set the x-axis tick mark labels frequency


data    = nb_ts(rand(40,2),'','2012Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property xTickFrequency to do this
plotter.set('xTickFrequency','yearly');

% Graph
plotter.graph

%% Set the x-axis tick marks start date

data    = nb_ts(rand(40,2),'','2012Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property xTickStart to do this
plotter.set('xTickStart','2012Q2','spacing',8);

% Graph
plotter.graph

%% Set how to interpreter the data,
% i.e. where to place the data points in relation to the tick mark labels.

% Adding data to an object of class nb_ts
data    = nb_ts([2,2;1,3;3,2;3,4;2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_ts(data);

% Uses the property dateInterpreter to do this (Either 'start',
% 'middel' or 'end')
plotter.set('dateInterpreter','middle');

% Graph
plotter.graph

%% Set the location of the x-axis tick mark labels

data    = nb_ts([2,2;-1,3;3,-2;3,4;-2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property xTickLabelAlignment to do this.
plotter.set('dateInterpreter',      'middle',...
             'plotType',            'grouped',...
             'xTickLabelAlignment', 'middle');

% Graph
plotter.graph

%% Set the location of the x-axis tick marks

data    = nb_ts([2,2;-1,3;3,-2;3,4;-2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property xTickLocation to do this
plotter.set('dateInterpreter',      'middle',...
            'plotType',             'grouped',...
            'xTickLabelAlignment',  'middle',...
            'xTickLocation',        0);

% Graph
plotter.graph

%% Set the location of the x-axis tick mark labels

data    = nb_ts([2,2;-1,3;3,-2;3,4;-2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});
plotter = nb_graph_ts(data);

% Uses the property xTickLabelLocation to do this.
plotter.set('dateInterpreter',      'middle',...
            'plotType',             'grouped',...
            'xTickLabelAlignment',  'middle',...
            'xTickLocation',        0,...
            'xTickLabelLocation',   'baseline');

% Graph
plotter.graph



%% Set the graph style of the plotted figures

% Example 1
data    = nb_ts([2,2;-1,3;3,-2;3,4;-2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set the graphStyle property to do this ('mpr' is a predefined
% graph style)
plotter.set('graphStyle','mpr');
plotter.graph

% Example 2
data    = nb_ts([2,2;-1,3;3,-2;3,4;-2,3;1,2],'','2012Q1',...
                {'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set the graphStyle property to do this. Now using a .m file.
% You can not add the extension!
plotter.set('graphStyle','exampleStyleFile');
plotter.graph()

%% Adding a fake legend

data    = nb_ts(rand(36,2),'','2008Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set some properties of the graph
plotter.set('lineStyles',{'Var1',{'-','2012Q1','--'},...
                          'Var2',{'-','2012Q1','--'}},...
            'colorOrder',{'green','orange'},...
            'legends',   {'Var 1','Var 2','','','Anslag'},...
            'fakeLegend',{'Anslag',...
                          {'cData','black','lineStyle','--'}},...
            'yLim',       [0 1]);
                      
plotter.graph()

%% Add a horizontal line spanning the whole figure

data    = nb_ts(rand(36,2)*3,'','2008Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set some properties of the graph to create a horizontal line
plotter.set('horizontalLine',       2,...
            'horizontalLineColor',  'black',...
            'horizontalLineStyle',  '-',...   
            'horizontalLineWidth',  1);
                      
plotter.graph()

% Set some properties of the graph to create more horizontal lines
plotter.set('horizontalLine',       [2,       2.5],...
            'horizontalLineColor',  {'orange','blue'},...
            'horizontalLineStyle',  {'-','--'},...   
            'horizontalLineWidth',  1);

plotter.graph()

%% Add a vertical line spanning the whole figure

data    = nb_ts(rand(36,2)*3,'','2008Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set some properties of the graph to create a vertical line
plotter.set('verticalLine',       {'2012Q1'},...
            'verticalLineColor',  'black',...
            'verticalLineStyle',  '-',...   
            'verticalLineWidth',  1);
                      
plotter.graph()

% Set some properties of the graph to create more vertical lines
plotter.set('verticalLine',       {'2012Q1',{'2014Q1','2014Q2'}},...
            'verticalLineColor',  {'orange','blue'},...
            'verticalLineStyle',  {'-','--'},...   
            'verticalLineWidth',  1);

plotter.graph()

%% Add highlighted area(s) behind the plotted variables

data    = nb_ts(rand(36,2)*3,'','2008Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

% Set some properties of the graph to create one highlighted area
plotter.set('highlight',          {'2012Q1','2014Q1'},...
            'highlightColor',     {'orange'});

plotter.graph()        
        
% Set some properties of the graph to create more highlighted areas
plotter.set('highlight',          {{'2011Q1','2012Q1'},...
                                   {'2013Q1','2014Q1'}},...
            'highlightColor',     {'orange','light blue'});

plotter.graph()

%% How to interpret missing data

% Generate data with missing observations (Only workdays)
data            = nb_ts.rand('2019M3D1',100,1);
data(2:7:end,:) = nan;
data(3:7:end,:) = nan;

% No interpolation
plotter = nb_graph_ts(data);
plotter.graph()

% Interpolate the missing observations
plotter.set('missingValues','interpolate');
plotter.graph()

% Strip the missing observations
plotter.set('missingValues','strip');
plotter.graph()

%% Merging data with different frequency 
% and strip the data of the highest frequency

% Generate data with missing observations (Only workdays)
dataDaily            = nb_ts.rand('2016M3D1',1000,1);
dataDaily(2:7:end,:) = nan;
dataDaily(3:7:end,:) = nan;

% Add some artificial forecast
dataQuarterly = nb_ts(rand(3,1),'','2019Q1',{'Var1'});
data          = dataDaily.merge(dataQuarterly);

plotter = nb_graph_ts(data);

% Interpolate the missing observations works fine
plotter.set('missingValues','interpolate');
plotter.graph()

% Strip the missing observations does not
plotter.set('missingValues','strip');
plotter.graph()

% Solution use the 'both' option in combined with the stopStrip 
% command
plotter.set('missingValues','both','stopStrip','2018M11D25');
plotter.graph()

%% Remove observation (not stripped though)

data    = nb_ts(rand(12,2)*3,'','2008Q1',{'Var1','Var2'});
plotter = nb_graph_ts(data);

plotter.set('nanVariables',       {'Var1',{'before','2009Q1'}});                   
plotter.graph()

plotter.set('nanVariables',       {'Var1',{'after','2009Q1'}});                   
plotter.graph()

plotter.set('nanVariables',       {'Var1',{'between','2009Q1','2009Q4'}});                   
plotter.graph()

plotter.set('nanVariables',       {'Var1',{'beforeAndAfter',...
                                           '2009Q1','2009Q4'}});                   
plotter.graph()

plotter.set('nanVariables',       {'Var1',{'ind',...
                                           {'2009Q1','2009Q4'}}});                   
plotter.graph()

%% Creating a fan chart

% Creating some artificial data
data     = nb_ts([ones(20,1,100);ones(16,1,100)*0.5 + rand(16,1,100)],'','2008Q1','Var1');

% Get the mean (which must be given to the nb_graph_ts constructor)
meanData = mean(data,'nb_ts',3);
meanData = meanData.window('','',{},1);
plotter = nb_graph_ts(meanData);

% Set the fanDatasets property
plotter.set('fanDatasets',data);

% Graph the fan chart
plotter.graph();

%% Add a fan legend to the fan chart

% Creating some artificial data
data     = nb_ts([ones(20,1,100);ones(16,1,100)*0.5 + rand(16,1,100)],'','2008Q1','Var1');

% Get the mean (which must be given to the nb_graph_ts constructor)
meanData = mean(data,'nb_ts',3);
meanData = meanData.window('','',{},1);
plotter = nb_graph_ts(meanData);

% Set the fanDatasets property
plotter.set('fanDatasets', data,...
            'fanLegend',   1,...
            'fanLegendLocation', [0.3,0.7]);

% Graph the fan chart
plotter.graph();

%% Plot against two different axes (left and right)

data    = nb_ts([rand(10,1)*2, rand(10,2), rand(10,1)*2],'','2012',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Set which variables to plot against which axes
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'variablesToPlotRight', {'Var2','Var3'})

plotter.graph()        
        
%% Set the colors of the variables

data    = nb_ts([rand(10,1)*2, rand(10,2), rand(10,1)*2],'','2012',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Using color names (colors property overload the colorOrder 
% property)
plotter.set('variablesToPlot',  {'Var1','Var4'},...
            'colors',           {'Var1','purple','Var4','green'});

plotter.graph()

% Using RGB colors
plotter = nb_graph_ts(data);
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'colorOrder',           [100, 234, 78; 34, 56, 76]/255);

plotter.graph()

% When plotting variables against two axes
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'colorOrder',           {'purple','green'},...
            'variablesToPlotRight', {'Var2','Var3'},...
            'colorOrderRight',      {'red','light blue'});
plotter.graph()
        
        
% or (which is prefered)        
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'variablesToPlotRight', {'Var2','Var3'},...
            'colors',               {'Var1','purple',...
                                     'Var4','green',...
                                     'Var2','red',...
                                     'Var3','light blue'}); 

plotter.graph()

%% Set the y-axis properties

data    = nb_ts([rand(10,1)*2, rand(10,2), rand(10,1)*2],'','2012',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Plot some variables and set the y-axis limits (Here you will
% set the limits of both the left and right y-axis.)
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'yLim',                 [0,2],...
            'ySpacing',             0.5);

plotter.graph()


% Set which variables to plot against which axes and set the
% y-axis limits
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'yLim',                 [0,2],...
            'ySpacing',             0.5,...
            'variablesToPlotRight', {'Var2','Var3'},...
            'yLimRight',            [0,1],...
            'ySpacingRight',        0.25);

plotter.graph()

% Set which variables to plot against which axes, set the
% y-axis limits and set the direction
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'yLim',                 [0,2],...
            'ySpacing',             0.5,...
            'yDir',                 'reverse',...
            'variablesToPlotRight', {'Var2','Var3'},...
            'yLimRight',            [0,1],...
            'ySpacingRight',        0.25);

plotter.graph()

%% Merging two nb_graph_ts objects 
% That uses the graph method

data    = nb_ts([2,2;1,3;3,2],'','2012',{'Var1','Var2'});
plotter1 = nb_graph_ts(data);
plotter1.graph()

data     = nb_ts([1,1.5;1,3;4,1.2],'','2011',{'Var3','Var4'});
plotter2 = nb_graph_ts(data);
plotter2.graph()

merged = merge(plotter1,plotter2,'graph');
merged.graph()

%% The graphSubPlots method

% One paged data
data    = nb_ts(rand(20,4),'Data1','2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

% Two paged data
data    = nb_ts(rand(20,4,2),{'Data1','Data2'},'2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

%% The graphInfoStruct method

% Two paged data
data    = nb_ts(rand(20,4,2),{'Data1','Data2'},'2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_ts(data);

% Set up the graph settings
s = struct();
s.Example = {
'Var1',      {'ylim', [-1 1],'ySpacing',1};
'Var3*100',  {'yLabel','Prosent'};
'Var3./Var4',{'yLabel','Prosent','title','Expression (Var3./Var4)'};
'Var3',      {}};

s.Example2 = {
'Var1',      {'ylim', [-1 1],'ySpacing',1};
'Var3*100',  {'yLabel','Prosent'};
'Var3./Var4',{'yLabel','Prosent','title','Expression (Var3./Var4)'};
'Var3',      {}};

% Set the graphStruct property
plotter.set('graphStruct',s);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphInfoStruct();

% Using a .m file instead
plotter.set('graphStruct','graphInfoFile');

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphInfoStruct();
