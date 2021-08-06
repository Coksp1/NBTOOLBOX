%% Help on this example

nb_dsge.help
help nb_dsge.priorPredictiveAnalysis

%% NB Toolbox; Setup for prior predictive analysis

plot = true;

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
param.theta     = 0.5;
param.varphi    = 0.8;
m               = assignParameters(m,param);
m               = solve(m);

% Priors
priors        = struct();
priors.theta  = {0.5, 0.5,0.2,'beta'};
priors.varphi = {0.8, 0.8,0.1,'normal'};
priors.phi    = {0.5, 0.5,0.2,'beta'};
priors.alpha  = {0.1,0,2}; % Uniform on 0 - 2!
m             = set(m,'prior',priors);

if plot
    plotter = plotPriors(m);
    nb_graphMultiGUI(plotter);
end

%% Prior predictive analysis; IRFs

[irfs,irfsBands,plotter] = priorPredictiveAnalysis(m,'irf',1000,false);

%% Plot error bands in each case

nb_graphInfoStructGUI(plotter);


%% Prior predictive analysis; IRFs
% With RMSD analysis

[irfs,irfsBands,plotter] = priorPredictiveAnalysis(m,'irf',1000,true);

%% Plot error bands in each case

nb_graphInfoStructGUI(plotter.prior);
nb_graphInfoStructGUI(plotter.theta);   % theta fixed at mean
nb_graphInfoStructGUI(plotter.varphi);  % varphi fixed at mean
nb_graphInfoStructGUI(plotter.phi);     % phi fixed at mean
nb_graphInfoStructGUI(plotter.alpha);   % alpha fixed at mean
