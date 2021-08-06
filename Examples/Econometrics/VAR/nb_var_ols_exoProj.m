%% Generate artificial data

rng(1); % Set seed

obs     = 100;
burn    = 10;
X       = randn(obs + burn,2);
B       = [0.2, 0; 0, 0.4; 0, 0];
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,3,1,lambda,rho,[],burn,...
            'exoData',X,'B',B);  
        
% nb_graphSubPlotGUI(sim);

%% Estimate VAR (OLS)

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'Var1','Var2','Var3'};
t.exogenous = {'ExoVar1','ExoVar2'};
t.constant  = true;
t.nLags     = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print_estimation_results(model)

%% Solve model and forecast

model   = solve(model);
model   = forecast(model,8,...
           'output',    'all',...
           'exoProj',   'ar');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and forecast

model   = solve(model);
model   = forecast(model,8,...
           'output',    'all',...
           'exoProj',   'var');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast

model = solve(model);
model = forecast(model,8,...
    'draws',            1000,...
    'parameterDraws',   50,...
    'output',           'all',...
    'perc',             [0.3,0.5,0.7,0.9],...
    'exoProj',          'ar');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Recursive estimate VAR (OLS)

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'Var1','Var2','Var3'};
t.exogenous = {'ExoVar1','ExoVar2'};
t.constant  = true;
t.nLags     = 2;
t.recursive_estim            = true;
t.recursive_estim_start_date = '2014M1';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print_estimation_results(model)

%% Solve model and forecast

model   = solve(model);
model   = forecast(model,8,...
           'fcstEval',  'SE',...
           'output',    'all',...
           'exoProj',   'ar');
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Solve model and forecast

model   = solve(model);
model   = forecast(model,8,...
           'fcstEval',  'SE',...
           'output',    'all',...
           'exoProj',   'var');
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast

model = solve(model);
model = forecast(model,8,...
    'startDate',        '2020M1',...
    'estimateDensities',false,... Prevent kernel estimation
    'fcstEval',         'SE',...
    'draws',            1000,...
    'parameterDraws',   50,...
    'output',           'all',...
    'perc',             [0.3,0.5,0.7,0.9],...
    'exoProj',          'ar');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

