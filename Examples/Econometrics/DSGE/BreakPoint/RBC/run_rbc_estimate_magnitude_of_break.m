%% Help on this example

help nb_dsge.addBreakPoint
help nb_dsge.simulate
help nb_dsge.estimate

%% Parse model 

m = nb_dsge('nb_file','rbc_stoch2.nb','silent',false,...
            'steady_state_file','rbc_steadystate');

%% Assign baseline calibration

p       = struct();
p.alpha = 0.17;
p.beta  = 0.999;
p.delta = 0.1;
p.rho_a = 0.5;
p.rho_i = 0.7;
p.rho_y = 0.2;
p.std_a = 0.1;
p.std_i = 0.15;
p.std_y = 0.05;
m       = assignParameters(m,p);

%% Assign new parameter value after 2000Q1

mBP = addBreakPoint(m,{'alpha'},0.2,'2000Q1');

%% Solve model in both regimes

mBP = solve(mBP);

%% Simulate the break-point model

sim = simulate(mBP,80,'startDate','1990Q1','draws',1);
sim = sim.Model1;
p   = plot(sim,'graphSubPlots');
nb_graphSubPlotGUI(p);

%% Estimate the magnitude of the break-point

% Priors
priors              = struct();
priors.alpha_2000Q1 = {0.17, 0.1,0.3,'uniform'};
mBPEst              = set(mBP,'prior',priors);

% Filtering options
mBPEst = set(mBPEst,...
'kf_init_variance', [],...
'kf_presample',     5);

% PLot prior
plotter = plotPriors(mBPEst);
nb_graphMultiGUI(plotter);

%% Mode estimatation

mBPEst = set(mBPEst,'data',sim);
mBPEst = estimate(mBPEst,'optimizer','fmincon');
mBPEst.print

%% Solve the estimated version 
% (This is not done in the estimate method!!)

mBPEst = solve(mBPEst);

%% Run Kalman filter

mBPEst = filter(mBPEst,'kf_method','normal');

%% Plot smoothed

smoothed = getFiltered(mBPEst,'smoothed');
both     = addPages(smoothed,sim);
p        = nb_graph_ts(both);
p.set('legends',{'Smoothed','Simulated'})
nb_graphSubPlotGUI(p);

%% Shock decompose updated 

[~,~,p] = shock_decomposition(mBPEst,'type','updated');
nb_graphPagesGUI(p);

