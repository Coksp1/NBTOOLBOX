%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim      = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

% Make one observation missing
sim(end,3) = nan;

% nb_graphSubPlotGUI(sim);

%% Get help on the nb_var class

nb_var.help
help nb_var.forecast

%% Recursive estimation of VAR

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ols';
t.dependent       = sim.variables;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;
t.recursive_estim_start_date = '2013M12';
t.missingMethod   = 'forecast';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Recursive density forecast (Out-of-sample)
% No parameter uncertainty

modelS = solve(model);
modelF = forecast(modelS,8,...
    'draws',            1000,...
    'estimateDensities',false,... Prevent kernel estimation
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);

plotterF = plotForecast(modelF);
nb_graphSubPlotGUI(plotterF);

%% Estimate kernel based on percentiles

modelFK = doForecastPerc2Dist(modelF);

%% Simulate from estimated kernel

modelFKDraws   = doSimulateFromDensity(modelFK,1000);
plotterFKDraws = plotForecast(modelFKDraws);
nb_graphSubPlotGUI(plotterFKDraws);

%% Estimate parameterized distribution based on percentiles

modelFPDraws   = doForecastPerc2ParamDist(modelF,'normal',1000);
plotterFPDraws = plotForecast(modelFPDraws);
nb_graphSubPlotGUI(plotterFPDraws);
