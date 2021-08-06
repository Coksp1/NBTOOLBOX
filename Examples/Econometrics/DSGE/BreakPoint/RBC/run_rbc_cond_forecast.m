%% Help on this example

nb_dsge.help
help nb_dsge.addBreakPoint
help nb_dsge.simulate
help nb_dsge.filter

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

%% Forecast

filt = forecast(mFilt,10,'output','all');
p    = plotForecast(filt);
% nb_graphSubPlotGUI(p);

%% Forecast

condDB = nb_ts([1,0.3;1,0.3],'',sim.endDate + 1,{'e_a','i'});
SP     = struct('Name',{'e_i'},'Periods',2);
filt   = forecast(mFilt,10,'condDB',condDB,'shockProps',SP,'output','all');
pCond  = plotForecast(filt);
pBoth  = merge(p,pCond);
pBoth.set('startGraph','2000Q1');
nb_graphSubPlotGUI(pBoth);

%% Assign new parameter value after 2010Q1 (First period of forecast)

mBP = addBreakPoint(m,{'alpha'},0.2,'2010Q1');

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

%% Forecast

filt = forecast(mFilt,10,'output','all');
p    = plotForecast(filt);
% nb_graphSubPlotGUI(p);

%% Forecast
% Interpret conditional information given that the break did not happend. 
% This means that the forecast will not give what we condition on...

condDB = nb_ts([1,0.3;1,0.3],'',sim.endDate + 1,{'e_a','i'});
SP     = struct('Name',{'e_i'},'Periods',2);
filt   = forecast(mFilt,10,'condDB',condDB,'shockProps',SP,'output','all');
pCond  = plotForecast(filt);
pBoth  = merge(p,pCond);
pBoth.set('startGraph','2005Q1');
nb_graphSubPlotGUI(pBoth);

%% Forecast
% Interpret conditional information given that the break did happend. 

condDB = nb_ts([1,0.3;1,0.3],'',sim.endDate + 1,{'e_a','i'});
SP     = struct('Name',{'e_i'},'Periods',2);
filt   = forecast(mFilt,10,'condDB',condDB,'shockProps',SP,'output','all',...
                           'condAssumption','after');
pCond  = plotForecast(filt);
pBoth  = merge(p,pCond);
pBoth.set('startGraph','2005Q1');
nb_graphSubPlotGUI(pBoth);

%% Assign new parameter value after 2010Q2 (Second period of forecast)

mBP2 = addBreakPoint(m,{'alpha'},0.2,'2010Q2');

%% Solve model in both regimes

mBP2 = solve(mBP2);

%% Simulate the break-point model

sim = simulate(mBP2,80,'startDate','1990Q1','draws',1);
sim = sim.Model1;
p   = plot(sim,'graphSubPlots');
nb_graphSubPlotGUI(p);

%% Run Kalman filter

mFilt2 = set(mBP2,'data',sim);
mFilt2 = filter(mFilt2,'kf_method','normal');

%% Forecast

filt = forecast(mFilt2,10,'output','all');
p    = plotForecast(filt);
% nb_graphSubPlotGUI(p);

%% Forecast
% Interpret conditional information given that the break did not happend. 
% This means that the forecast will not give what we condition on...

condDB = nb_ts([1,0.3;1,0.3],'',sim.endDate + 1,{'e_a','i'});
SP     = struct('Name',{'e_i'},'Periods',2);
filt   = forecast(mFilt2,10,'condDB',condDB,'shockProps',SP,'output','all');
pCond  = plotForecast(filt);
pBoth  = merge(p,pCond);
pBoth.set('startGraph','2005Q1','legends',{'Uncond','cond'});
nb_graphSubPlotGUI(pBoth);

%% Forecast
% Interpret conditional information given that the break did happend. 

condDB = nb_ts([1,0.3;1,0.3],'',sim.endDate + 1,{'e_a','i'});
SP     = struct('Name',{'e_i'},'Periods',2);
filt   = forecast(mFilt2,10,'condDB',condDB,'shockProps',SP,'output','all',...
                           'condAssumption','after');
pCond  = plotForecast(filt);
pBoth  = merge(p,pCond);
pBoth.set('startGraph','2005Q1');
nb_graphSubPlotGUI(pBoth);

