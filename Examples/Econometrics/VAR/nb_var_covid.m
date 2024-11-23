%% Get help on the nb_var class

nb_var.help

%% Generate artificial data

rng(1); % Set seed

% Define covid names and dates
[covidDates,drop] = nb_covidDates(4);
covidDates        = covidDates(1:end-drop);
covidDummyNames   = nb_covidDummyNames(4);
covidDummyNames   = covidDummyNames(1:end-drop);

% Simulate covid episode 
obs     = 110;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1]; 
B       = -[8, -3, 1, -1, 0, 0;
            4, -4, 3, -1, 0, 0;
            7, -2, 2, -1, 0, 0];
covid   = nb_ts.zeros('1996Q1',obs,{'ZEROS'});
covid   = double(keepVariables(covidDummy(covid,covidDates),covidDummyNames));
sim     = nb_ts.simulate('1996Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho,...
                [],0,'exoData',covid,'B',B);
sim     = keepVariables(sim,{'VAR1','VAR2','VAR3'});
sim     = covidDummy(sim,covidDates);

%nb_graphSubPlotGUI(sim);

%% Estimate VAR (OLS)

% Options
t                      = nb_var.template();
t.data                 = sim;
t.estim_method         = 'ols';
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = covidDummyNames;
t.constant             = false;
t.nLags                = 2;
t.doTests              = 1;
t.stdType              = 'h';
t.removeZeroRegressors = true;

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
set(plotter,'startGraph','2017Q1')
nb_graphSubPlotGUI(plotter);

%% Estimate VAR (Recursive)

% Options
t                      = nb_var.template();
t.data                 = sim;
t.estim_method         = 'ols';
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = covidDummyNames;
t.constant             = false;
t.nLags                = 2;
t.stdType              = 'h';
t.recursive_estim      = 1;
t.removeZeroRegressors = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Recursive point forecast (In-sample)

modelS  = solve(model);
modelF  = forecast(modelS,8 ...
            ,'fcstEval', 'SE'... This triggers the recursive forecast
            ,'startDate','2014Q1'...
          );
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Estimate VAR (Rolling window)

% Options
t                      = nb_var.template();
t.data                 = sim;
t.estim_method         = 'ols';
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = covidDummyNames;
t.constant             = false;
t.nLags                = 2;
t.stdType              = 'h';
t.recursive_estim      = 1;
t.rollingWindow        = 20;
t.removeZeroRegressors = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (OLS)
% Remove covid dates from estimation

% Options
t              = nb_var.template();
t.data         = sim;
t.estim_method = 'ols';
t.dependent    = {'VAR1','VAR2','VAR3'};
t.constant     = false;
t.nLags        = 2;
t.doTests      = 1;
t.stdType      = 'h';
t.covidAdj     = covidDates;


% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (Recursive)
% Remove covid dates from estimation

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ols';
t.dependent       = {'VAR1','VAR2','VAR3'};
t.constant        = false;
t.nLags           = 2;
t.stdType         = 'h';
t.recursive_estim = 1;
t.covidAdj        = covidDates;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (RIDGE)

% Options
t              = nb_var.template();
t.data         = sim;
t.estim_method = 'ridge';
t.dependent    = {'VAR1','VAR2','VAR3'};
t.constant     = false;
t.nLags        = 2;
t.doTests      = 1;
t.covidAdj     = covidDates;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (Ridge, recursive)

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ridge';
t.dependent       = {'VAR1','VAR2','VAR3'};
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;
t.covidAdj        = covidDates;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (LASSO)

% Options
t                    = nb_var.template();
t.data               = sim;
t.estim_method       = 'lasso';
t.dependent          = {'VAR1','VAR2','VAR3'};
t.constant           = false;
t.nLags              = 2;
t.regularizationPerc = 0.9;
t.covidAdj           = covidDates;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (LASSO, recursive)

% Options
t                    = nb_var.template();
t.data               = sim;
t.estim_method       = 'lasso';
t.dependent          = {'VAR1','VAR2','VAR3'};
t.constant           = false;
t.nLags              = 2;
t.recursive_estim    = 1;
t.regularizationPerc = 0.9;
t.covidAdj           = covidDates;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)
