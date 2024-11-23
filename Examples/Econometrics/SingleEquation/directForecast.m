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

t           = nb_sa.template;
t.data      = data;
t.dependent = {'y'};
t.exogenous = {'x1','x2'};
t.constant  = 1;
t.nStep     = 4;

model = nb_sa(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Direct forecast (at end of sample only)

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);


%% Forecast 
% Recursive in-sample forecasting

model   = forecast(model,4,'fcstEval','se');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

score = getScore(model,'RMSE');
score.Model1

%% Forecast
% Recursive density in-sample forecasting

model = forecast(model,3,...
    'startDate',        '2012Q1',...
    'draws',            1000,...
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

score = getScore(model,'MLS');
score.Model1

%% Forecast with parameter uncertainty
% Recursive density in-sample forecasting

model = forecast(model,4,...
    'startDate',        '2012Q1',...
    'draws',            10,...
    'parameterDraws',   100,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

score = getScore(model,'MLS');
score.Model1

%% Estimate step ahead model
% Recursively

t = nb_sa.template;
t.data            = data;
t.dependent       = {'y','y2'};
t.exogenous       = {'x1','x2'};
t.constant        = 1;
t.nStep           = 4;
t.recursive_estim = 1;
% t.recursive_estim_start_date  = '2023Q4';

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
% Recursive out-of-sample density forecasting

model = forecast(model,4,'fcstEval','se');
score = getScore(model,'RMSE');
score.Model1

%% Forecast
% Recursive density out-of-sample forecasting

model = forecast(model,4,...
    'startDate',        '2012Q1',...
    'draws',            1000,...
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
score = getScore(model,'MLS');
score.Model1

%% Forecast with parameter uncertainty
% Recursive density out-of-sample forecasting

model = forecast(model,4,...
    'startDate',        '2012Q1',...
    'endDate',          '2020Q4',...
    'draws',            100,...
    'parameterDraws',   10,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
score = getScore(model,'MLS');
score.Model1

%% Append data 

data = createVariable(data,{'y_lead1','y_lead3'},{'lead(y,1)','lead(y,3)'});

%% Estimate step ahead model (Using nb_singleEq)
% Not recommended! As one period is removed at the end of the sample!!

t            = nb_singleEq.template;
t.data       = data;
t.dependent  = {'y_lead1','y_lead3'};
t.exogenous  = {'x1','x2'};
t.constant   = 1;

model = nb_singleEq(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast 
% Caution: Horizon2 will be given the forecast 0 in this example!

model   = forecast(model,3);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecasts
% Caution: Horizon2 will be given the forecast of mean 0 and std 1 in 
% this example!

model = forecast(model,3,...
    'draws',            10,...
    'parameterDraws',   100,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
