%% Help on this example

nb_singleEq.help

%% Generate artificial data

rng(1) % Set seed

draws  = randn(100,1)*4;
sim1   = filter(1,[1,-1],draws); % ARIMA(1,0,0)
simexo = [0.3;nan(100-1,1)];
for tt = 2:100
    simexo(tt) = 0.7*simexo(tt-1) + randn;
end
sim2  = [0.3;nan(100-1,1)];
for tt = 2:100
    sim2(tt) = 1*sim2(tt-1) + simexo(tt) + randn;
end
sim3 = [0.3;nan(100-1,1)];
for tt = 2:100
    sim3(tt) = 0.2 + 1*sim3(tt-1) + randn;
end

% Transform to nb_ts object
data     = nb_ts([sim1,simexo,sim2,sim3],'','2000Q1',{'VAR','EXO','VAR_EXO_DRIFT','VAR_DRIFT'});

%% Random walk

t           = nb_rw.template();
t.data      = data;
t.dependent = {'VAR'};
rwModel     = nb_rw(t);
rwModel     = estimate(rwModel);
print(rwModel)

% Solve model
rwModel     = solve(rwModel);

% Produce point forecast
rwModel     = forecast(rwModel,4);
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);

% Produce point forecast
rwModel     = forecast(rwModel,4,'parameterDraws',500,'draws',2);
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);

%% Random walk
% with drift

t           = nb_rw.template();
t.data      = data;
t.dependent = {'VAR_DRIFT'};
t.constant  = 1;
rwModel     = nb_rw(t);
rwModel     = estimate(rwModel);
print(rwModel)

% Solve model
rwModel     = solve(rwModel);

% Produce point forecast
rwModel     = forecast(rwModel,4);
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);

% Produce point forecast
rwModel     = forecast(rwModel,4,'parameterDraws',500,'draws',2);
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);

%% Random walk
% with exogenous forcing variable

t           = nb_rw.template();
t.data      = data;
t.dependent = {'VAR_EXO_DRIFT'};
t.exogenous = {'EXO'};
t.constant  = 0;
rwModel     = nb_rw(t);
rwModel     = estimate(rwModel);
print(rwModel)

% Solve model
rwModel     = solve(rwModel);

% Produce point forecast
rwModel     = forecast(rwModel,4,'exoProj','ar');
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);

% Produce point forecast
rwModel     = forecast(rwModel,4,'parameterDraws',500,'draws',2,'exoProj','ar');
plotter     = plotForecast(rwModel);
plotter.set('startGraph','2015Q1')
nb_graphSubPlotGUI(plotter);
