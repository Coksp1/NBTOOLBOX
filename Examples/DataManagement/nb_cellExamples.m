%% Get help on this example

help nb_cell

%% Set the folder of the NB toolbox
% This must be updated!

folder = nb_folder();

%% nb_cell class

% Encapsulate a cell using the nb_cell class
r    = rand(4,4,2);
c    = num2cell(r);
data = nb_cell(c);

% Read from excel without link
data  = nb_cell('example_cs.xlsx')
dataU = data.update

% Read from excel with link
d  = nb_cell([folder '\Examples\DataManagement\example_cs.xlsx'])
du = d.update

%% Math operators on numerical elements

data1 = log(d);
data2 = update(data1)

%% Concatenation

r     = rand(4,4,2);
c     = num2cell(r);
data1 = nb_cell(c);
data2 = nb_cell(c);

data3 = [data1,data2];
data4 = [data1;data2];

%% Make table

t = nb_table_cell(data1);
t.graph
