%% Help on this example

nb_dsge.help
help nb_dsge.mcfRestriction
help nb_dsge.monteCarloFiltering

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

%% Monte carlo filtering

% Create filtering function
restriction = {'e','y',1:2,@(x)lt(x,0)};
f           = mcfRestriction(m,'irf',restriction);

% Do monte carlo filtering
params = {'gamma_pie','gamma_y'};
lb     = [0,0];
ub     = [2,2];

[paramD,values] = monteCarloFiltering(m,...
    'draws',        100,...
    'func',         f,...
    'parameters',   params,...
    'lowerBound',   lb,...
    'upperBound',   ub);

%% Plot all in one

plotter = nb_model_generic.plotMCF(paramD(values,:),params,lb,ub);
nb_graphPagesGUI(plotter);

%% Plot bi-plots

plotter = nb_model_generic.plotMCF(paramD(values,:),params,lb,ub,'biplot');
nb_graphMultiGUI(plotter);

%% Monte carlo filtering
% For which values of gamma_pie, holding all other parameters fixed, does
% the model solve?

% Do monte carlo filtering
params = {'gamma_pie'};
lb     = 0;
ub     = 2;

[paramD,~,solvingFailed] = monteCarloFiltering(m,...
    'draws',        100,...
    'func',         @(x)true,... % Always return true!
    'parameters',   params,...
    'lowerBound',   lb,...
    'upperBound',   ub);

% Plot results
plotter = nb_model_generic.plotMCFValues(paramD,params,...
            ~solvingFailed,'Solved');
nb_graphMultiGUI(plotter);

%% Monte carlo filtering
% For which values of gamma_y, holding all other parameters fixed, does
% the model solve?

% Do monte carlo filtering
params = {'gamma_y'};
lb     = 0;
ub     = 40;

[paramD,~,solvingFailed] = monteCarloFiltering(m,...
    'draws',        500,...
    'func',         @(x)true,... % Always return true!
    'parameters',   params,...
    'lowerBound',   lb,...
    'upperBound',   ub);

% Plot results
plotter = nb_model_generic.plotMCFValues(paramD,params,...
            ~solvingFailed,'Solved');
nb_graphMultiGUI(plotter);

%% Monte carlo filtering

% Create filtering function
restriction = {'e','y',1:2,@(x)lt(x,0)};
f           = mcfRestriction(m,'irf',restriction);

% Do monte carlo filtering
params = {'gamma_pie','gamma_y'};
lb     = [0,0];
ub     = [2,2];

[paramD,solves] = monteCarloFiltering(m,...
    'draws',        100,...
    'func',         @(x)true,... % Will give us the parameter sets where the model solves!
    'parameters',   params,...
    'lowerBound',   lb,...
    'upperBound',   ub);

% CDF plots, with Cucconi
plotter = nb_model_generic.plotMCFDistTest(paramD,params,...
            solves);
nb_graphMultiGUI(plotter);

% Smirnov plot Smirnov
plotter = nb_model_generic.plotMCFDistTest(paramD,params,...
            solves,'Smirnov');
nb_graphMultiGUI(plotter);

