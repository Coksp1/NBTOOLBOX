%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

nb_graphSubPlotGUI(sim);

%% Get help on the nb_var class

nb_var.help
help nb_var.forecast

%% Estimate VAR (OLS)

% Options
t              = nb_var.template();
t.data         = sim;
t.estim_method = 'ols';
t.dependent    = sim.variables;
t.constant     = false;
t.nLags        = 2;
t.stdType      = 'h';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Point forecast from end of sample

nSteps  = 8;
modelS  = solve(model);
modelF  = forecast(modelS,nSteps);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% Recursive point forecast (In-sample)

modelS  = solve(model);
modelF  = forecast(modelS,8 ...
            ,'fcstEval', 'SE'... This triggers the recursive forecast
            ,'startDate','2014M1'...
          );
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Root mean squared error
score = getScore(modelF,'RMSE');
score.Model1

%% Density forecast from end of sample

nSteps  = 8;
modelS  = solve(model);
modelF  = forecast(modelS,nSteps,...
            'draws',2,...
            'parameterDraws',500);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% Recursive estimation of VAR

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ols';
t.dependent       = sim.variables;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;
% t.rollingWindow   = 20; % Include to estimate with rolling window!
t.recursive_estim_start_date = '2013M12';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Recursive point forecast (Out-of-sample)

modelS  = solve(model);
modelF  = forecast(modelS,8 ...
            ,'fcstEval', 'SE'... This triggers the recursive forecast
          );
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Root mean squared error
score = getScore(modelF,'RMSE');
score.Model1

%% Recursive density forecast (Out-of-sample)
% No parameter uncertainty

modelS = solve(model);
modelF = forecast(modelS,8,...
    'draws',            1000,...
    'estimateDensities',false,... Prevent kernel estimation
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);

% Root mean squared error
score = getScore(modelF,'RMSE');
score.Model1

% Mean log score
score = getScore(modelF,'MLS');
score.Model1

%% Recursive density forecast (Out-of-sample)
% With parameter uncertainty

modelS = solve(model);
modelF = forecast(modelS,8,...
    'draws',            2,...
    'estimateDensities',false,... Prevent kernel estimation
    'parameterDraws',   500,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);

% Root mean squared error
score = getScore(modelF,'RMSE');
score.Model1

% Mean log score
score = getScore(modelF,'MLS');
score.Model1
