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

y  = simulate(mr,40,'draws',1,'seed',2);
y  = y.taylor;
y  = tonb_ts(y,'2000Q1');
y  = deleteVariables(y,'r');
mr = set(mr,'data',y);

%% Filter

mr = filter(mr);

%% Unconditional forecast

mr       = forecast(mr,8,'output','all');
plotterU = plotForecast(mr);
plotterU.set('subPlotSize',[3,3],'startGraph','2008Q1')
% nb_graphSubPlotGUI(plotterU);

%% Conditional forecast, exogenous

condDB  = nb_ts([-6;zeros(7,1)],'',y.endDate + 1,'eps');
mr      = forecast(mr,8,'condDB',condDB,'output','all');
plotter = plotForecast(mr);
plotter.set('subPlotSize',[3,3],'startGraph','2008Q1')
% nb_graphSubPlotGUI(plotter);

%% Conditional forecast, exogenous

bounds.i = struct('shock','e','lower',-3);
condDB   = nb_ts([-6;zeros(7,1)],'',y.endDate + 1,'eps');
mr       = forecast(mr,8,'condDB',condDB,'output','all','bounds',bounds);
plotterB = plotForecast(mr);
plotterB.set('subPlotSize',[3,3],'startGraph','2008Q1')
% nb_graphSubPlotGUI(plotterB);

%% Plot in same figure

plotterM = merge(plotterU,plotter,plotterB);
plotterM.set('legends',{'Uncond','Condexo','Condexo (bounded)'});
nb_graphSubPlotGUI(plotterM);

%% Conditional forecast, endogenous

condDB     = nb_ts([-6;nan(7,1)],'',y.endDate + 1,'y');
shockProps = struct('Name','eps','Horizon',1,'Periods',1);
mr         = forecast(mr,8,'condDB',condDB,'shockProps',shockProps,...
                'output','all');
plotter    = plotForecast(mr);
plotter.set('subPlotSize',[3,3],'startGraph','2008Q1')
% nb_graphSubPlotGUI(plotter);

%% Conditional forecast, endogenous, bounded

bounds.i   = struct('shock','e','lower',-3);
condDB     = nb_ts([-6;nan(7,1)],'',y.endDate + 1,'y');
shockProps = struct('Name','eps','Horizon',1,'Periods',1);
mr         = forecast(mr,8,'condDB',condDB,'shockProps',shockProps,...
                'output','all','bounds',bounds);
plotterB    = plotForecast(mr);
plotterB.set('subPlotSize',[3,3],'startGraph','2008Q1')
% nb_graphSubPlotGUI(plotterB);

%% Plot in same figure

plotterM = merge(plotterU,plotter,plotterB);
plotterM.set('legends',{'Uncond','Condendo','Condendo (bounded)'});
nb_graphSubPlotGUI(plotterM);
