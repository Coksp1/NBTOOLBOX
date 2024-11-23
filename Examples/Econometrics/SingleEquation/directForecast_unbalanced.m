%% Help on this example

nb_sa.help

%% Simulate some data

rng(1) % Set seed

% y_h = a + b*x + e
y     = nan(100,2);
x1    = nan(100,1);
x2    = nan(100,1);
x1(1) = 1;
x2(1) = 2;
for t = 2:100
    x1(t) = 0.5*x1(t-1) + randn;
    x2(t) = 0.5*x2(t-1) + randn;
end
y(2:100,1) = 0.2 + 0.6*x1(1:99) + 0.4*x2(1:99) + randn(99,1);
y(2:100,2) = 0.3 + 0.1*x1(1:99) + 0.8*x2(1:99) + randn(99,1);

data = nb_ts([y,x1,x2],'','1999Q1',{'y','y2','x1','x2'});

%% General settings

nLags = 1;

%% Estimate step ahead model
% Using the unbalanced option

dataM        = setValue(data,'y',nan,data.endDate,data.endDate);
dataM        = setValue(dataM,'x1',nan,data.endDate,data.endDate);
dataM        = setValue(dataM,'x2',nan,data.endDate,data.endDate);
t            = nb_sa.template;
t.data       = dataM;
t.dependent  = {'y'};
t.exogenous  = {'x1','x2'};
t.constant   = 1;
t.nStep      = 4;
t.nLags      = nLags;
t.unbalanced = true;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model   = set(model,'name','All lag');
model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model
% Using the unbalanced option

dataM        = setValue(data,'y',nan,data.endDate,data.endDate);
t            = nb_sa.template;
t.data       = dataM;
t.dependent  = {'y'};
t.exogenous  = {'x1','x2'};
t.constant   = 1;
t.nStep      = 4;
t.nLags      = nLags;
t.unbalanced = true;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model     = set(model,'name','y lag');
model   = forecast(model,4);
plotterU = plotForecast(model);
nb_graphSubPlotGUI(plotterU);

%% Estimate step ahead model
% Using the unbalanced option, different end date for the two exogenous

dataM        = setValue(data,'y',nan,data.endDate,data.endDate);
dataM        = setValue(dataM,'x2',nan,data.endDate,data.endDate);
t            = nb_sa.template;
t.data       = dataM;
t.dependent  = {'y'};
t.exogenous  = {'x1','x2'};
t.constant   = 1;
t.nStep      = 4;
t.nLags      = nLags;
t.unbalanced = true;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model     = set(model,'name','y and x2 lag');
model     = forecast(model,4);
plotterU2 = plotForecast(model);
nb_graphSubPlotGUI(plotterU2);

%% Plot against eachother

plotterB = merge(plotter,plotterU,plotterU2);
nb_graphSubPlotGUI(plotterB);
