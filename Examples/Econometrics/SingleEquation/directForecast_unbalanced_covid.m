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

%% Estimate step ahead model
% Using the covidAdj option

t            = nb_sa.template;
t.data       = data;
t.dependent  = {'y'};
t.exogenous  = {'x1','x2'};
t.constant   = 1;
t.nStep      = 4;
t.nLags      = 1;
t.unbalanced = true;
t.covidAdj   = nb_covidDates(4);

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)
% Using the covidAdj option

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model recursively
% Using the covidAdj option

t                 = nb_sa.template;
t.data            = data;
t.dependent       = {'y'};
t.exogenous       = {'x1','x2'};
t.constant        = 1;
t.nStep           = 4;
t.nLags           = 1;
t.unbalanced      = true;
t.covidAdj        = nb_covidDates(4);
t.recursive_estim = true;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Recursive forecast 
% Using the covidAdj option

model      = forecast(model,4,'fcstEval','SE');
plotterRec = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotterRec);
