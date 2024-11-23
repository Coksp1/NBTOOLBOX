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

%% Settings

constant         = 1;
restrictConstant = true;

%% Estimate step ahead model
% Using the unbalanced option

t                       = nb_sa.template;
t.data                  = data;
t.dependent             = {'y'};
t.exogenous             = {'x1','x2'};
t.constant              = 1;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.regularization        = 2;
t.restrictConstant      = restrictConstant;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate step ahead model
% Using the unbalanced option

t                       = nb_sa.template;
t.data                  = data;
t.dependent             = {'y'};
t.exogenous             = {'x1','x2'};
t.constant              = constant;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.restrictConstant      = restrictConstant;

model       = nb_sa(t);
[reg,model] = getRegularization(model,'perc',0.5);
model       = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate step ahead model
% Using the unbalanced option

t                       = nb_sa.template;
t.data                  = data;
t.dependent             = {'y'};
t.exogenous             = {'x1','x2'};
t.constant              = constant;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.regularizationPerc    = 0.5;
t.restrictConstant      = restrictConstant;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model
% Using the unbalanced option

dataM                   = setValue(data,'y',nan,data.endDate,data.endDate);
t                       = nb_sa.template;
t.data                  = dataM;
t.dependent             = {'y'};
t.exogenous             = {'x1','x2'};
t.constant              = constant;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.regularizationPerc    = 0.5;
t.restrictConstant      = restrictConstant;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model    = forecast(model,4);
plotterU = plotForecast(model);
nb_graphSubPlotGUI(plotterU);

%% Plot against eachother

plotterB = merge(plotter,plotterU);
nb_graphSubPlotGUI(plotterB);

%% Estimate step ahead model
% Recursive

modelRec = set(model,'recursive_estim',1);
modelRec = estimate(modelRec);
print(modelRec)

plotter = getRecursiveEstimationGraph(modelRec);
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model
% Covid adjustment

dataM                   = setValue(data,'y',nan,data.endDate,data.endDate);
t                       = nb_sa.template;
t.data                  = dataM;
t.dependent             = {'y'};
t.exogenous             = {'x1','x2'};
t.constant              = constant;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.regularizationPerc    = 0.5;
t.restrictConstant      = restrictConstant;
t.covidAdj              = nb_covidDates(4);

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate step ahead model
% Recursive, covid adjustment

modelRec = set(model,'recursive_estim',1);
modelRec = estimate(modelRec);
print(modelRec)

plotter = getRecursiveEstimationGraph(modelRec);
nb_graphSubPlotGUI(plotter);

%% Simulate some big dataset

rng(1) % Set seed

% y_h = a + b*x + e
T      = 50;
N      = 70;
y      = nan(T,1);
x      = nan(T,N);
x(1,:) = 1;
for n = 1:N
    for t = 2:T
        x(t,n) = 0.5*x(t-1,n) + randn;
    end
end
beta       = randn(N,1).*0.1;
y(2:T,1) = 0.2 + x(2:T,:)*beta + randn(T-1,1).*0.2;
xNames   = nb_appendIndexes('x',1:N)';
data     = nb_ts([y,x],'','1999Q1',[{'y'},xNames]);

%% Estimate model with N > T

t                       = nb_sa.template;
t.data                  = data;
t.dependent             = {'y'};
t.exogenous             = xNames;
t.constant              = 1;
t.nStep                 = 4;
t.nLags                 = 1;
t.unbalanced            = true;
t.estim_method          = 'lasso';
t.regularization        = 2;
t.regularizationMode    = 'lagrangian';
t.restrictConstant      = restrictConstant;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the unbalanced option

model    = forecast(model,4);
plotterU = plotForecast(model);
nb_graphSubPlotGUI(plotterU);

%% Estimate step ahead model
% Recursive

modelRec = set(model,'recursive_estim',1);
modelRec = estimate(modelRec);
print(modelRec)

plotter = getRecursiveEstimationGraph(modelRec);
nb_graphSubPlotGUI(plotter);
