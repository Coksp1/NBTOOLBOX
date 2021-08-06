%% Get help on the nb_fmsa class

nb_fmsa.help

%% Import data

data = nb_ts('factorModelsData.xlsx');
data = epcn(data);
data = data - mean(data);
data = data(2:end,:,:);

%% Model variables

dep = {'QSA_PCPI','QSA_PCPIJAE'};
obs = {'QSA_CG','QSA_CP','QSA_JC','QSA_JG','QSA_JH','QSA_JOS',...
       'QSA_LMN','QSA_WILMN','QSA_XMN','QSA_MMN','QSA_XS','QSA_Y'};

%% Step ahead FM

t                = nb_fmsa.template();
t.dependent      = dep;
t.observables    = obs;
t.data           = data;
t.nFactors       = 4;
t.nStep          = 4;
t.nLags          = 1;

model = nb_fmsa(t);
model = estimate(model);
print(model)

%% Solve model

modelS = solve(model);
modelS.solution

% help nb_fm.solution

%% Forecast model
% Point forecast 

modelF  = forecast(modelS,4);
plotter = plotForecast(modelF);
plotter.set('startGraph','2015Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Density forecast without parameter uncertainty

modelF  = forecast(modelS,3,...
            'draws',1000);
plotter = plotForecast(modelF);
plotter.set('startGraph','2015Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Density forecast with parameter uncertainty

modelF  = forecast(modelS,3,...
            'draws',2,...
            'parameterDraws',500);
plotter = plotForecast(modelF);
plotter.set('startGraph','2015Q1');
nb_graphSubPlotGUI(plotter);

%% Step ahead FM (recursive)

t                 = nb_fmsa.template();
t.dependent       = dep;
t.observables     = obs;
t.data            = data;
t.nFactors        = 4;
t.nStep           = 4;
t.nLags           = 1;
t.recursive_estim = 1;

model = nb_fmsa(t);
model = estimate(model);
print(model)

%% Solve model

modelS = solve(model);
modelS.solution

% help nb_fm.solution

%% Solve model,forecast and evaluate the forecast

modelF  = forecast(modelS,4,'fcstEval','SE','startDate','2000Q1');
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Get root mean squared error

score = getScore(modelF,'RMSE');
score.Model1

%% Solve model and density forecast

modelF = forecast(modelS,4,...
    'startDate',        '2014Q1',...
    'draws',            10,...
    'parameterDraws',   100,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Get mean log score

score = getScore(modelF,'MLS');
score.Model1
