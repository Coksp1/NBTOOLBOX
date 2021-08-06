%% Get help on this example

nb_midas.help

%% Generate artificial data

rng(1); % Set seed

obs     = 200;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
dataQ   = nb_ts.simulate('1990Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataA   = convert(dataQ,1,'diffAverage');
dataAQ  = convert(dataA,4,'','interpolateDate','end');
dataAQ  = addPrefix(dataAQ,'A_');
data    = [dataAQ,dataQ];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Settings

algorithm       = 'almon';
AR              = 0;
nStep           = 2;
polyLags        = 2;
recursive_estim = false;

%% MIDAS
% Balanced

% Options
t                 = nb_midas.template();
t.data            = data;
t.algorithm       = algorithm;
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = nStep;
t.nLags           = 3;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
model   = forecast(model,2);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% MIDAS
% 4 leads on exogenous

dataM        = data;
dataM(end,1) = nan;

% Options
t                 = nb_midas.template();
t.data            = dataM;
t.algorithm       = algorithm;
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = nStep;
t.nLags           = 3;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
model   = forecast(model,2);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);


%% MIDAS
% 3 leads on exogenous

dataM = data;
dataM = dataM(1:end-1,:);

% Options
t                 = nb_midas.template();
t.data            = dataM;
t.algorithm       = algorithm;
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = nStep;
t.nLags           = 3;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
model   = forecast(model,2);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% MIDAS
% 2 leads on exogenous

dataM = data;
dataM = dataM(1:end-2,:);

% Options
t                 = nb_midas.template();
t.data            = dataM;
t.algorithm       = algorithm;
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = nStep;
t.nLags           = 3;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
model   = forecast(model,2);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% MIDAS
% 1 leads on exogenous

dataM = data;
dataM = dataM(1:end-3,:);

% Options
t                 = nb_midas.template();
t.data            = dataM;
t.algorithm       = algorithm;
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = nStep;
t.nLags           = 3;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
model   = forecast(model,2);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
