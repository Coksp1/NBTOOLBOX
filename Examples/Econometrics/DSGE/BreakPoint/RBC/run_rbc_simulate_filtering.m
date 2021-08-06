%% Help on this example

nb_dsge.help
help nb_dsge.addBreakPoint
help nb_dsge.simulate
help nb_dsge.filter
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

%% Solve model

m = solve(m);

%% Simulate time-series from the model

sim = simulate(m,80,'startDate','1990Q1','draws',1);
sim = sim.Model1;
p   = plot(sim,'graphSubPlots');
nb_graphSubPlotGUI(p);

%% Run Kalman filter

mFilt = set(m,'data',sim);
mFilt = filter(mFilt,'kf_method','normal');

%% Plot filtered

filt = getFiltered(mFilt,'filtered');
both = addPages(filt,sim);
p    = nb_graph_ts(both);
p.set('legends',{'Filtered','Simulated'})
nb_graphSubPlotGUI(p);

%% Plot updated

updated = getFiltered(mFilt,'updated');
both    = addPages(updated,sim);
p       = nb_graph_ts(both);
p.set('legends',{'Updated','Simulated'})
nb_graphSubPlotGUI(p);

%% Plot smoothed

smoothed = getFiltered(mFilt,'smoothed');
both     = addPages(smoothed,sim);
p        = nb_graph_ts(both);
p.set('legends',{'Smoothed','Simulated'})
nb_graphSubPlotGUI(p);

%% Assign new parameter value after 2000Q1

mBP = addBreakPoint(m,{'alpha'},0.2,'2000Q1');

%% Solve model in both regimes

mBP = solve(mBP);

%% Simulate the break-point model

sim = simulate(mBP,80,'startDate','1990Q1','draws',1);
sim = sim.Model1;
p   = plot(sim,'graphSubPlots');
nb_graphSubPlotGUI(p);

%% Run Kalman filter

mFilt = set(mBP,'data',sim);
mFilt = filter(mFilt,'kf_method','normal');

%% Plot filtered

filt = getFiltered(mFilt,'filtered');
both = addPages(filt,sim);
p    = nb_graph_ts(both);
p.set('legends',{'Filtered','Simulated'})
nb_graphSubPlotGUI(p);

%% Plot updated

updated = getFiltered(mFilt,'updated');
both    = addPages(updated,sim);
p       = nb_graph_ts(both);
p.set('legends',{'Updated','Simulated'})
nb_graphSubPlotGUI(p);

%% Plot smoothed

smoothed = getFiltered(mFilt,'smoothed');
both     = addPages(smoothed,sim);
p        = nb_graph_ts(both);
p.set('legends',{'Smoothed','Simulated'})
nb_graphSubPlotGUI(p);

%% Shock decompose updated 

[~,~,p] = shock_decomposition(mFilt,'type','updated');
nb_graphPagesGUI(p);
