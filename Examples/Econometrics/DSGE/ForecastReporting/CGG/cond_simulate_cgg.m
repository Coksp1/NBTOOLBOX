%% Help on this example

nb_dsge.help
help nb_dsge.simulate

%% Model with rule

mr = nb_dsge('nb_file','cgg_rule.nb','silent',false,'name','taylor');

% Parameterization
param           = struct();
param.alpha     = 0.1;
param.beta      = 1;
param.gamma_eps = 0;
param.gamma_eta = 0;
param.gamma_i   = 0;
param.gamma_pie = 1.2;
param.gamma_y   = 0.338;
param.phi       = 0.5;
param.theta     = 0.5;
param.varphi    = 0.8;
mr              = assignParameters(mr,param);
mr              = solve(mr);

%% Simulate and assign as data

y  = simulate(mr,40,'draws',1);
y  = y.taylor;
y  = tonb_ts(y,'2000Q1');
y  = deleteVariables(y,'r');
mr = set(mr,'data',y);

%% Filter

mr = filter(mr);

%% Forecast

mr      = forecast(mr,8);
plotter = plotForecast(mr);
nb_graphSubPlotGUI(plotter);

%% Reported variables

rep     = {'r_2','r*2',''};
mrr     = set(mr,'reporting',rep);
mrr     = checkReporting(mrr);
mrr     = forecast(mrr,8);
plotter = plotForecast(mrr);
nb_graphSubPlotGUI(plotter);

