%% Help on this example

nb_dsge.help
help nb_dsge.estimate

%% Setup for estimation

plotP = false;

% Parse model
m = nb_dsge('nb_file','cgg_rule.nb','silent',false,'name','Model1');

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

% Priors
priors           = struct();
priors.gamma_pie = {1.2, 1.2,0.2,'normal'};
priors.gamma_i   = {0.6, 0.5,0.2,'beta'};
priors.gamma_y   = {0.338,0.4,1,'normal'};
priors.std_eps   = {0.01,0.01,1,'invgamma'};
m                = set(m,'prior',priors);

% Filtering options
m = set(m,...
'kf_init_variance', [],...
'kf_presample',     5);

if plotP
    plotter = plotPriors(m);
    nb_graphMultiGUI(plotter);
end

%% Mode estimation

saveName = [cd,filesep,'tempRes'];
optimset = nb_abc.optimset('saveTime',10,'maxTime',12,'saveName',saveName);

me = estimate(m,'optimizer','nb_abc','optimset',optimset,...
                'estim_steady_state_solve',false);

%% Restart estimation

optimizer                 = nb_load('tempRes.mat');
optimizer.maxTime         = 100;
optimizer.saveTime        = inf;
[x,fval,exitflag,hessian] = restart(optimizer);
paramNames                = optimizer.displayer.names;

%% Solve the estimated version 
% This is not done in the estimate method!!

mes = solve(me);
