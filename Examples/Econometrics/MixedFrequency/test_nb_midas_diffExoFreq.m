%% Get help on this example

nb_midas.help

%% Generate artificial data

rng(1); % Set seed

obs     = 816;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataA   = convert(dataM,1,'diffAverage');
dataAM  = convert(dataA,12,'','interpolateDate','end');
dataAM  = addPrefix(dataAM,'A_');
dataQ   = convert(dataM,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data    = [dataAM,dataQM,dataM];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Restricted MIDAS (almon)

% Options
t            = nb_midas.template();
t.data       = data;
t.algorithm  = 'almon';
t.dependent  = {'A_VAR1'};
t.exogenous  = {'Q_VAR2','VAR3'};
t.constant   = true;
t.frequency  = {'A_VAR1',1,'Q_VAR2',4};
t.nStep      = 4;
t.nLags      = [2,11];
t.doTests    = 1;
t.AR         = 0;
t.draws      = 500;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Unrestricted MIDAS

% Options
t            = nb_midas.template();
t.data       = data;
t.algorithm  = 'unrestricted';
t.dependent  = {'A_VAR1'};
t.exogenous  = {'Q_VAR2','VAR3'};
t.constant   = true;
t.frequency  = {'A_VAR1',1,'Q_VAR2',4};
t.nStep      = 4;
t.nLags      = [2,11];
t.doTests    = 1;
t.AR         = 0;
t.draws      = 500;

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
t.exogenous       = {'Q_VAR2','VAR3'};
t.constant        = true;
t.frequency       = {'A_VAR1',1,'Q_VAR2',4};
t.nStep           = 4;
t.nLags           = [2,11];
t.doTests         = 1;
t.AR              = 0;
t.draws           = 500;
t.recursive_estim = true;

t.recursive_estim_start_date = '2025M1';

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

%% Solve unrestricted MIDAS (recursive)

model = solve(model);

%% Forecast with unrestricted MIDAS at a spesific point in time

model   = forecast(model,4,'startDate','2030');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Out-of-sample forecast evaluation of unrestricted MIDAS

model   = forecast(model,4,'fcstEval',{'SE'});
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

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

score = getScore(model,'RMSE');
score.Model1

scoreLS = getScore(model,'EELS');
scoreLS.Model1

%% Out-of-sample density forecast with unrestricted MIDAS 
% (with parameter uncertainty)

model   = forecast(model,4,...
            'fcstEval',{'SE','logScore'},...
            'draws',2,...
            'parameterDraws',500);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

score = getScore(model,'RMSE');
score.Model1

scoreLS = getScore(model,'EELS');
scoreLS.Model1

%% Unrestricted MIDAS
% Regressor also on the same frequency as the dependent

% Options
t            = nb_midas.template();
t.data       = data;
t.algorithm  = 'unrestricted';
t.dependent  = {'A_VAR1'};
t.exogenous  = {'A_VAR2','VAR3'};
t.constant   = true;
t.frequency  = {'A_VAR1',1,'A_VAR2',1};
t.nStep      = 4;
t.nLags      = [2,11];
t.doTests    = 1;
t.AR         = 0;
t.draws      = 500;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)
