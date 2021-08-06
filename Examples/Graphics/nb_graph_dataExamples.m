%% Get help on this example

help nb_graph_data
properties(nb_graph_data)

%% Intializing an object of class nb_graph_data

% Reading data from a excel spreadsheet
data = nb_data('example_data_mat');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_data(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('title','test','titleFontSize',14);

% Plot the object
plotter.graph

%% Save the figure down to pdf

data = nb_data('example_data');
plotter = nb_graph_data(data);
plotter.set('title','test','titleFontSize',14);

% Set the saveName property to save it to a pdf
plotter.set('saveName','simpleFigure','crop',1,...
            'figurePosition',[40   15  186.4   43]);

% Plot the object
plotter.graph

%% Set the plot type

% Adding data to an object of class nb_data
data    = nb_data.rand(2,2,2,1);

% Initialize an nb_graph_data object with the above data
plotter = nb_graph_data(data);

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

data = nb_data([1,2,3,4,2.9;1,2,3,4,2.5;1,2,3,4,2.5],'',...
             1,{'var1','var2','var3','var4','var5'});
plotter = nb_graph_data(data);

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

data = nb_data(rand(10,4),'',1,{'var1','var2','var3','var4'});

plotter = nb_graph_data(data);

% Set the scatter group
plotter.set('plotType',         'scatter',...
            'legends',          'Scatter group',...
            'scatterObs',       {'ScatterGroup',{1,5}},...
            'scatterVariables', {'var1','var4'});
plotter.graph()

% Plot two scatter groups
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterObs',       {'ScatterGroup1',{1,5},...
                                 'ScatterGroup2',{6,10}},...
            'scatterVariables', {'var1','var4'});
plotter.graph()

% Set x-limits (Which is only possible when plotType is set to
% 'scatter')
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterObs',       {'ScatterGroup1',{1,5},...
                                 'ScatterGroup2',{6,10}},...
            'scatterVariables', {'var1','var4'},...
            'xLim',             [0,1],...
            'yLim',             [0,1],...
            'markers',          {'ScatterGroup2','s'},...
            'colors',           {'ScatterGroup1','blue','ScatterGroup2','red'});
plotter.graph()

% Plot two scatter groups against different axes
plotter.set('plotType',                 'scatter',...
            'legends',                  {'Scatter group 1',...
                                         'Scatter group 2'},...
            'scatterObs',               {'ScatterGroup',...
                                         {1,5}},...
            'scatterObsRight',          {'ScatterGroup',...
                                         {6,10}},...
            'scatterVariables',         {'var1','var4'},...
            'scatterVariablesRight',    {'var1','var2'});
        
plotter.graph()


%% Save the data of the graph

% Reading data from a excel spreadsheet
data = nb_data('example_data.xlsx');

