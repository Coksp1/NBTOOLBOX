%% Get help on the nb_var class

nb_var.help

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1]; 
B       = -[0.5 , 0.2;
            0.5 , 0.2;
            0.5 , 0.2];
covid   = nb_ts.zeros('1996Q1',obs,{'ZEROS'});
covid   = double(keepVariables(covidDummy(covid),nb_covidDummyNames(4)));
sim     = nb_ts.simulate('1996Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho,...
                [],0,'exoData',covid,'B',B);
sim     = covidDummy(sim);

%nb_graphSubPlotGUI(sim);

%% Estimate VAR (Two stage OLS)
% 1. Prefilter variables with covid dummies
% 2. The VAR

% Options
t                      = nb_var.template();
t.data                 = sim;
t.estim_method         = 'ols';
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = nb_covidDummyNames(4);
t.constant             = false;
t.nLags                = 2;
t.doTests              = 1;
t.stdType              = 'h';
t.removeZeroRegressors = true;
% t.estim_end_date       = '2018Q1';

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
t.exogenous            = nb_covidDummyNames(4);
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
t.exogenous            = nb_covidDummyNames(4);
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
