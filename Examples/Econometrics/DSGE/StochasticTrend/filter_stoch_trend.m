%% Help on this example

nb_dsge.help('stochasticTrend')
help nb_dsge.simulate
help nb_dsge.filter

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

sim = simulate(rbcObs,100,'draws',1,'startDate','1990Q1','output','all');
sim = sim.Model1;
sim = createVariable(sim,rbcObs.reporting(:,1),rbcObs.reporting(:,2));

%% Plot simulated series

p = nb_graph_ts(sim);
p.set('subPlotSize',[3,3],'spacing',20);
nb_graphSubPlotGUI(p);

%% Estimate the starting point of observation block

simObs     = window(sim,'','',{'c_obs','i_obs','y_obs'});
simTrend   = simObs - detrend(simObs,'linear1s');
simTrend   = simTrend(1,:);
init       = struct();
init.y_det = double(simTrend('y_obs'));
init.y_obs = init.y_det;
init.c_det = double(simTrend('c_obs'));
init.c_obs = init.c_det;
init.i_det = double(simTrend('i_obs'));
init.i_obs = init.i_det;
rbcObs     = set(rbcObs,'stochasticTrendInit',init);

%% Filter the data

rbcObs = set(rbcObs,'data',sim,'observables',{'c_obs','i_obs','y_obs'});
rbcObs = filter(rbcObs,'kf_method','univariate');

updated = getFiltered(rbcObs,'updated');
updated = createVariable(updated,rbcObs.reporting(:,1),rbcObs.reporting(:,2));

smoothed = getFiltered(rbcObs,'smoothed');
smoothed = createVariable(smoothed,rbcObs.reporting(:,1),rbcObs.reporting(:,2));

%% Plot

plotData = addPages(sim,updated,smoothed);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','Updated','Smoothed'});
nb_graphSubPlotGUI(plotter);

%% Filter with more observables

rbcObs = set(rbcObs,'data',sim,'observables',{'c_obs','i_obs','y_obs','l_obs'});
rbcObs = filter(rbcObs,'kf_method','univariate');

smoothed2 = getFiltered(rbcObs,'smoothed');
smoothed2 = createVariable(smoothed2,rbcObs.reporting(:,1),rbcObs.reporting(:,2));

%% Plot

plotData = addPages(sim,smoothed,smoothed2);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','smoothed1','smoothed2'});
nb_graphSubPlotGUI(plotter);
