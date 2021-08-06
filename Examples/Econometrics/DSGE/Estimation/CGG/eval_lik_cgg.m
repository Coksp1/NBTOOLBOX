%% Help on this example

nb_dsge.help
help nb_dsge.lik

%% Setup for likelihood evaluation

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
dataM = simulate(m,100,'draws',1,'burn',100);
data  = dataM.Model1;
data  = tonb_ts(data,'2012Q1');
m     = set(m,'data',data);

% Filtering options
m = set(m,...
'kf_init_variance', [],...
'kf_presample',     5);

%% Likelihood evaluation

lik = evalLikelihood(m);
