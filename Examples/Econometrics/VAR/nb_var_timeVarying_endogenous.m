%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
sim     = sim + 2;
%nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Setup prior

prior = nb_var.priorTemplate('kkse');

% -------------------------- TVP and SV -----------------------------------
% Here we set l_2_endo_update and l_4_endo_update to true to update
% the forgetting factors endogenously during estimation of the model
%
% prior.l_2 and prior.l_4 are in this case the starting values of the 
% forgetting factors
%
% for more information type "help nb_var.priorTemplate"
% -------------------------------------------------------------------------
prior.l_2             = 0.9;
prior.l_4             = 0.9;
prior.l_2_endo_update = 1;
prior.l_4_endo_update = 1;
prior.V0VarScale      = 0.1;

%% TVP-STVOL-B-VAR 

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.prior      = prior;
t.constant   = true;
t.nLags      = 2;
t.constant   = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model) 

%% Solve

modelS = solve(model);

%% Forecast

modelF  = forecast(modelS,4);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% TVP-STVOL-B-VAR  
% Missing observations

simMissing              = sim; 
simMissing(1:5,2)       = NaN;
simMissing(end-7:end,3) = NaN;

% Options
t            = nb_var.template();
t.data       = simMissing;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;
t.constant   = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model) 

%% Solve

modelS = solve(model);

%% Forecast

modelF  = forecast(modelS,4);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% Recursive estimation

% Options
t                            = nb_var.template();
t.data                       = sim;
t.dependent                  = {'VAR1','VAR2','VAR3'};
t.prior                      = prior;
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = true;
t.recursive_estim_start_date = '2017M1';

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

%% Recursive estimation
% Missing observations

simMissing              = sim; 
simMissing(1:5,2)       = NaN;
simMissing(end-1:end,3) = NaN;

% Options
t                            = nb_var.template();
t.data                       = simMissing;
t.dependent                  = {'VAR1','VAR2','VAR3'};
t.prior                      = prior;
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = true;
% t.recursive_estim_start_date = '2020M1';

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
