%% Simulate some ARIMA processes

rng(1) % Set seed

draws = randn(100,1);
x     = randn(100,1);
x2    = randn(100,1);
sim1  = ones(101,1);
for tt = 1:100
   sim1(tt+1) = 0.9*sim1(tt) + 0.5*x(tt) + draws(tt);
end
sim1 = sim1(2:end);

sim2  = ones(101,1);
for tt = 1:100
   sim2(tt+1) = 0.9*sim2(tt) + draws(tt);
end
sim2 = sim2(2:end) + 0.5*x2;

sim3  = ones(101,1);
for tt = 1:100
   sim3(tt+1) = 0.9*sim3(tt) + 0.5*x(tt) + draws(tt);
end
sim3 = sim3(2:end) + 0.5*x2;

% Transform to nb_ts object
data   = nb_ts([sim1,sim2,sim3,x,x2],'','2000Q1',...
                {'Sim1','Sim2','Sim3','x','x2'});
           
%% Help on the nb_arima class

nb_arima.help
help nb_arima.forecast

%% nb_arima

t                  = nb_arima.template;
t.algorithm        = 'ml';
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim2'};
t.exogenous        = {'x2'};
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% nb_arima

t                  = nb_arima.template;
t.algorithm        = 'ml';
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim1'};
t.exogenous        = {'x'};
t.transition       = true;
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% nb_arima

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim1'};
t.exogenous        = {'x'};
t.transition       = true;
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;

model = nb_arima(t);
model = estimate(model);
print(model)

%% Solve AR model

modelS = solve(model);

%% Unconditional forecast (point)

modelF  = forecast(modelS,8,'exoProj','ar','output','all');
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% nb_arima

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;

model = nb_arima(t);
model = estimate(model);
print(model)

%% nb_arima

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim3'};
t.exogenous        = {'x2','x'};
t.transition       = [false,true];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;

model = nb_arima(t);
model = estimate(model);
print(model)

%% Solve AR model

modelS = solve(model);

%% Unconditional forecast (point)

modelF  = forecast(modelS,8,'exoProj','ar','output','all');
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);
