% Help on these examples

help nb_figure
help nb_axes

% Same syntax for all the other classes used

%% Initialize a figure

f = nb_figure('name','An example');

%% Initialize an axes to plot on

% Creates a new figure
ax = nb_axes();

% Creates a new axes in the given figure
ax = nb_axes('parent',f);

%% Radar plot

% Plot on a new figure and new axes 
radar = nb_radar([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],'numberOfIsoLines',...
                 10);

% Plot on a given axes handle
ax    = nb_axes;
radar = nb_radar([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],'numberOfIsoLines',...
                 10,'parent',ax);

% plot on a given axes in a given figure
f     = nb_figure();
ax    = nb_axes('parent',f);
radar = nb_radar([1,2; 2,4; 3,5; 2,1; 3,4; 2,5],'numberOfIsoLines',...
                 10,'parent',ax);

%% Plotting bars

d   = rand(10,2);
bar = nb_bar(d,'style','grouped');

%% Get the parent (which is an nb_axes handle)

ax = bar.parent;

% or

ax = get(bar,'parent');

%% Set position of axes

set(ax,'position',[0.1,0.15,0.8,0.75])

%% Adding a title   

tit = nb_title(ax,'A title');

%% Adding a x-axis label

xlab = nb_xlabel(ax,'x-axis');

%% Adding a y-axis label

ylabLeft  = nb_ylabel(ax,'y-axis');
ylabRight = nb_ylabel(ax,'y-axis','side','right');

%% Adding a legend

leg = nb_legend(ax,{'Var1','Var2'});


%% Adding a base line

horLine = nb_horizontalLine(0.5,'parent',ax);

%% Adding a vertical line

verLine = nb_verticalLine(8,'parent',ax);

%% Adding a highlighted area

hl = nb_highlight([3,4],'parent',ax);

%% Plot a line on the same axes

line = nb_plot(rand(10,1),'parent',ax,'cData','green');

%% Fan chart with fan legend

fan = nb_fanChart([ones(20,100)*0.5;rand(10,100)],'cData','grey');
leg = nb_fanLegend(fan.parent,{},'location','outside');%[0.2 0.3]

%% Line plot

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.2;
h      = nb_plot(d);
func   = @(src,event)nb_displayValue(src,event,{'Var1','Var2'});
addlistener(h.parent,'mouseOverObject',func);

%% Scatter plot

d1     = rand(5,2);
d2     = rand(5,2);
h      = nb_scatter(d1,d2);
func   = @(src,event)nb_displayValue(src,event,...
            {{'Var1,Var2','Var3,Var4'}},{{'Obs1','Obs2','Obs3','Obs4','Obs5'}});
addlistener(h.parent,'mouseOverObject',func);

%% Bar plot
% Grouped

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
bar    = nb_bar(d,'style','grouped');
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(bar.parent,'mouseOverObject',func);

%% Bar plot
% Stacked

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
bar    = nb_bar(d,'style','stacked','lineStyle','none');
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(bar.parent,'mouseOverObject',func);

%% Area plot

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
a      = nb_area(d);
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(a.parent,'mouseOverObject',func);

%% Area plot

d = rand(10,2);
a = nb_area(d,'faceAlpha',0.5,'accumulate',false,'lineWidth',2.5);

%% Horizontal bar plot

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
bar    = nb_hbar(d,'style','grouped');
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(bar.parent,'mouseOverObject',func);

%% Plot combinations

d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
h      = nb_plotComb(d,'types',{'grouped','line'});
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(h.parent,'mouseOverObject',func);

%% Subplots

f   = nb_figure();

ax1    = nb_axes('position',[0.1,0.25,0.35,0.5],'parent',f);
d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
bar1   = nb_bar(d,'style','grouped','parent',ax1);
func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
addlistener(ax1,'mouseOverObject',func);

ax2    = nb_axes('position',[0.55,0.25,0.35,0.5],'parent',f);
d      = rand(10,2);
d(2,2) = -0.2;
d(2,1) = -0.1;
bar2   = nb_bar(d,'style','grouped','parent',ax2);
func   = @(src,event)nb_displayValue(src,event,{{'Var3','Var4'}});
addlistener(ax2,'mouseOverObject',func);

%% Add labels

d      = rand(10,3);
d(2,2) = -0.2;
d(2,1) = -0.1;
h      = nb_plotComb(d,'types',{'line','stacked','stacked'});
l      = nb_plotLabels('parent',h.parent);

%% Pie plot

d = rand(10,1);
a = nb_pie(d,'origoPosition',[-0.5,0],'axisVisible','off',...
             'edgecolor','none');

%% Donut plot

d = rand(3,5);
a = nb_donut(d,'axisVisible','off','edgecolor','white');

%% Image with a color bar

ax = nb_axes('yTickLabelRight',{''});
im = nb_image(rand(5,5)*2,'parent',ax);
cb = nb_colorbar('parent',ax);

%% Graded fan chart with color bar

ax  = nb_axes('yTickLabelRight',{''},'colorMap',rand(4,3));
fan = nb_gradedFanChart([ones(20,100)*0.5;rand(10,100)],'parent',ax);
cb  = nb_colorbar('parent',ax);

%% Graded fan chart with color bar
% Using color map from file

ax  = nb_axes('yTickLabelRight',{''},'colorMap','colorMapNB.mat');
fan = nb_gradedFanChart([ones(20,100)*0.5;rand(10,100)],'parent',ax);
cb  = nb_colorbar('parent',ax,'direction','reverse','space',0);

%% Graded fan chart
% Lower and upper bound only. 

ax  = nb_axes('yTickLabelRight',{''});
fan = nb_gradedFanChart([ones(20,2)*0.5;sort(rand(10,2),2)],'parent',ax);

%% Place legend outside axes and resize axes to get room for legend

f   = nb_figure();
ax  = nb_axes('parent',f,'yLim',[0,1]);
l   = nb_plot(1:10,rand(10,2),'parent',ax);
leg = nb_legend(ax,{'Var1','Var2 sjbdfj hghjdgf hghd fghg df'},'location','outsideright');

f   = nb_figure();
ax  = nb_axes('parent',f,'yLim',[0,1]);
l   = nb_plot(1:10,rand(10,2),'parent',ax);
lab = nb_ylabel(ax,'y-label','side','right');
leg = nb_legend(ax,{'Var1','Var2'},'location','outsideright');

%% Place legend outside axes and resize axes to get room for legend

f   = nb_graphPanel('[4,3]','advanced',true);
ax  = nb_axes('parent',f,'yLim',[0,1]);
l   = nb_plot(1:10,rand(10,2),'parent',ax);
leg = nb_legend(ax,{'Var1','Var2 sjbdfj hghjdgf hghd fghg df'},'location','outsideright');

%% Shaded bars

d       = rand(10,2);
s       = false(10,2);
s(10,1) = true;
bar     = nb_bar(d,'style','grouped','shaded',s);

%% Blended bars

d       = rand(10,2);
s       = false(10,2);
s(10,1) = true;
bar     = nb_bar(d,'style','grouped','shaded',s,'blend',true);
