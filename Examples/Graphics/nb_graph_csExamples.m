%% Get help on this example

help nb_graph_cs
properties(nb_graph_cs)

%% Intializing an object of class nb_graph_cs 

% Reading data from a excel spreadsheet to construct a nb_cs object
data = nb_cs('example_cs_mat');

% Initialize a nb_graph_cs object
plotter = nb_graph_cs(data)

% Set one property of an nb_graph_cs object
plotter.set('title','A title');

% Set more properties of an object of class nb_graph_cs
plotter.set('title','A title','titleFontSize',14);

% Graph an obejct of class nb_graph_cs
plotter.graph

%% Line plot

data    = nb_cs([2,2;1,3;3,2],'',{'type1','type2','type3'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.graph();

%% Area plot

data    = nb_cs([2,2;1,3;3,2],'',{'type1','type2','type3'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('plotType','area');
plotter.graph();

%% Stacked bar plot

data    = nb_cs([2,2;1,3;3,2],'',{'type1','type2','type3'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('plotType','stacked');
plotter.graph();

%% Grouped bar plot

data    = nb_cs([2,2;1,3;3,2],'',{'type1','type2','type3'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('plotType','grouped');
plotter.graph();


%% Horizontal stacked bar plot

data    = nb_cs([2,2;1,3;3,2],'',{'type1','type2','type3'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('plotType','stacked','barOrientation','horizontal');
plotter.graph();

%% Pie plot

data    = nb_cs([2,2,3,2],'',{'type1'},...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_cs(data);
plotter.set('plotType','pie','pieAxisVisible','off',...
            'pieOrigoPosition',[-0.7,0],...
            'pieEdgeColor','w');
plotter.graph();

%% Donut plot

data    = nb_cs([2,2,3,2;1,2,3,1],'',{'type1','type2'},...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_cs(data);
plotter.set('plotType','donut','pieAxisVisible','off',...
            'pieOrigoPosition',[-0.7,0],'lineWidth',1,...
            'pieEdgeColor','w');
plotter.graph();

data    = nb_cs([2,2,3,2],'',{'type1'},...
                {'Var1','Var2','Var3','Var4'});
plotter = nb_graph_cs(data);
plotter.set('plotType','donut','pieAxisVisible','off',...
            'pieExplode',{'Var1'},...
            'pieEdgeColor','w');
plotter.graph();


%% Radar plot

data    = nb_cs([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],'',...
                {'type1','type2','type3','type4','type5','type6'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('plotType','radar');%
plotter.graph();

%% Candle plot

data = nb_cs([1,2,3,4,2.5;1,2,3,4,2.5;1,2,3,4,2.5],'',...
  {'type1','type2','type3'},{'var1','var2','var3','var4','var5'});
plotter = nb_graph_cs(data);

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

%% Image plot where the data of the object is mapped to the color map

data    = nb_cs.rand(5,5);
plotter = nb_graph_cs(data);
plotter.set('plotType','image','annotation',nb_colorbar);
plotter.graph();


%% Scatter plot

data = nb_cs(rand(2,10),'',{'type1','type2'},{'var1','var2',...
    'var3','var4','var5','var6','var7','var8','var9','var10'});

plotter = nb_graph_cs(data);
plotter.set('plotType','scatter');
plotter.graph()

% Set the scatter group
plotter.set('plotType',         'scatter',...
            'legends',          'Scatter group',...
            'scatterVariables', {'scatterGroup1',{'var1','var2',...
                                 'var3','var4','var5'}},...
            'scatterTypes',     {'type1','type2'});
plotter.graph()

% Plot two scatter groups
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterVariables', {'scatterGroup1',{'var1','var2',...
                                 'var3','var4','var5'},...
                                 'scatterGroup2',{'var6','var7',...
                                 'var8','var9','var10'}},...
            'scatterTypes',     {'type1','type2'});
plotter.graph()

% Set x-limits (Which is only possible when plotType is set to
% 'scatter')
plotter.set('plotType',         'scatter',...
            'legends',          {'Scatter group 1',...
                                 'Scatter group 2'},...
            'scatterVariables', {'scatterGroup1',{'var1','var2',...
                                 'var3','var4','var5'},...
                                 'scatterGroup2',{'var6','var7',...
                                 'var8','var9','var10'}},...
            'scatterTypes',     {'type1','type2'},...
            'xLim',             [0,1],...
            'yLim',             [0,1]);
plotter.graph()

% Plot two scatter groups against different axes
plotter.set('plotType',                 'scatter',...
            'legends',                  {'Scatter group 1',...
                                         'Scatter group 2'},...
            'scatterVariables',         {'scatterGroup1',{'var1',...
                                         'var2','var3','var4',...
                                         'var5'}},...
            'scatterVariablesRight',    {'scatterGroup1',{'var6',...
                                         'var7','var8','var9',...
                                         'var10'}},...
            'scatterTypes',             {'type1','type2'},...
            'scatterTypesRight',        {'type1','type2'});
        
plotter.graph()

%% Save data of the plot

data    = nb_cs([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],'',...
                {'type1','type2','type3','type4','type5','type6'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);
plotter.set('variablesToPlot',{'Var1'},'typesToPlot',{'type1','type2'});
plotter.graph();

% Save the data of the plot to a excel file
plotter.saveData('test')

%% Too long type names

% Using the xTickLabels property
data    = nb_cs([1,2; 2,4; 3,5; 2,1; 3,4; 2,5; 4,5; 3,4],'',...
                {'type1','type2','A too long type name',...
                 'Another too long type name','type5','type6',...
                 'type7','type8'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);

% Now the x-axis tick mark labels will overlap
plotter.set('axesFontSize',16);
plotter.graph

plotter.set('xTickLabels',{'A too long type name',...
                           char('A too long','type name'),...
                           'Another too long type name',...
                           char('Another too long','   type name')});
plotter.graph
                       
% Using the lookUpMatrix
data    = nb_cs([1,2; 2,4; 3,5; 2,1; 3,4; 2,5; 4,5; 3,4],'',...
                {'type1','type2','A too long type name',...
                 'Another too long type name','type5','type6',...
                 'type7','type8'},...
                {'Var1','Var2'});
plotter = nb_graph_cs(data);

% Now the x-axis tick mark labels will overlap
plotter.set('axesFontSize',16);

% Set the lookUpMatrix property to make the x-axis tick mark labels
% multi-lined
s={'A too long type name',   char('A too long','type name'),''
'Another too long type name',char('Another too long','type name'),''};
 
plotter.set('lookUpMatrix',s);
plotter.graph

% Use a .m file instead
plotter.set('lookUpMatrix','lookUpMatrixExample');
plotter.graph

%% Add a horizontal line spanning the whole figure

data    = nb_cs(rand(3,2)*3,'',{'type1','type2','type3'},{'Var1','Var2'});
plotter = nb_graph_cs(data);

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

data    = nb_cs(rand(3,2)*3,'',{'type1','type2','type3'},{'Var1','Var2'});
plotter = nb_graph_cs(data);

% Set some properties of the graph to create a vertical line
plotter.set('verticalLine',       {'type2'},...
            'verticalLineColor',  'black',...
            'verticalLineStyle',  '-',...   
            'verticalLineWidth',  1);
                      
plotter.graph()

% Set some properties of the graph to create more vertical lines
plotter.set('verticalLine',       {'type2',{'type2','type3'}},...
            'verticalLineColor',  {'orange','blue'},...
            'verticalLineStyle',  {'-','--'},...   
            'verticalLineWidth',  1);

plotter.graph()

%% The method graphSubPlots

data = nb_cs(rand(3,3,3),'',{'type1','type2','type3'},...
                            {'var1','var2','var3'});
                        
plotter = nb_graph_cs(data);
plotter.graphSubPlots();
                        
                        
%% The method graphInfoStruct

data = nb_cs(rand(3,3,3),'',{'type1','type2','type3'},...
                            {'var1','var2','var3'});
                        
plotter = nb_graph_cs(data);

% Set up the graph settings
s = struct();
s.Example = {
'var1',      {'ylim', [-1 1],'ySpacing',1};
'var3*100',  {'yLabel','Prosent'};
'var3./var2',{'yLabel','Prosent','title','Expression (Var3./var2)'};
'var2',      {}};

% Set the graphStruct property
plotter.set('graphStruct',s);

% Graph all the variables stored in the data object in separate
% subplots
plotter.graphInfoStruct();

