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
cy = window(y,'2009Q1');
y  = window(y,'','2008Q4');
mr = set(mr,'data',y);

%% Filter

mr = filter(mr);

%% Forecast

modelF  = forecast(mr,8,'startDate',y.endDate + 1,...
            'output','all');
plotter = plotForecast(modelF);
set(plotter,'startGraph','2000Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional forecast

SP      = struct('Name',mr.solution.res,...
                 'Periods',4);
modelCF = forecast(mr,8,'startDate',y.endDate + 1,...
                   'condDB',cy,'output','all','shockProps',SP);
plotter = plotForecast(modelCF);
set(plotter,'startGraph','2000Q1')
nb_graphSubPlotGUI(plotter);

%% Anticipated Conditional forecast

% Solve model with anticipated shocks
SP = struct('Name',mr.solution.res,...
            'Periods',4,...
            'Horizon',4);
mra = solve(mr,4,SP);             
             
% Conditional forecast with anticipated shocks             
modelACF = forecast(mra,8,'startDate',y.endDate + 1,...
                   'condDB',cy,'output','all','shockProps',SP);
plotter = plotForecast(modelACF);
set(plotter,'startGraph','2000Q1')
nb_graphSubPlotGUI(plotter);

%% Discounted Anticipated Conditional forecast

% Solve model with discounted anticipated shocks
SP = struct('Name',mr.solution.res,...
            'Periods',4,...
            'Horizon',4,...
            'Discount',0.5);
mrad = solve(mr,4,SP);             
             
% Conditional forecast with discounted anticipated shocks             
modelDACF = forecast(mrad,8,'startDate',y.endDate + 1,...
                   'condDB',cy,'output','all','shockProps',SP);
plotter = plotForecast(modelDACF);
set(plotter,'startGraph','2000Q1')
nb_graphSubPlotGUI(plotter);
