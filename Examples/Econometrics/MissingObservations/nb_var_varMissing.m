%% Get help on the nb_var class

% nb_var.help
nb_var.help('estim_method')

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
data    = nb_ts.simulate('1990Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(data);

%% Test VAR (OLS)

% Options
t              = nb_var.template();
t.data         = data;
t.estim_method = 'ols';
t.dependent    = {'VAR1','VAR2','VAR3'};
t.constant     = true;
t.nLags        = 2;
t.doTests      = 1;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Maximum likelihood)

% Options
t              = nb_var.template();
t.data         = data;
t.estim_method = 'ml';
t.dependent    = {'VAR1','VAR2','VAR3'};
t.constant     = true;
t.nLags        = 2;
t.doTests      = 1;
t.optimizer    = 'fmincon';
t.covrepair    = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Maximum likelihood) 
% with missing observations

dataM = setValue(data,'VAR1',nan,data.endDate,data.endDate);

% Options
t              = nb_var.template();
t.data         = dataM;
t.estim_method = 'ml';
t.dependent    = {'VAR1','VAR2','VAR3'};
t.constant     = true;
t.nLags        = 2;
t.doTests      = 1;
t.optimizer    = 'fmincon';
t.covrepair    = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Get smoothed estimates of the missing value

smoothed = getFiltered(model);
smoothed.window(data.endDate,data.endDate,'VAR1') % Smoothed estimate
data.window(data.endDate,data.endDate,'VAR1') % Actual

%% Draw from the parameter distribution
% Draw parameters using asymptotic normality assumption and numerically
% calculated Hessian from ML estimation. Do not draw from the distribution
% of the std of the residual.
%
% If the model include missing observation these are observations are
% re-estimated using the Kalman filter for each draw from the confidence
% set of the parameters.
%
% For more see the function nb_mlEstimator.drawParameters

modelS   = solve(model);
param    = parameterDraws(modelS,1000,'asymptotic');
solution = parameterDraws(modelS,1000,'asymptotic','solution');
models   = parameterDraws(modelS,1000,'asymptotic','object');

%% Solve model and forecast
% Here we do not return nowcast, due to missingMethod not used!
%
% This means that the smoothed estimates will appear as history in the 
% graph. This will be updated in a future release.

model   = solve(model);
model   = forecast(model,8);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast
% Here we do not return nowcast, due to missingMethod not used!

model = solve(model);
model = forecast(model,8,...
    'method',           'asymptotic',...
    'draws',            2,...
    'parameterDraws',   500,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Test VAR (Minnesota; Normal-Wishart type) 
% without missing observations

% Prior
prior        = nb_var.priorTemplate('minnesota');
prior.method = 'mci';

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Minnesota; Normal-Wishart type) 
% with missing observations

dataM = setValue(data,'VAR1',nan,data.endDate,data.endDate);

% Prior
prior        = nb_var.priorTemplate('minnesotaMF');
prior.method = 'mci';

% Options
t           = nb_var.template();
t.data      = dataM;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Get smoothed estimates of the missing value

smoothed = getFiltered(model);
smoothed.window(data.endDate,data.endDate,'VAR1') % Smoothed estimate
data.window(data.endDate,data.endDate,'VAR1') % Actual

%% Test VAR (Minnesota; Independent Normal-Wishart type) 
% without missing observations

% Prior
prior         = nb_var.priorTemplate('minnesota');
prior.method  = 'inwishart';
prior.S_scale = 1;

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Test VAR (Minnesota; Independent Normal-Wishart type) 
% with missing observations

dataM = setValue(data,'VAR1',nan,data.endDate,data.endDate);

% Prior
prior         = nb_var.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t           = nb_var.template();
t.data      = dataM;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Test VAR (Normal-Wishart) 
% without missing observations

% Prior
prior       = nb_var.priorTemplate('nwishart');

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Normal-Wishart) 
% with missing observations

dataM = setValue(data,'VAR1',nan,data.endDate,data.endDate);

% Prior
prior       = nb_var.priorTemplate('nwishartMF');

% Options
t           = nb_var.template();
t.data      = dataM;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Independent Normal-Wishart) 
% without missing observations

% Prior
prior       = nb_var.priorTemplate('inwishart');

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Independent Normal-Wishart) 
% with missing observations

dataM = setValue(data,'VAR1',nan,data.endDate,data.endDate);

% Prior
prior       = nb_mfvar.priorTemplate('inwishartMF');

% Options
t           = nb_var.template();
t.data      = dataM;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.doTests   = 1;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Test VAR (Minnesota (Independent Normal-Wishart)) with missing 
% observations, recursivly and using missingMethod

nMis  = 2;
dataM = setValue(data,'VAR1',nan(nMis,1),data.endDate-nMis+1,data.endDate);
            
% Prior
prior         = nb_var.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t                            = nb_var.template();
t.data                       = dataM;
t.dependent                  = {'VAR1','VAR2'};
t.constant                   = true;
t.nLags                      = 2;
t.prior                      = prior;
t.draws                      = 500;
t.missingMethod              = 'kalman';
t.recursive_estim            = true;
t.recursive_estim_start_date = '2012Q4'; 

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Solve model,forecast and evaluate the forecast (Recursive)
% Here we do return nowcast, due to missingMethod used!

model   = solve(model);
model   = forecast(model,8,...
            'fcstEval',   'SE',...
            'startDate',  '2013Q1');
plotter = plotForecast(model);
plotter.set('startGraph','2008Q1');
nb_graphSubPlotGUI(plotter)
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast (Recursive)
% Here we do return nowcast, due to missingMethod used!

model = solve(model);
model = forecast(model,8,...
    'startDate',        '2013Q1',...
    'draws',            1000,...
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
plotter.set('startGraph','2008Q1');
nb_graphSubPlotGUI(plotter);
