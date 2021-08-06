%% Help on this example

help nb_dsge.addBreakPoint
help nb_dsge.simulate
help nb_dsge.estimate

%% Parse model 

% Good inital values is important for ood speed during estimation
% Here I use the solution of the inital regime gotten from the
% analytical solution
init = struct(...
    'z_y',0,...
    'z_i',0,...
    'y',1.1125,...
    'k_gap',0,...
    'k',1.8726,...
    'i',0.1873,...
    'c',0.9253,...
    'a',0 ...
);

% Display slow estimation down a lot, so we
% turn it off...
opt         = nb_getDefaultOptimset('fsolve');
opt.Display = 'off';

m = nb_dsge('nb_file','rbc_stoch2.nb','silent',false);

% Set options for numerical solving of the steady state
m = set(m,'steady_state_optimset',opt,...
          'steady_state_debug',true,...
          'steady_state_init',init,...
          'steady_state_file','',...
          'steady_state_solve',true);

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
mBPEstN             = set(mBP,'prior',priors);

% Filtering options
mBPEstN = set(mBPEstN,...
'kf_init_variance', [],...
'kf_presample',     5);

% PLot prior
plotter = plotPriors(mBPEstN);
nb_graphMultiGUI(plotter);

%% Mode estimatation

mBPEstN = set(mBPEstN,'data',sim);
mBPEstN = estimate(mBPEstN,'optimizer','fmincon');
mBPEstN.print                
