%% Load data used in paper

data = nb_ts('data');

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
prior.optParam = {'lambda','phi','mu'};

% Dummy-inital-observation prior
% prior.DIO = true;
prior.DIO = false;

% Defines the matrix with the linear transformations used to elicit the Long Run Prior
%     Y   C   I
H = [
      1   1   1 ;  %Y+C+I
     -1   1   0 ;  %C-Y
     -1   0   1 ]; %I-Y  
phi = ones(3,1);

%% B-VAR

% Options
t            = nb_var.template();
t.data       = data;
t.dependent  = {'Y','C','I'};
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = true;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);

% Apply prior for the long run
model = applyLongRunPriors(model,H,phi);

% Estimate
model = estimate(model);
print(model)
printCov(model)

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
hyperLearningSettings.variable = 'Y';

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
