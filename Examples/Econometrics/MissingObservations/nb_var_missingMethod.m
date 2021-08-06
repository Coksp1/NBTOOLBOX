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

%% Get help on the nb_var class

nb_var.help('missingMethod')

%% Set up VAR (no missing data)

% Options
t                            = nb_var.template();
t.data                       = sim;
t.estim_method               = 'ols';
t.dependent                  = vars;
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Add missing observations

dataM = setValue(sim,'VAR1',nan,'2014Q4','2014Q4');
dataM = setValue(dataM,'VAR2',nan(2,1),'2014Q3','2014Q4');

%% Set up VAR
% When estimating the VAR reecursivly with the use of the missingMethod 
% option we act as the variables that are missing today is also missing
% during the recursive estimation. This is done so we can evaluate
% the nowcasting properties of the given missingMethod!

% Options
t                            = nb_var.template();
t.data                       = dataM;
t.estim_method               = 'ols';
t.dependent                  = vars;
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';
t.missingMethod              = 'forecast';

% Create model and estimate
modelM = nb_var(t);
modelM = estimate(modelM);
print(modelM)

% Solve model
modelM = solve(modelM);

%% Set up VAR
% When estimating the VAR reecursivly with the use of the missingMethod 
% option we act as the variables that are missing today is also missing
% during the recursive estimation. This is done so we can evaluate
% the nowcasting properties of the given missingMethod!

% Options
t                            = nb_var.template();
t.data                       = dataM;
t.estim_method               = 'ols';
t.dependent                  = vars(2:end);
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';
t.missingMethod              = 'forecast';

% Create model and estimate
modelM2 = nb_var(t);
modelM2 = estimate(modelM2);
print(modelM2)

% Solve model
modelM2 = solve(modelM2);

%% Point nowcast and forecast
% Here we act as the variables that are missing today are also missing
% recursivly, we do this to evaluate how good the nowcast are!

modelF  = forecast([modelM,modelM2],6,'fcstEval','SE');
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);

plotter = plotForecast(modelF(2),'hairyplot');
% set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);

%% Plot with AR models

% Options
t                            = nb_arima.template();
t.data                       = dataM;
t.constant                   = false;
t.AR                         = 1;
t.MA                         = 0;
t.integration                = 0;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';

% Create model and estimate
arModels(3,1) = nb_arima();
for ii = 1:3
    t.dependent    = vars(ii);
    arModels(ii,1) = nb_arima(t);
end 
arModels  = estimate(arModels);
arModels  = solve(arModels);
arModels  = forecast(arModels,6);
arModelsR = forecast(arModels,6,...
                'startDate','2000Q2',...
                'fcstEval','SE');

%% Plot forecast

plotter = plotForecast([modelF;arModels]);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);

%% Get forecast in different ways

[fcstData,fcstPercData] = getForecast(modelF(2),'default')
[fcstData,fcstPercData] = getForecast(modelF(2),'graph')
[fcstData,fcstPercData] = getForecast(modelF(2),'2015Q1',true)
[fcstData,fcstPercData] = getForecast(modelF(2),'horizon')

%% Evaluate forecast

modelF = evaluateForecast(modelF,'fcstEval','ABS')

% Evaluation ABS will be stored in the forecastOutput property at field
% evaluation
modelF(1).forecastOutput.evaluation.ABS
modelF(2).forecastOutput.evaluation.ABS

%% Get PIT

modelF1               = forecast(modelM,6,'fcstEval','SE','draws',1000);
[pit,plotter,pitTest] = getPIT(modelF1);
nb_graphPagesGUI(plotter)

%% Get score

scores = getScore(modelF,'RMSE',false)
scores = getScore(modelF,'RMSE',true)
scores = getScore([arModelsR(1);modelF],'RMSE',false)
scores = getScore([arModelsR(1);modelF],'RMSE',true)

%% Plot density forecast

plotter = plotForecastDensity(modelF1,'2015Q1','VAR1'); % Last forecast of VAR1, so this is actually '2014Q4'
nb_graphPagesGUI(plotter);

plotter = plotForecastDensity(modelF1,'2015Q1','VAR2'); % Last forecast of VAR2, so this is actually '2014Q3'
nb_graphPagesGUI(plotter);

plotter = plotForecastDensity(modelF1,'2015Q1','VAR3'); % Last forecast of VAR3
nb_graphPagesGUI(plotter);

%% Get recursive score
% Same as when the third input is set to true, but now it is organized in
% another way, and we can more easily plot it

[score,plotter] = getRecursiveScore(modelF1,'RMSE','VAR1');
nb_graphPagesGUI(plotter);

[score,plotter] = getRecursiveScore([arModelsR(1),modelF1],'RMSE','VAR1');
nb_graphPagesGUI(plotter);

% We can also plot the scores of different variables against each other
[score,plotter] = getRecursiveScore(modelF1,'RMSE','variables');
nb_graphPagesGUI(plotter);

%% Add missing observations (also in sample)

dataM2 = setValue(sim,'VAR1',nan,'2014Q4','2014Q4');
dataM2 = setValue(dataM2,'VAR2',nan(2,1),'2014Q3','2014Q4');
dataM2 = setValue(dataM2,'VAR1',nan,'1990Q4','1990Q4');

%% Set up VAR

% Options
t                            = nb_var.template();
t.data                       = dataM2;
t.estim_method               = 'ols';
t.dependent                  = vars;
t.constant                   = false;
t.nLags                      = 2;
t.missingMethod              = 'kalmanFilter';

% Create model and estimate
modelM3 = nb_var(t);
modelM3 = estimate(modelM3);
print(modelM3)

% Solve model
modelM3 = solve(modelM3);

% Forecast
modelF  = forecast(modelM3,6);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);
