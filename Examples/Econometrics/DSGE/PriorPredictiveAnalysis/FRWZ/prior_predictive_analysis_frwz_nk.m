%% Help on this example

nb_dsge.help
help nb_dsge.priorPredictiveAnalysis

%% Setup for prior predictive analysis
% Reference: Foerster, Rubio-Ramirez, Waggoner and Zha (2013)
% Perturbation Methods for Markov Switching Models.

plot = true;

% Parse
m = nb_dsge('nb_file','frwz_nk.nb');

% Assign parameters
p.betta = 0.99;
p.kappa = 161;
p.eta   = 10;
p.rhor  = 0.8;
p.sigr  = 0.0025;
p.mu    = 0.03;
p.psi   = 3.1;
m       = assignParameters(m,p);

% Check steady-state solution provided by a file
m = checkSteadyState(m,'steady_state_file','frwz_nk_nb_steadystate');
m = solve(m);

% Priors
priors        = struct();
priors.kappa  = {161, 160,40,'normal'};
priors.eta    = {10, 10,0.5,'normal'};
m             = set(m,'prior',priors);

if plot
    plotter = plotPriors(m);
    nb_graphMultiGUI(plotter);
end

%% Prior predictive analysis; IRFs

[irfs,irfsBands,plotter] = priorPredictiveAnalysis(m,'irf',1000,true,...
                                'fanPerc',[0.3,0.5,0.7,0.9,0.99]);

%% Plot error bands in each case

nb_graphInfoStructGUI(plotter.prior);
nb_graphInfoStructGUI(plotter.kappa);   % kappa fixed at mean
nb_graphInfoStructGUI(plotter.eta);     % eta fixed at mean

%% Prior predictive analysis; "Multiplier"

mult = priorPredictiveAnalysis(m,'calculateMultipliers',1000,true,...
            'variables',{'PAI'},'instrument','Y','rate','RR',...
            'shocks',{'EPS_R'});
nb_plotPPAMultipliers(mult,'EPS_R','PAI',[0.3,0.5,0.7,0.9,0.99]);
