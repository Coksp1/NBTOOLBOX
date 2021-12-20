%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')

%% Recursive estimation
% Missing observations

simMissing              = sim; 
simMissing(1:5,2)       = NaN;
simMissing(end-1:end,3) = NaN;

% Options
t                            = nb_var.template();
t.data                       = simMissing;
t.dependent                  = {'VAR1','VAR2','VAR3'};
t.estim_method               = 'ml';
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = true;
t.recursive_estim_start_date = '2020M1';

% Create model and estimate
modelRec = nb_var(t);
modelRec = estimate(modelRec);
print(modelRec)

%% Solve

modelRecS = solve(modelRec);

%% Forecast

modelRecF = forecast(modelRecS,4,'fcstEval','SE');
plotter   = plotForecast(modelRecF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);
plotter   = plotForecast(modelRecF,'hairyplot');
nb_graphSubPlotGUI(plotter);
