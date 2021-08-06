%% Get help on these examples

help nb_graph_ts
properties(nb_graph_ts)

% Help on a property
help nb_graph_ts.variablesToPlot

% Help on annotation classes
help nb_textBox
help nb_arrow
help nb_textArrow
help nb_drawLine
help nb_drawPatch
help nb_barAnnotation
help nb_regressLine
help nb_plotLabels

%% Adding a text box

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'Text box','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_textBox object
ann = nb_textBox('string','Some text','xData',1,'yData',0.7);

% Add the annotation object to the graph object
plotter.set('annotation',ann);
plotter.graph();


%% Adding a arrow

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'A arrow','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_arrow object
ann = nb_arrow('xData',[9,10],'yData',[0.7,0.5],'lineWidth',3);

% Add the annotation object to the graph object
plotter.set('annotation',ann);
plotter.graph();

%% Adding a arrow with text

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'Arrow with text','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_textArrow object
ann = nb_textArrow('string','Some text','xData',[9,10],...
                   'yData',[0.7,0.5],'lineWidth',3);

% Add the annotation object to the graph object
plotter.set('annotation',ann);
plotter.graph();

%% Adding a line

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'A line','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_drawLine object
ann = nb_drawLine('xData',[9,10,11,9,9],...
                  'yData',[0.7,0.5,0.8,0.5,0.5],...
                  'lineWidth',3,'cData','green');

% Add the annotation object to the graph object
plotter.set('annotation',ann);
plotter.graph();

%% Adding a patch

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'A patch','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_drawPatch object
ann = nb_drawPatch('position',[9,.4,5,.5],...
                  'faceColor','green');

% Add the annotation object to the graph object
plotter.set('annotation',ann);
plotter.graph();

%% Adding text to a bar plot

obj = nb_ts(rand(8,2),'Bar annotation','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

ann = nb_barAnnotation('color',     'black',...
                       'decimals',  1,...
                       'location',  'top');

% Add the annotation object to the graph object
plotter.set('annotation',ann,'plotType','grouped','yLim',[0,1.5]);
plotter.graph();

%% Adding more annoations at a time

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'A line','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);

% Initializing an nb_textBox object
ann2 = nb_textBox('string','Some text','xData',1,'yData',0.7);

% Initializing an nb_drawLine object
ann1 = nb_drawLine('xData',[9,10,11,9,9],...
                   'yData',[0.7,0.5,0.8,0.5,0.5],...
                   'lineWidth',3,'cData','green');

% Add the annotation object to the graph object
plotter.set('annotation',{ann1,ann2});
plotter.graph();


%% Adding annotation to an object of class nb_axes

ax  = nb_axes();
ann = nb_textBox('string','Some text','xData',0.5,'yData',0.7);
ann.set('parent',ax);

%% Adding annotation after the graph method is called
% This method will not be saved in the nb_graph_ts object, and is therefore
% not preferred!

obj = nb_ts([ones(10,2)*0.5;rand(10,2)],'A line','2012Q1',...
            {'Var1','Var2'});        
plotter = nb_graph_ts(obj);
plotter.graph
ax  = get(plotter,'axesHandle');
ann = nb_textBox('string','Some text','xData',1,'yData',0.7);
set(ann,'parent',ax);

