%% Help on this example

nb_dsge.help('stochasticTrend')
help nb_dsge.simulate
help nb_dsge.estimate

%% Parse model

rbcObs = nb_dsge('nb_file','rbc_obs.nb',...
                 'name','RBC OBS',...
                 'steady_state_file','rbc_steadystate',...
                 'stochasticTrend',true);
param  = rbc_param(2);
rbcObs = assignParameters(rbcObs,param);   

%% Solve model
% With observation model

rbcObs = solve(rbcObs);

%% Set the starting point of observation block

ss         = getSteadyState(rbcObs,'','struct');
c_share    = ss.c/ss.y;
i_share    = ss.i/ss.y;
init       = struct();
init.y_det = 1;
init.y_obs = init.y_det;
init.c_det = log(c_share) + init.y_det;
init.c_obs = init.c_det;
init.i_det = log(i_share) + init.y_det;
init.i_obs = init.i_det;
rbcObs     = set(rbcObs,'stochasticTrendInit',init);

%% Simulate model

plotS = false;

sim = simulate(rbcObs,100,'draws',1,'startDate','1990Q1','output','all');
sim = sim.Model1;
sim = createVariable(sim,rbcObs.reporting(:,1),rbcObs.reporting(:,2));
if plotS
    nb_graphSubPlotGUI(sim);
end

%% Estimate some parameters

plotP = false;

% Priors
priors       = struct();
priors.alpha = {0.4,  0.6,  0.1,'normal'};
rbcObsEstP   = set(rbcObs,'prior',priors);

% Filtering options
rbcObsEstP = set(rbcObsEstP,...
'kf_init_variance', [],...
'kf_method',        'diffuse',...
'kf_presample',     5);

if plotP
    plotter = plotPriors(rbcObsEstP);
    nb_graphMultiGUI(plotter);
end

%% Assign data and observables

rbcObsEstP = set(rbcObsEstP,...
    'data',         sim,...
    'observables',  {'c_obs','i_obs','y_obs'});

%% Mode estimatation
clc
optimizer   = 'nb_abc';
opt         = nb_getDefaultOptimset(optimizer);
% opt.Display = 'iter';
opt.maxTime = 60*35;
rbcObsEstP   = estimate(rbcObsEstP,...
    'optimset',opt,...
    'optimizer',optimizer,...
    'estim_steady_state_solve',true);
rbcObsEstP.print

%% Solve the estimated version 
% This is not done in the estimate method!!

rbcObsEstP = solve(rbcObsEstP);

%% Tell the model that the inital condition parameters can be estimated 
% We need to do this as they are only used in the function given to the
% 'stochasticTrendInit' option

rbcObs = setParametersInUse(rbcObs,...
    {'c_det_init','i_det_init','y_det_init'});

%% Estimate the starting point of observation block

plotP = false;

% Priors
priors            = struct();
priors.c_det_init = {0.3,  0.3,  0.01,'normal'};
priors.i_det_init = {0.08, 0.08, 0.01,'normal'};
priors.y_det_init = {1,    1,    0.01,'normal'};
rbcObsEst         = set(rbcObs,'prior',priors);

% Filtering options
rbcObsEst = set(rbcObsEst,...
'kf_init_variance', [],...
'kf_presample',     5,...
'stochasticTrendInit','rbc_init');

if plotP
    plotter = plotPriors(rbcObsEst);
    nb_graphMultiGUI(plotter);
end

%% Assign data and observables

rbcObsEst = set(rbcObsEst,...
    'data',         sim,...
    'observables',  {'c_obs','i_obs','y_obs'});

%% Mode estimatation

opt         = nb_getDefaultOptimset('nb_abc');
opt.maxTime = 60*60*6;
rbcObsEst   = estimate(rbcObsEst,...
    'optimset',opt,...
    'optimizer','nb_abc',...
    'estim_steady_state_solve',true);
rbcObsEst.print

%% Solve the estimated version 
% This is not done in the estimate method!!

rbcObsEst = solve(rbcObsEst);
