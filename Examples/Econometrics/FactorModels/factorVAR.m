%% Get help on the nb_favar class

nb_favar.help

%% Import data

data = nb_ts('factorModelsData.xlsx');
data = epcn(data);
data = data - mean(data);
data = data(2:end,:,:);

%% Model variables

dep = {'QSA_PCPI','QSA_PCPIJAE'};
obs = {'QSA_CG','QSA_CP','QSA_JC','QSA_JG','QSA_JH','QSA_JOS',...
       'QSA_LMN','QSA_WILMN','QSA_XMN','QSA_MMN','QSA_XS','QSA_Y'};

%% nb_favar

t             = nb_favar.template();
t.dependent   = dep;
t.observables = obs;
t.data        = data;
t.nLags       = 2;
t.nFactors    = 4;

model = nb_favar(t);
model = estimate(model);
print(model)

%% Solve model

modelS = solve(model);
modelS.solution

% help nb_favar.solution

%% Forecast

modelF  = forecast(modelS,8);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast
% This example has too few factors, so the density forecast are 
% too wide!

modelF  = forecast(modelS,8,...
            'draws',1000);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Identify model and solve after identification

modelI = set_identification(model,'cholesky');
modelS = solve(modelI);

%% Get identified residual

residual = getIdentifiedResidual(modelS);

%% Produce irfs

[irfs,irfsBand,plotter] = irf(modelS);
nb_graphInfoStructGUI(plotter)

%% nb_favar
% Recursive estimation

t                  = nb_favar.template();
t.dependent        = dep;
t.observables      = obs;
t.data             = data;
t.nLags            = 2;
t.nFactors         = 4;
t.recursive_estim  = 1;

model = nb_favar(t);
model = estimate(model);
print(model)

%% Solve model
% Recursive

modelS = solve(model);
modelS.solution

% help nb_favar.solution

%% Forecast
% Recursive

modelF  = forecast(modelS,8,...
            'fcstEval','SE',...
            'startDate','2001Q4');
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Get root mean squared error

score = getScore(modelF,'RMSE');
score.Model1

%% Density forecast
% Recursive

modelF = forecast(modelS,8,...
    'startDate',        '2017Q1',...
    'draws',            500,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Get mean log score

score = getScore(modelF,'MLS');
score.Model1
