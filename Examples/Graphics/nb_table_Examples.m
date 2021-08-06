%% Get help on this example

help nb_table
help nb_table_ts
help nb_table_cs
help nb_table_data
help nb_table_cell
properties(nb_graph_data)

%% nb_table

t = nb_table;
set(t,'Editing',true,'decimals',2)
plot(t);

%% Time-series table

data  = nb_ts.rand('2000',10,4);
table = nb_table_ts(data);
set(table,'fontSize',10,'lookUpMatrix',{'Var1','Test1','Test2'},...
          'title','Title','xLabel','Label')
graph(table)

s = struct(table);
t = nb_table_ts.unstruct(s);
graph(t)

%% Cross-sectional table

data  = nb_cs.rand(5,6);
table = nb_table_cs(data);
graph(table)

s = struct(table);
t = nb_table_cs.unstruct(s);
graph(t)

%% Data table

data  = nb_data.rand(1,10,4);
table = nb_table_data(data);
graph(table)

%% Cell table

data  = nb_data.rand(1,10,4);
data  = asCell(data);
table = nb_table_cell(data);
graph(table)

%% Include table in an nb_graph_adv

data  = nb_ts.rand('2000',10,4);
table = nb_table_ts(data);
set(table,'fontSize',10,'lookUpMatrix',{'Var1','Test1','Test2'})
plotterAdv = nb_graph_adv(table);
set(plotterAdv,'figureTitleEng','Something here...','footerEng','Footnote comes here...')
graphEng(plotterAdv)

%% Include table in package

graphNumber = 1;
chapter     = 1;

% Initialize a nb_graph_package object
package = nb_graph_package(graphNumber,chapter);

% Add the nb_graph_adv object to the nb_graph_package object
package.add(plotterAdv);

% Preview package
package.preview('english')
