%% Load data
% This is the data from the examples given in the paper
% Giannone, Lenza and Primiceri (2014)
%
% The results are slightly different as the AR estimation  
% that is used to set up the priors are using the same number 
% of lags as the VAR as opposed to only 1 lag.

y    = load('y.mat');
data = nb_ts(y,'','1947Q3',{'Y','C','I','H','W','P','R'});

%% Setting up the VAR

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'Y','C','I'};
t.nLags     = 5;
model       = nb_var(t);

%% Setting up prior and estimate standard minnesota
% Using a independent normal wishart type minnesota prior

prior         = nb_var.priorTemplate('minnesota');
prior.ARcoeff = 1;
prior.a_bar_1 = 0.2;
prior.a_bar_2 = 0.2;
prior.method  = 'inwishart'; % Triggers the independent normal wishart type
modelS        = setPrior(model,prior);
modelS        = estimate(modelS,'constant',true,'draws',1000);
print(modelS)
printCov(modelS)

%% Setting up prior and estimate minnesota and prior for the long run
% Using a independent normal wishart type minnesota prior

prior         = nb_var.priorTemplate('minnesota');
prior.ARcoeff = 1;
prior.a_bar_1 = 0.2;
prior.a_bar_2 = 0.2;
prior.method  = 'gibbs'; % Triggers the independent normal wishart type
modelLR       = setPrior(model,prior);

% Long run restrictions
H       = [ 1   1   1 ;  %Y+C+I
           -1   1   0 ;  %C-Y
           -1   0   1 ]; %I-Y 
phi     = ones(3,1);
modelLR = applyLongRunPriors(modelLR,H,phi);

% Estimate
modelLR = set(modelLR,'constant',true);
modelLR = estimate(modelLR);
print(modelLR)

%% Setting up prior and estimate minnesota and prior for the long run
% Using parsing

prior         = nb_var.priorTemplate('minnesota');
prior.ARcoeff = 1;
prior.a_bar_1 = 0.2;
prior.a_bar_2 = 0.2;
prior.method  = 'gibbs'; % Triggers the independent normal wishart type
modelLRP      = setPrior(model,prior);

% Long run restrictions
H        = {'Y+C+I','C-Y','I-Y'}; 
phi      = {'Y',1;
            'C',1;
            'I',1};
modelLRP = applyLongRunPriors(modelLRP,H,phi);

% Estimate
modelLRP = set(modelLRP,'constant',false);
modelLRP = estimate(modelLRP);
print(modelLRP)

%% Giannone, Lenza and Primiceri (2014) prior + prior for the long run
% Which is a Normal-Wishart type minnesota prior

prior   = nb_var.priorTemplate('glp');
modelLR = setPrior(model,prior);

% Long run restrictions
H       = [ 1   1   1 ;  %Y+C+I
           -1   1   0 ;  %C-Y
           -1   0   1 ]; %I-Y 
phi     = ones(3,1);
modelLR = applyLongRunPriors(modelLR,H,phi);

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelLR = set(modelLR,'constant',true,'draws',1); 
modelLR = estimate(modelLR);
print(modelLR)

%% Giannone, Lenza and Primiceri (2014) prior + prior for the long run
% Optimized hyperparameters, but not using priors for the hyperparameters

prior                   = nb_var.priorTemplate('glp');
prior.ARcoeffHyperprior = [];
prior.VcHyperprior      = [];
prior.S_scaleHyperprior = [];
modelLR                 = setPrior(model,prior);

% Long run restrictions
H       = [ 1   1   1 ;  %Y+C+I
           -1   1   0 ;  %C-Y
           -1   0   1 ]; %I-Y 
phi     = ones(3,1);
modelLR = applyLongRunPriors(modelLR,H,phi);

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'iter';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelLR = set(modelLR,...
    'constant',true,...
    'draws',1,...
    'empirical',true,... % Do empirical bayesian
    'optimizer',optimizer,...
    'optimset',optimset); 
modelLR = estimate(modelLR);
print(modelLR)
printCov(modelLR)

%% Giannone, Lenza and Primiceri (2014) prior + prior for the long run
% Optimized hyperparameters and using priors for the hyperparameters, but
% not using M-H to sample from the posterior of hyperparameters

prior                   = nb_var.priorTemplate('glp');
prior.ARcoeffHyperprior = [];
prior.VcHyperprior      = [];
prior.S_scaleHyperprior = [];
modelLR                 = setPrior(model,prior);

% Long run restrictions
H       = [ 1   1   1 ;  %Y+C+I
           -1   1   0 ;  %C-Y
           -1   0   1 ]; %I-Y 
phi     = ones(3,1);
modelLR = applyLongRunPriors(modelLR,H,phi);

% Optimizer options
optimizer        = 'fmincon';
optimset         = nb_getDefaultOptimset(optimizer);
optimset.Display = 'iter';

% Estimate
% Set draws to 1 to get the posterior mode, as the posterior has an
% analytical solution in this case!
modelLR = set(modelLR,...
    'constant',true,...
    'draws',1,...
    'empirical',true,... % Do empirical bayesian
    'hyperprior',true,...
    'optimizer',optimizer,...
    'optimset',optimset); 
modelLR = estimate(modelLR);
print(modelLR)
