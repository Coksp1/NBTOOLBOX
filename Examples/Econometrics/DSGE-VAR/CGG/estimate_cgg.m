%% Help on this example

nb_dsge.help
help nb_dsge.estimate

%% Number of lags of the VAR

nLags = 4;

%% Solve DSGE model

plotP = false;

% Parse model
m = nb_dsge('nb_file','cgg_rule.nb','silent',false);

% Calibration
param           = struct();
param.alpha     = 0.1;
param.beta      = 1;
param.gamma_eps = 0;
param.gamma_eta = 0;
param.gamma_i   = 0.8;
param.gamma_pie = 1.2;
param.gamma_y   = 0.338;
param.phi       = 0.5;
param.std_e     = 0.01;
param.std_eps   = 0.01;
param.std_eta   = 0.01;
param.theta     = 0.5;
param.varphi    = 0.8;
m               = assignParameters(m,param);

% Simulate som data to estimate the model on
m     = solve(m);
dataM = simulate(m,100,'draws',1,'burn',100,'seed',1);
data  = dataM.Model1;
data  = tonb_ts(data,'2012Q1');

%% Setup DSGE-VAR

t           = nb_var.template();
t.constant  = 0;
t.data      = data;
t.dependent = m.dependent.name;
t.draws     = 1;
t.nLags     = nLags;
model       = nb_var(t);

%% Setup priors

[GammaYY,GammaXX,GammaXY] = getDSGEVARPriorMoments(m,model);

prior         = nb_var.priorTemplate('dsge');
prior.lambda  = 1;
prior.GammaYY = GammaYY;
prior.GammaXX = GammaXX;
prior.GammaXY = GammaXY;

model = set(model,'prior',prior);

%% Estimate DSGE-VAR

model = estimate(model);
print(model)

%% Estimate DSGE-VAR
% Mean of posterior draws

modelD = set(model,'draws',1000);
modelD = estimate(modelD);
print(modelD)

%% Estimate DSGE-VAR
% Empirical bayesian

modelEMP = set(model,'empirical',true);
modelEMP = estimate(modelEMP);
print(modelEMP)

%% Estimate on random data

% Calibration another model
param.theta = 0.1;
param.phi   = 0.1;
m2          = assignParameters(m,param);

m2    = solve(m2);
dataM = simulate(m2,100,'draws',1,'burn',100);
data2 = dataM.Model1;
data2 = tonb_ts(data2,'2012Q1');

modelEMPSim = set(modelEMP,'data',data2);
modelEMPSim = estimate(modelEMPSim);
print(modelEMPSim)
