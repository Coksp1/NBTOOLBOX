%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataQ   = convert(dataM,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data    = [dataQM,dataM];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-TVP-STVOL-B-VAR 

% Prior
prior = nb_mfvar.priorTemplate('kkse');

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


% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','VAR3','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'}; % Approximation
t.constant  = true;
t.nLags     = 5;
t.prior     = prior;
t.draws     = 500;
t.recursive_estim = 0;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Solve

modelS = solve(model);

%% Forecast

modelF  = forecast(modelS,4);
plotter = plotForecast(modelF);
% set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% Recursive estimation

% Options
t                 = nb_mfvar.template();
t.data            = data;
t.dependent       = {'VAR1','Q_VAR2'};
t.frequency       = {'Q_VAR2',4};
t.mapping         = {'Q_VAR2','diffAverage'}; % Approximation
t.constant        = true;
t.nLags           = 5;
t.prior           = prior;
t.draws           = 500;
t.recursive_estim = true;

% Create model and estimate
modelRec = nb_mfvar(t);
modelRec = estimate(modelRec);
print(modelRec)

%% Solve

modelRecS = solve(modelRec);
