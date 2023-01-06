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
help nb_var.priorTemplate

%% Setup prior

prior = nb_var.priorTemplate('horseshoe');

%% B-VAR (Horseshoe prior)

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 500; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Solve model, point forecast and evaluate

model   = solve(model);
model   = forecast(model,8,'fcstEval','SE');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model, density forecast and evaluate

model = solve(model);
model = forecast(model,8,...
            'draws',1,'parameterDraws',1000,...
            'perc',[0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Identify model

model = set_identification(model,'cholesky',...
            'ordering',{'VAR1','VAR2','VAR3'});
model = solve(model);

%% Produce irfs 
% With error bands using posterior draws

[~,~,plotter] = irf(model,'replic',100,'perc',0.68);
nb_graphInfoStructGUI(plotter);

%% Recursive estimation

% Options
t                 = nb_var.template();
t.data            = sim;
t.dependent       = {'VAR1','VAR2','VAR3'};
t.draws           = 1000; % Return posterior mean estimate (using posterior sim)
t.prior           = prior;
t.constant        = false;
t.nLags           = 2;
t.draws           = 1000;
t.recursive_estim = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Recursive estimation
% Parallel (not efficient in this case)

% Options
t                 = nb_var.template();
t.data            = sim;
t.dependent       = {'VAR1','VAR2','VAR3'};
t.draws           = 1000; % Return posterior mean estimate (using posterior sim)
t.prior           = prior;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = true;
t.parallel        = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Recursive estimation
% Missing observations

simMissing              = sim; 
simMissing(1:5,2)       = NaN;
simMissing(end-1:end,3) = NaN;

% Options
t                            = nb_var.template();
t.data                       = simMissing;
t.dependent                  = {'VAR1','VAR2','VAR3'};
t.prior                      = nb_var.priorTemplate('horseshoe');
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = true;
t.draws                      = 1000;
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

%% Density forecast

modelRecDensF = forecast(modelRecS,4,'fcstEval','SE',...
    'draws',1,'parameterDraws',1000);
plotter   = plotForecast(modelRecDensF,'default','2020M2');
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);
plotter   = plotForecast(modelRecDensF,'default','2020M3');
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);
