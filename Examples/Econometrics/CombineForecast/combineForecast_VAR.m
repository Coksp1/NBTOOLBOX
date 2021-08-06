%% Get help on this example

help nb_model_group
help nb_model_group.combineForecast

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
vars    = {'VAR1','VAR2','VAR3'};
sim     = nb_ts.simulate('1990Q1',obs,vars,1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Estimate and solve many models

t                  = nb_var.template(10);
t.data             = sim;
t.dependent        = vars;
t(5).dependent     = {vars(1:2)};
t.constant         = 0;
t.recursive_estim  = 0;
t.nLags            = {1,2,3,4,5,6,7,8,9,10};
models             = nb_model_generic.initialize('nb_var',t);

tic
models = estimate(models);
toc

%% Solve the models

tic
models = solve(models);
toc

%% Forecast the models
% In-sample

tic
models = forecast(models,8,'fcstEval',{'SE','ABS','DIFF'},'waitbar');
toc

%% Test combined point forecast

% Construct a model group object
modelGroup = nb_model_group(models);

% Calculate the combined point forecast
tic
[modelGroup,weights,plotter] = combineForecast(modelGroup,...
                        'allPeriods',   1,...
                        'fcstEval',     {'SE'});
toc

% Plot weights at horizon 1
nb_graphPagesGUI(plotter(1));

% Plot the combined forecast with history
plotter = plotForecast(modelGroup);
nb_graphSubPlotGUI(plotter);

% See the individual forecast
plotter = plotForecast(models);
nb_graphSubPlotGUI(plotter);

%% Produce density forecast 
% Provided domain, which means we don't need to use the 'check' options
% during combine forecast.
%
% Density forecast saved to the folder returned by nb_userpath('gui')

tic
modelsD = forecast(models(1:5),8,...
    'fcstEval',         {'logScore','SE'},...
    'draws',            1000,...
    'parameterDraws',   1,...
    'varOfInterest',    'VAR1',...
    'saveToFile',       true,...
    'perc',             0,... % Just to make it not store all simulation
    'bins',             {'VAR1',-7,7,0.015});
toc

%% Construct a model group object

modelGroup = nb_model_group(modelsD);

%% Calculate the combined density forecast using MSE

tic
modelGroupMSE = combineForecast(modelGroup,...
                        'allPeriods',   1,...
                        'fcstEval',     {'logScore','SE'},...
                        'type',         'MSE',...
                        'density',      true,...
                        'draws',        1000,...
                        'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Calculate the combined density forecast using sum of log scores

tic
modelGroupESLS = combineForecast(modelGroup,...
                        'allPeriods',   1,...
                        'fcstEval',     {'logScore','SE'},...
                        'type',         'ESLS',...
                        'density',      true,...
                        'draws',        1000,...
                        'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Calculate the combined density forecast using mean log scores

tic
modelGroupEELS = combineForecast(modelGroup,...
                        'allPeriods',   1,...
                        'fcstEval',     {'logScore','SE'},...
                        'type',         'EELS',...
                        'density',      true,...
                        'draws',        1000,...
                        'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Calculate the combined density forecast using equal weights

tic
modelGroupEq = combineForecast(modelGroup,...
                        'allPeriods',   1,...
                        'fcstEval',     {'logScore','SE'},...
                        'type',         'equal',...
                        'density',      true,...
                        'draws',        1000,...
                        'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Plot different combined forecast

% Plot the combined forecast with history
plotter = plotForecast(modelGroupMSE);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupESLS);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupEELS);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupEq);
nb_graphSubPlotGUI(plotter);

% See the individual forecast
plotter = plotForecast(modelsD);
nb_graphSubPlotGUI(plotter);

%% Produce density forecast 
% Not provided domain, which means we need to use the 'check' options
% during combine forecast.
%
% Density forecast saved to the folder returned by nb_userpath('gui')

tic
modelsD = forecast(models(1:5),8,...
    'fcstEval',         {'logScore','SE'},...
    'draws',            1000,...
    'parameterDraws',   1,...
    'varOfInterest',    'VAR1',...
    'saveToFile',       true,...
    'perc',             0); % Just to make it not store all simulation

toc

%% Construct a model group object

modelGroup = nb_model_group(modelsD);

%% Calculate the combined density forecast using MSE

tic
modelGroupMSE = combineForecast(modelGroup,...
    'allPeriods',   0,... Just combine forecast for last period
    'type',         'MSE',...
    'check',        true,...
    'density',      true,...
    'draws',        1000,...
    'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Calculate the combined density forecast using sum of log scores

tic
modelGroupESLS = combineForecast(modelGroup,...
    'allPeriods',   0,... Just combine forecast for last period
    'type',         'ESLS',...
    'density',      true,...
    'check',        true,...
    'draws',        1000,...
    'perc',         [0.3,0.5,0.7,0.9]);

toc

%% Calculate the combined density forecast using mean log scores

tic
modelGroupEELS = combineForecast(modelGroup,...
    'allPeriods',   0,... Just combine forecast for last period
    'type',         'EELS',...
    'check',        true,...
    'density',      true,...
    'draws',        1000,...
    'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Calculate the combined density forecast using equal weights

tic
modelGroupEq = combineForecast(modelGroup,...
    'allPeriods',   0,... Just combine forecast for last period
    'type',         'equal',...
    'check',        true,...
    'density',      true,...
    'draws',        1000,...
    'perc',         [0.3,0.5,0.7,0.9]);
toc

%% Plot different combined forecast

% Plot the combined forecast with history
plotter = plotForecast(modelGroupMSE);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupESLS);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupEELS);
nb_graphSubPlotGUI(plotter);

% Plot the combined forecast with history
plotter = plotForecast(modelGroupEq);
nb_graphSubPlotGUI(plotter);

% See the individual forecast
plotter = plotForecast(modelsD);
nb_graphSubPlotGUI(plotter);