% Initialize an nb_graph_data object with the above data
plotter = nb_graph_data(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('variablesToPlot',{'Var1','Var2'},...
            'startGraph',3);

% Plot the object
plotter.graph

% Save the data of the plot to a excel file
plotter.saveData('test');

%% Change the legend

% Reading data from a excel spreadsheet
data = nb_data('example_data_mat');

% Initialize an nb_graph_data object with the above data
plotter = nb_graph_data(data);

% Set the text of the legend
plotter.set('legends',{'First','Second','Third'});

% Set the legend position
plotter.set('legPosition',[0.25 0.4],'legColumns',3); %

% Plot the object
plotter.graph


%% Add labels

% Adding data to an object of class nb_data
data    = nb_data([2,2;1,3;3,2],'',1,{'Var1','Var2'});

% Initialize an nb_graph_data object with the above data
plotter = nb_graph_data(data);

% Add a x-axis label
plotter.set('xLabel','x-axis');

% Add a y-axis label left
plotter.set('yLabel','y-axis left');

% Add a y-axis label right
plotter.set('yLabelRight','y-axis right');

% Plot the object
plotter.graph


%% Set the spacing between the x-axis tick mark labels

data    = nb_data(rand(40,2),'',1,{'Var1','Var2'});
plotter = nb_graph_data(data);

% Uses the property spacing to do this
plotter.set('spacing',4);

% Graph
plotter.graph


%% Set the x-axis tick marks start date

data    = nb_data(rand(40,2),'',1,{'Var1','Var2'});
plotter = nb_graph_data(data);

% Uses the property xTickStart to do this
plotter.set('xTickStart',2,'spacing',4);

% Graph
plotter.graph


%% Set the graph style of the plotted figures

% Example 1
data    = nb_data([2,2;-1,3;3,-2;3,4;-2,3;1,2],'',1,...
                {'Var1','Var2'});
plotter = nb_graph_data(data);

% Set the graphStyle property to do this ('mpr' is a predefined
% graph style)
plotter.set('graphStyle','mpr');
plotter.graph

% Example 2
data    = nb_data([2,2;-1,3;3,-2;3,4;-2,3;1,2],'',1,...
                {'Var1','Var2'});
plotter = nb_graph_data(data);

% Set the graphStyle property to do this. Now using a .m file.
% You can not add the extension!
plotter.set('graphStyle','exampleStyleFileData');
plotter.graph()


%% Add a horizontal line spanning the whole figure

data    = nb_data(rand(36,2)*3,'',1,{'Var1','Var2'});
plotter = nb_graph_data(data);

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

data    = nb_data(rand(36,2)*3,'',1,{'Var1','Var2'});
plotter = nb_graph_data(data);

% Set some properties of the graph to create a vertical line
plotter.set('verticalLine',       {20},...
            'verticalLineColor',  'black',...
            'verticalLineStyle',  '-',...   
            'verticalLineWidth',  1);
                      
plotter.graph()

% Set some properties of the graph to create more vertical lines
plotter.set('verticalLine',       {20,35.5},...
            'verticalLineColor',  {'orange','blue'},...
            'verticalLineStyle',  {'-','--'},...   
            'verticalLineWidth',  1);

plotter.graph()

%% Add highlighted area(s) behind the plotted variables

data    = nb_data(rand(36,2)*3,'',1,{'Var1','Var2'});
plotter = nb_graph_data(data);

% Set some properties of the graph to create one highlighted area
plotter.set('highlight',          {4,10},...
            'highlightColor',     {'orange'});

plotter.graph()        
        
% Set some properties of the graph to create more highlighted areas
plotter.set('highlight',          {{4,10},...
                                   {12.5,16}},...
            'highlightColor',     {'orange','light blue'});

plotter.graph()


%% Plot against two different axes (left and right)

data    = nb_data([rand(10,1)*2, rand(10,2), rand(10,1)*2],'','2012',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

% Set which variables to plot against which axes
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'variablesToPlotRight', {'Var2','Var3'})

plotter.graph()        
        
%% Set the colors of the variables

data    = nb_data([rand(10,1)*2, rand(10,2), rand(10,1)*2],'',1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

% Using color names (colors property overload the colorOrder 
% property)
plotter.set('variablesToPlot',  {'Var1','Var4'},...
            'colors',           {'Var1','purple','Var4','green'});

plotter.graph()

% Using RGB colors
plotter = nb_graph_data(data);
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

data    = nb_data([rand(10,1)*2, rand(10,2), rand(10,1)*2],'',1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

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

%% Use a variable as the x-axis ticker

data    = nb_data(rand(40,3),'',1,{'Var1','Var2','Var3'});
plotter = nb_graph_data(data);

% Uses the property xTickStart to do this
plotter.set('variablesToPlot',{'Var2','Var3'},...
            'variableToPlotX','Var1');

% Graph
plotter.graph

%% The graphSubPlots method

% One paged data
data    = nb_data(rand(20,4),'Data1',1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

% Two paged data
data    = nb_data(rand(20,4,2),{'Data1','Data2'},1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

% Bars at end
data    = nb_data(rand(150,4),'Data1',1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);
plotter.set('lineStop',40,'barPeriods',[50,100,150]);
plotter.graphSubPlots();
% nb_graphSubPlotGUI(plotter)

%% The graphInfoStruct method

% Two paged data
data    = nb_data(rand(20,4,2),{'Data1','Data2'},1,...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_data(data);

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
