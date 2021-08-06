%% Get help on this example

help nb_graph_subplot
properties(nb_graph_subplot)


%% Graph more nb_graph objects in one figure

% Create objects of the subplots
data1    = nb_ts([2,2,2;1,3,2;3,2,2],'','2012',{'Var1','Var2','Var3'});
plotter1 = nb_graph_ts(data1);
plotter1.set('legPosition',[0.4 0.45],'xLabel','x-axis');

data2    = nb_ts([2,2,2;1,3,2;3,2,2],'','2012',{'Var1','Var2','Var3'});
plotter2 = nb_graph_ts(data2);

data3    = nb_cs([2,2,2;1,3,2;3,2,2],'',{'type1','type2','type3'},...
                 {'Var1','Var2','Var3'});
plotter3 = nb_graph_cs(data3);

data4    = nb_cs([2,2,2;1,3,2;3,2,2],'',{'type1','type2','type3'},...
                 {'Var1','Var2','Var3'});
plotter4 = nb_graph_cs(data4);

% Initialize the nb_graph_subplot object
plotter = nb_graph_subplot(plotter1,plotter2,plotter3,plotter4);

% Graph the figure
plotter.graph();

%% Save the figure to pdf

plotter.set('saveName','test','graphStyle','mpr');

% Graph the figure
plotter.graph();


%% Save the data to excel

plotter.saveData();
