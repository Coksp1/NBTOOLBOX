%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Setup prior
% Giannone, Lenza and Primiceri (2014)

prior = nb_var.priorTemplate('glp');

%% B-VAR

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Emprirical B-VAR
% Optimized hyperparameters, but not using priors for the hyperparameters

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'iter';

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
optimset.Display = 'iter';

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

%% Setup prior, which handle missing observations
% Giannone, Lenza and Primiceri (2014)

priorM = nb_var.priorTemplate('glpMF');

%% B-VAR, with missing observations

simM = setToNaN(sim,sim.endDate,sim.endDate,sim.variables{1});

% Options
t            = nb_var.template();
t.data       = simM;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = priorM;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
modelM = nb_var(t);
modelM = estimate(modelM);
print(modelM)
printCov(modelM)

%% Emprirical B-VAR, with missing observations
% Optimized hyperparameters, but not using priors for the hyperparameters
%
% Caution: The optimization step is done on the balanced dataset, but the
%          estimation of the parameters given the hyperparameters is done
%          on the unbalanced dataset.

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'iter';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelMEMP = set(modelM,...
    'constant',true,...
    'draws',1000,...
    'empirical',true,... % Do empirical bayesian
    'optimizer',optimizer,...
    'optimset',optimset); 
modelMEMP = estimate(modelMEMP);
print(modelMEMP)
printCov(modelMEMP)

%% Hierarchical emprirical B-VAR, with missing observations
% Optimized hyperparameters and using priors for the hyperparameters, but
% not using M-H to sample from the posterior of hyperparameters
%
% Caution: The optimization step is done on the balanced dataset, but the
%          estimation of the parameters given the hyperparameters is done
%          on the unbalanced dataset.

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'iter';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelMEMPH = set(modelM,...
    'constant',true,...
    'draws',1000,...
    'empirical',true,... % Do empirical bayesian
    'hyperprior',true,...
    'optimizer',optimizer,...
    'optimset',optimset); 
modelMEMPH = estimate(modelMEMPH);
print(modelMEMPH)
printCov(modelMEMPH)
