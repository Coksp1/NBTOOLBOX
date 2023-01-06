%% Load data used in paper

data = nb_ts('KAMEL_data.mat');

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Setup prior
% Giannone, Lenza and Primiceri (2014)

prior = nb_var.priorTemplate('glp');

% Use same log transfomration as in the paper. This to apply bounds to the
% csminwel optimizer!
prior.logTransformation = true;

% Only optimize over some of the priors 
prior.optParam = {'lambda','rho','mu','delta'};

% Stochastic-volatility-dummy prior
prior.SVD        = true;
prior.dateSVD    = '2020Q1';
prior.periodsMax = 3;
prior.rho        = 0.5;
prior.DIO        = 1;
prior.SC         = 1;

%% B-VAR

% Options
t            = nb_var.template();
t.data       = data;
t.dependent  = data.variables;
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = true;
t.nLags      = 5;

% Create model and estimate
model = nb_var(t);

% Estimate
model = estimate(model);
print(model)
printCov(model)

%% Density forecast

modelS  = solve(model);
modelF  = forecast(modelS,10,'draws',1000);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Emprirical B-VAR
% Optimized hyperparameters, but not using priors for the hyperparameters

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelEMP = set(model,...
    'constant',true,...
    'draws',1,...
    'empirical',true,... % Do empirical bayesian
    'optimizer',optimizer,...
    'optimset',optimset); 
modelEMP = estimate(modelEMP);
print(modelEMP)
printCov(modelEMP)

%% Hierarchical emprirical B-VAR
% Optimized hyperparameters and using priors for the hyperparameters, but
% not using M-H to sample from the posterior of hyperparameters

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelEMPH = set(model,...
    'constant',true,...
    'draws',1,...
    'empirical',true,... % Do empirical bayesian
    'hyperprior',true,...
    'optimizer',optimizer,...
    'optimset',optimset); 
modelEMPH = estimate(modelEMPH);
print(modelEMPH)
printCov(modelEMPH)

%% Hyper optimization based on RMSE B-VAR
% Optimized hyperparameters using out-of-sample RMSE

% Settings
hyperLearningSettings          = nb_bVarEstimator.defaultHyperLearningSettings();
hyperLearningSettings.variable = 'QSA_YMN';

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelEMP = set(model,...
    'constant',true,...
    'draws',1,...
    'hyperLearning',true,...
    'hyperLearningSettings',hyperLearningSettings,...
    'optimizer',optimizer,...
    'optimset',optimset); 
modelEMP = estimate(modelEMP);
print(modelEMP)
printCov(modelEMP)

%% Recursive estimation

modelRec = set(model,...
    'recursive_estim',true); 
modelRec = estimate(modelRec);
print(modelRec)
printCov(modelRec)

%% Density forecast

modelS  = solve(model);
modelF  = forecast(modelS,10,'draws',1000,'fcstEval','SE','startDate','2020Q1');

s.QSA_CP = struct('yLim',[4.5,4.67]);

plotter = plotForecast(modelF,'default','2020Q1');
plotter.set('startGraph','2019Q1','subPlotsOptions',s);
nb_graphSubPlotGUI(plotter);

plotter = plotForecast(modelF,'default','2020Q2');
plotter.set('startGraph','2019Q1','subPlotsOptions',s);
nb_graphSubPlotGUI(plotter);
