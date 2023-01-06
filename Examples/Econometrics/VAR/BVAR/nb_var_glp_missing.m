%% Load data used in paper

data = nb_ts('data');

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Prior for the long run

% Defines the matrix with the linear transformations used to elicit the Long Run Prior
%     Y   C   I
H = [
      1   1   1 ;  %Y+C+I
     -1   1   0 ;  %C-Y
     -1   0   1 ]; %I-Y  
phi = ones(3,1);

%% B-VAR
% Giannone, Lenza and Primiceri (2014)

prior                   = nb_var.priorTemplate('glp');
prior.ARcoeff           = 1;
prior.logTransformation = true;
prior.optParam          = {'lambda','phi'};

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Options
t            = nb_var.template();
t.data       = data;
t.dependent  = {'Y','C','I'};
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = true;
t.nLags      = 2;
t.empirical  = true;
t.optimizer  = optimizer;
t.optimset   = optimset;

% Create model and estimate
model = nb_var(t);

% Apply prior for the long run
model = applyLongRunPriors(model,H,phi);

% Estimate
model = estimate(model);
print(model)
printCov(model)

%% B-VAR (missing)
% Giannone, Lenza and Primiceri (2014)

dataM        = data;
dataM(end,3) = nan;

prior                   = nb_var.priorTemplate('glpMF');
prior.ARcoeff           = 1;
prior.lambda            = 0.5;
prior.logTransformation = true;
prior.optParam          = {'lambda','phi'};
prior.nonStationary     = true; % Important for non-stationary data!

% Options
t            = nb_var.template();
t.data       = dataM;
t.dependent  = {'Y','C','I'};
t.draws      = 1000; % Return posterior mean estimate
t.prior      = prior;
t.constant   = true;
t.nLags      = 2;
% t.empirical  = true;
% t.optimizer  = optimizer;
% t.optimset   = optimset;

% Create model and estimate
model = nb_var(t);

% Apply prior for the long run
model = applyLongRunPriors(model,H,phi);

% Estimate
model = estimate(model);
print(model)
printCov(model)

%% B-VAR
% Classical minnesota with prior for the long run
% Minimize RMSE at forecast horizon 1!

prior                   = nb_var.priorTemplate('minnesota');
prior.ARcoeff           = 1;
prior.logTransformation = true;
prior.optParam          = {'phi'};

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'Y','C','I'};
t.draws     = 1000; % Return posterior mean estimate
t.prior     = prior;
t.constant  = true;
t.nLags     = 2;
t.optimizer = optimizer;
t.optimset  = optimset;

% Hyper-learning settings
t.hyperLearning         = true;
hypSettings             = nb_bVarEstimator.defaultHyperLearningSettings();
hypSettings.variable    = 'Y';
t.hyperLearningSettings = hypSettings;

% Create model and estimate
model = nb_var(t);

% Apply prior for the long run
model = applyLongRunPriors(model,H,phi);

% Estimate
model = estimate(model);
print(model)
printCov(model)

%% B-VAR (missing)
% Classical minnesota with prior for the long run and missing observation

dataM        = data;
dataM(end,3) = nan;

prior                   = nb_var.priorTemplate('minnesotaMF');
prior.ARcoeff           = 1;
prior.logTransformation = true;
prior.optParam          = {'phi'};
prior.nonStationary     = true;

% Optimizer options
% optimizer        = 'csminwel';
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'off';

% Options
t           = nb_var.template();
t.data      = dataM;
t.dependent = {'Y','C','I'};
t.draws     = 1000; % Return posterior mean estimate
t.prior     = prior;
t.constant  = true;
t.nLags     = 2;
t.optimizer = optimizer;
t.optimset  = optimset;

% Hyper-learning settings
t.hyperLearning         = true;
hypSettings             = nb_bVarEstimator.defaultHyperLearningSettings();
hypSettings.variable    = 'Y';
t.hyperLearningSettings = hypSettings;

% Create model and estimate
model = nb_var(t);

% Apply prior for the long run
model = applyLongRunPriors(model,H,phi);

% Estimate
model = estimate(model);
print(model)
printCov(model)
