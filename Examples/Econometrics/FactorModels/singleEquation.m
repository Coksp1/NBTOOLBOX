%% Get help on the nb_fm class

nb_fm.help

%% Import data

data = nb_ts('factorModelsData.xlsx');
data = epcn(data);
data = data - mean(data);
data = data(2:end,:,:);

%% Model variables

dep = {'QSA_PCPI','QSA_PCPIJAE'};
obs = {'QSA_CG','QSA_CP','QSA_JC','QSA_JG','QSA_JH','QSA_JOS',...
       'QSA_LMN','QSA_WILMN','QSA_XMN','QSA_MMN','QSA_XS','QSA_Y'};

%% Single Eq FM

t                = nb_fm.template();
t.dependent      = dep;
t.observables    = obs;
t.data           = data;
t.estim_end_date = data.endDate;
t.nFactors       = 4;
% t.stdType        = 'bootstrap';
t.doTests        = 0;

model = nb_fm(t);
model = estimate(model);
print(model)

%% Single Eq FM (recursive)

t                  = nb_fm.template();
t.dependent        = dep;
t.observables      = obs;
t.data             = data;
t.estim_end_date   = data.endDate;
t.nFactors         = 4;
t.nLags            = 0;
% t.stdType          = 'bootstrap';
t.recursive_estim  = 1;

model = nb_fm(t);
model = estimate(model);
print(model)

%% Solve factor model

modelS = solve(model);
modelS.solution

% help nb_fm.solution

%% Solve model,forecast and evaluate the forecast

modelF   = forecast(modelS,8,...
            'fcstEval','SE',...
            'startDate','2000Q1',...
            'exoProj','AR'); % Must be set to 'AR' or 'VAR'!
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);
