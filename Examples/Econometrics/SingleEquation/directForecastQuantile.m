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
    x2(t) = 0.8*x2(t-1) + randn;
end
y(2:100,1) = 0.2 + 0.6*x1(1:99) + 0.4*x2(1:99) + randn(99,1);
y(2:100,2) = 0.3 + 0.1*x1(1:99) + 0.8*x2(1:99) + randn(99,1);

% plot([x1,x2,y])

data = nb_ts([y,x1,x2],'','1999Q1',{'y','y2','x1','x2'});

%% Estimate step ahead model

q              = [0.05,0.15,0.25,0.35,0.5,0.65,0.75,0.85,0.95];
t              = nb_sa.template;
t.data         = data;
t.dependent    = {'y'};
t.estim_method = 'quantile';
t.exogenous    = {'x1','x2'};
t.constant     = 1;
t.nStep        = 4;
t.quantile     = q;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (median at end of sample only)

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Forecast 
% Recursive median in-sample forecasting

model   = forecast(model,4,...
    'startDate', '2010Q1',...
    'fcstEval',  'se');
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Forecast
% Recursive percentiles in-sample forecasting

model = forecast(model,4,...
    'startDate', '2010Q1',...
    'draws',     2,... Any > 1
    'fcstEval',  {'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model
% Recursively

q                 = [0.05,0.15,0.25,0.35,0.5,0.65,0.75,0.85,0.95];
t                 = nb_sa.template;
t.data            = data;
t.dependent       = {'y'};
t.estim_method    = 'quantile';
t.exogenous       = {'x1','x2'};
t.constant        = 1;
t.nStep           = 4;
t.quantile        = q;
t.recursive_estim = 1;
t.recursive_estim_start_date  = '2010Q1';

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve recursivly
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Forecast 
% Recursive out-of-sample point forecasting

model   = forecast(model,4,'fcstEval','se');
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Forecast
% Recursive density out-of-sample forecasting

model = forecast(model,4,...
    'draws',    2,... Any > 1
    'fcstEval', {'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Estimate step ahead model
% Covid adjustment and unbalanced

q              = [0.05,0.15,0.25,0.35,0.5,0.65,0.75,0.85,0.95];
t              = nb_sa.template;
t.data         = data;
t.dependent    = {'y'};
t.estim_method = 'quantile';
t.exogenous    = {'x1','x2'};
t.constant     = 1;
t.nStep        = 4;
t.quantile     = q;
t.covidAdj     = nb_covidDates(4);
t.unbalanced   = true;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate step ahead model
% Recursive, covid adjustment

modelRec = set(model,'recursive_estim',1,...
    'recursive_estim_start_date','2010Q1');
modelRec = estimate(modelRec);
print(modelRec)

plotter = getRecursiveEstimationGraph(modelRec);
nb_graphSubPlotGUI(plotter);
