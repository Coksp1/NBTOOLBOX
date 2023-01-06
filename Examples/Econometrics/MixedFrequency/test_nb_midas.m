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

%% General estimation options

AR = true;

%% Step ahead model (OLS)

% Options
t              = nb_sa.template();
t.data         = data;
t.estim_method = 'ols';
t.dependent    = {'VAR1'};
t.exogenous    = {'VAR2','VAR3'};
t.constant     = true;
t.nStep        = 4;
t.doTests      = 1;

% Create model and estimate
model = nb_sa(t);
model = estimate(model);
print(model)

%% Unrestricted MIDAS

% Options
t            = nb_midas.template();
t.data       = data;
t.algorithm  = 'unrestricted';
t.dependent  = {'A_VAR1'};
t.exogenous  = {'VAR2','VAR3'};
t.constant   = true;
t.frequency  = 1;
t.nStep      = 4;
t.nLags      = 3;
t.doTests    = 1;
t.AR         = AR;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve unrestricted MIDAS

model = solve(model);

%% Forecast with unrestricted MIDAS

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% In-sample forecast evaluation of unrestricted MIDAS

model   = forecast(model,4,'fcstEval',{'SE'});
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

score = getScore(model,'RMSE');
score.Model1

%% Density forecast with unrestricted MIDAS (no parameter uncertainty)

model   = forecast(model,4,'draws',1000,'parameterDraws',1);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with unrestricted MIDAS (with parameter uncertainty)

model   = forecast(model,4,'draws',1,'parameterDraws',1000);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% In-sample density forecast evaluation of unrestricted MIDAS

model   = forecast(model,4,...
            'fcstEval',{'SE','logScore'},...
            'draws',1000,...
            'parameterDraws',1);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

score = getScore(model,'RMSE');
score.Model1

scoreLS = getScore(model,'EELS');
scoreLS.Model1

%% Unrestricted MIDAS 
% recursive

% Options
t                 = nb_midas.template();
t.data            = data;
t.algorithm       = 'unrestricted';
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = 4;
t.nLags           = 3;
t.doTests         = 1;
t.recursive_estim = true;
t.AR              = AR;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve unrestricted MIDAS (recursive)

model = solve(model);

%% Forecast with unrestricted MIDAS at a spesific point in time

model   = forecast(model,4,'startDate','2013');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Out-of-sample forecast evaluation of unrestricted MIDAS

model   = forecast(model,4,'fcstEval',{'SE'});%,'startDate','2013','endDate','2040'
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Inverted RMSE!!!
score = getScore(model,'RMSE');
score.Model1

%% Out-of-sample density forecast with unrestricted MIDAS 
% (no parameter uncertainty)

model   = forecast(model,4,...
            'fcstEval',{'SE','logScore'},...
            'draws',1000,...
            'parameterDraws',1);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Inverted RMSE!!!
score = getScore(model,'RMSE');
score.Model1

scoreLS = getScore(model,'EELS');
scoreLS.Model1

%% Out-of-sample density forecast with unrestricted MIDAS 
% (with parameter uncertainty)

model   = forecast(model,4,...
            'fcstEval',{'SE','logScore'},...
            'draws',1,...
            'parameterDraws',1000);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

score = getScore(model,'RMSE');
score.Model1

scoreLS = getScore(model,'EELS');
scoreLS.Model1

%% Test restricted MIDAS (almon)

% Options
t           = nb_midas.template();
t.data      = data;
t.algorithm = 'almon';
t.dependent = {'A_VAR1'};
t.exogenous = {'VAR2','VAR3'};
t.constant  = true;
t.frequency = 1;
t.nStep     = 4;
t.nLags     = 4;
t.doTests   = 1;
t.AR        = AR;
t.draws     = 500; % Need > 1 to get std!

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve restricted MIDAS (almon)

model = solve(model);

%% Forecast restricted MIDAS (almon)

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (almon) (no parameter uncertainty)

model   = forecast(model,4,'draws',1000,'parameterDraws',1);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (almon) (parameter uncertainty)

model   = forecast(model,4,'draws',2,'parameterDraws',500);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Test restricted MIDAS (almon) (recursive)

% Options
t                 = nb_midas.template();
t.data            = data;
t.algorithm       = 'almon';
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = 4;
t.nLags           = 4;
t.doTests         = 1;
t.recursive_estim = true;
t.AR              = AR;
t.draws           = 1;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve restricted MIDAS (almon) (recursive)

model = solve(model);

%% Out-of-sample forecast evaluation of restricted MIDAS (almon)

model   = forecast(model,4,'fcstEval',{'SE'});
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Inverse RMSE!!!
score = getScore(model,'RMSE');
score.Model1

%% Density forecast with restricted MIDAS (almon) (no parameter uncertainty)

model   = forecast(model,4,...
            'draws',1000,...
            'parameterDraws',1,...
            'fcstEval',{'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (almon) (with parameter uncertainty)

model   = forecast(model,4,...
            'draws',2,...
            'parameterDraws',500,...
            'fcstEval',{'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Test restricted MIDAS (beta)

% Options
t           = nb_midas.template();
t.data      = data;
t.algorithm = 'beta';
t.dependent = {'A_VAR1'};
t.exogenous = {'VAR2','VAR3'};
t.constant  = true;
t.frequency = 1;
t.nStep     = 4;
t.nLags     = 4;
t.doTests   = 1;
t.AR        = AR;
t.draws     = 500; % Need > 1 to get std!

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve restricted MIDAS (beta)

model = solve(model);

%% Forecast restricted MIDAS (beta)

model   = forecast(model,4);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (beta) (no parameter uncertainty)

model   = forecast(model,4,'draws',1000,'parameterDraws',1);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (beta) (parameter uncertainty)

model   = forecast(model,4,'draws',2,'parameterDraws',500);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Test restricted MIDAS (beta) (recursive)

% Options
t                 = nb_midas.template();
t.data            = data;
t.algorithm       = 'beta';
t.dependent       = {'A_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.constant        = true;
t.frequency       = 1;
t.nStep           = 4;
t.nLags           = 4;
t.doTests         = 1;
t.recursive_estim = true;
t.AR              = AR;
t.draws           = 500;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve restricted MIDAS (beta) (recursive)

model = solve(model);

%% Out-of-sample forecast evaluation of restricted MIDAS (almon)

model   = forecast(model,4,'fcstEval',{'SE'});
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Inverse RMSE!!!
score = getScore(model,'RMSE');
score.Model1

%% Density forecast with restricted MIDAS (beta) (no parameter uncertainty)

model   = forecast(model,4,...
            'draws',1000,...
            'parameterDraws',1,...
            'fcstEval',{'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Density forecast with restricted MIDAS (betacl) (with parameter uncertainty)

model   = forecast(model,4,...
            'draws',2,...
            'parameterDraws',1000,...
            'fcstEval',{'SE'});
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
