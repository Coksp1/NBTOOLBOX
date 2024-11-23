%% Parse model

model = nb_dsge('nb_file','model.nb');

%% Add break point

model = addBreakPoint(model,{'lambda_c'},0.9,'2010Q1');

%% Assign parameters and solve

param.lambda_c = 0.7;
param.lambda_t = 0.5;
param.std_ec   = 1;
param.std_en   = 0.1;
param.std_et   = 1;
model          = assignParameters(model,param);
model          = solve(model);

%% Simulate

rng(1) % Set seed

vars = {'y','yc','yt','yn','cc'};
sim  = simulate(model,100,'draws',1,'startDate','1990Q1');
sim  = sim.Model1;
sim  = keepVariables(sim,vars);

%% Filter

model = set(model,'data',sim);
model = filter(model,...
    'kf_method','diffuse');

filt  = getFiltered(model);
filt  = keepVariables(filt,vars);

%% Plot

plotData = addPages(sim,filt);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','Filtered'});
nb_graphSubPlotGUI(plotter);

%% Estimate

% Set priors
priors                 = struct();
priors.lambda_c        = {0.5,0.7,0.2,'normal',0,1};
priors.lambda_c_2010Q1 = {0.5,0.9,0.2,'normal',0,1};
priors.lambda_t        = {0.5,0.5,0.2,'beta'};
priors.std_ec          = {0.9,1,10,'invgamma'};
priors.std_en          = {0.05,0.1,10,'invgamma'};
priors.std_et          = {0.7,1,10,'invgamma'};

% Estimate the model
mest = estimate(model,'prior',priors,'data',sim,...
    'kf_init_variance',1,'kf_presample',4,...
    'kf_method','diffuse');
print(mest)

% Run the kalman filter
mest = filter(mest,'kf_method','diffuse');
filt = getFiltered(mest);
filt = keepVariables(filt,vars);

%% Plot

plotData = addPages(sim,filt);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','Estimated'});
nb_graphSubPlotGUI(plotter);
