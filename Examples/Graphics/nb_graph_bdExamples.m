%% Get help on this example

help nb_graph_bd
properties(nb_graph_bd)

%% Intializing an object of class nb_graph_ts

% Reading data from a excel spreadsheet
data = nb_bd('example_bd');

% Initialize an nb_graph_bd object with the above data
plotter = nb_graph_bd(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('title','test','titleFontSize',14,...
            'markers',{'Var1','x','Var2','x','Var3','x'});

% Plot the object
plotter.graph

% Pot full timespan
plotter.set('dataType','full');

% Plot the object
plotter.graph

%% Save the figure down to pdf

data    = nb_bd('example_bd_mat');
plotter = nb_graph_bd(data);
plotter.set('title','test','titleFontSize',14,...
            'figurePosition',[40   15  186.4   43],...
            'markers',{'Var1','x','Var2','x','Var3','x'});

% Set the saveName property to save it to a pdf
plotter.set('saveName','simpleFigure','crop',1);

% Plot the object
plotter.graph

%% Set the plot type

% Adding data to an object of class nb_ts
data    = nb_bd([2,2;1,nan;nan, nan;nan,2],'','2012',{'Var1','Var2'});

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_bd(data);

% Set the plotType to line
plotter.set('plotType','line','markers',{'Var1','x','Var2','x'});

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

data = nb_bd([1,2,3,4,2.9;1,2,3,4,2.5;1,2,3,4,2.5],'',...
             '2012',{'var1','var2','var3','var4','var5'});
plotter = nb_graph_bd(data);

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

data = nb_bd(rand(10,4),'','2010',{'var1','var2','var3','var4'});

plotter = nb_graph_bd(data);
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

%% Save the data of the graph

% Reading data from a mat file
data = nb_bd('example_bd_mat');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_bd(data);

% Set one property of the object
plotter.set('title','test');

% Set more properties of the object at one function call
plotter.set('variablesToPlot',{'Var1','Var2'},...
            'startGraph','2001Q1');

% Plot the object
plotter.graph

% Save the data of the plot to a excel file
plotter.saveData('test_bd')

%% Change the legend

% Reading data from a mat file
data = nb_bd('example_bd_mat');

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_bd(data);

% Set the text of the legend
plotter.set('legends',{'First','Second','Third'});

% Set the legend position
plotter.set('legPosition',[0.175 0.04],'legColumns',3); %

% Plot the object
plotter.graph


%% Add labels

% Adding data to an object of class nb_bd
data    = nb_bd([2,2;1,nan;nan,nan;nan,2;2,2;3,1],'','2012',{'Var1','Var2'});

% Initialize an nb_graph_ts object with the above data
plotter = nb_graph_bd(data);

% Add a x-axis label
plotter.set('xLabel','x-axis');

% Add a y-axis label left
plotter.set('yLabel','y-axis left');

% Add a y-axis label right
plotter.set('yLabelRight','y-axis right');

% Plot the object
plotter.graph


%% Set the spacing between the x-axis tick mark labels

data    = nb_bd(rand(40,2),'','2012Q1',{'Var1','Var2'});
plotter = nb_graph_bd(data);

% Uses the property spacing to do this
plotter.set('spacing',8);

% Graph
plotter.graph

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

d            = rand(36,2);
d(1:4:end,:) = nan;
d(35:36,2)   = nan;
data         = nb_bd(d,'','2008Q1',{'Var1','Var2'});
plotter      = nb_graph_bd(data);

% Set some properties of the graph to create a vertical line
plotter.set('verticalLine',       {'2012Q1'},...
            'verticalLineColor',  'black',...
            'verticalLineStyle',  '-',...   
            'verticalLineWidth',  1);
        
plotter.graph()

% Set some properties of the graph to create more vertical lines
plotter.set('verticalLine',       {'2012Q1','2014Q2'},...
            'verticalLineColor',  {'orange','blue'},...
            'verticalLineStyle',  {'-','--'},...   
            'verticalLineWidth',  1);

plotter.graph()

%% Add highlighted area(s) behind the plotted variables

d            = rand(36,2);
d(1:4:end,:) = nan;
d(35:36,2)   = nan;
data         = nb_bd(d,'','2008Q1',{'Var1','Var2'});
plotter      = nb_graph_bd(data);

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

% Generate data with missing observations
d            = rand(100,2);
d(2:7:end,:) = nan;
d(3:7:end,:) = nan;
d(75:76,2)   = nan;
data         = nb_bd(d,'','2019M3D1',{'Var1','Var2'});

% No interpolation
plotter = nb_graph_bd(data);
plotter.graph()

% Interpolate the missing observations
plotter.set('missingValues','interpolate');
plotter.graph()

%% Plot against two different axes (left and right)

data    = nb_bd([rand(10,1)*2, rand(10,2), rand(10,1)*2],'','2012',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_bd(data);

% Set which variables to plot against which axes
plotter.set('variablesToPlot',      {'Var1','Var4'},...
            'variablesToPlotRight', {'Var2','Var3'})

plotter.graph()        
        
%% Merging two nb_graph_ts objects 
% That uses the graph method

data     = nb_bd([2,2;1,3;3,2],'','2012',{'Var1','Var2'});
plotter1 = nb_graph_bd(data);
plotter1.graph()

data     = nb_bd([1,1.5;1,3;4,1.2],'','2011',{'Var3','Var4'});
plotter2 = nb_graph_bd(data);
plotter2.graph()

merged = merge(plotter1,plotter2,'graph');
merged.graph()

%% The graphSubPlots method

% One paged data
d          = rand(20,4);
d(4:4:end) = nan;
data       = nb_bd(d,'Data1','2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_bd(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

% Two paged data
d            = rand(20,4,2);
d(4:4:end,:) = nan;
data         = nb_bd(d,{'Data1','Data2'},'2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter      = nb_graph_bd(data);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphSubPlots();

%% The graphInfoStruct method

% Two paged data
d            = rand(20,4,2);
d(4:4:end,:) = nan;
data         = nb_bd(d,{'Data1','Data2'},'2012Q1',...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_bd(data);

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

%% Plot context data

d       = [1,2,NaN;NaN,8,9;10,11,12;6,7,4];
dates   = [nb_day(1,1,2018),nb_day(1,4,2018),nb_day(1,7,2018), nb_day(1,10,2018)];
vars    = {'Var1','Var3','Var2'};
sorted  = false;
data    = nb_bd.initialize(d,'',dates,vars,sorted);
plotter = nb_graph_bd(data);
plotter.set('dateFormat','vintage','markers',{'Var1','x','Var2','x','Var3','x'});
plotter.graph()
