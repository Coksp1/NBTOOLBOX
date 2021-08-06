%% Get help on this example

nb_var.help
nb_arima.help

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Initialize VAR

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.nLags     = 2;

% Create model and estimate
modelVAR = nb_var(t);
modelVAR = set(modelVAR,'name','VAR');

%% Initialize ARIMA

% Options
t             = nb_arima.template();
t.data        = sim;
t.dependent   = {'VAR1'};
t.AR          = 1;
t.MA          = 0;
t.integration = 0;

% Create model and estimate
modelAR = nb_arima(t);
modelAR = set(modelAR,'name','AR');

%% Create a heterogenous vector of model objects

models = [modelVAR,modelAR];

%% Estimate

models = estimate(models);
print(models)

%% Solve models

models = solveVector(models);

%% Forecast

models  = forecast(models,8);
plotter = plotForecast(models);
nb_graphSubPlotGUI(plotter)

