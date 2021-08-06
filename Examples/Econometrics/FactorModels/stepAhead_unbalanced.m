%% Get help on the nb_fmsa class

nb_fmsa.help

%% Import data

data = nb_ts('factorModelsData.xlsx');
data = epcn(data);
data = data - mean(data);
data = data(2:end,:,:);

%% Model variables

dep = {'QSA_PCPIJAE'};
obs = {'QSA_CG','QSA_CP','QSA_JC','QSA_JG','QSA_JH','QSA_JOS',...
       'QSA_LMN','QSA_WILMN','QSA_XMN','QSA_MMN','QSA_XS','QSA_Y'};

%% Step ahead FM

t                  = nb_fmsa.template();
t.dependent        = dep;
t.observables      = obs;
t.data             = data;
t.nFactors         = 4;
t.nStep            = 4;
t.nLags            = 0;
t.estim_start_date = data.getRealStartDate('default','all');
t.unbalanced       = true;

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

%% Set dependent variables to have one less observation, and re-estimate
% In this case we have one more observation on the observables, so during
% estimation the regressors are automatically leaded one period.

dataM  = setValue(data,'QSA_PCPIJAE',nan,data.endDate,data.endDate);
modelM = set(model,'data',dataM);
modelM = estimate(modelM);
print(modelM)

%% Solve model

modelMS = solve(modelM);
modelMS.solution

% help nb_fm.solution

%% Forecast model
% Point forecast 

modelMF = forecast(modelMS,4);
plotter = plotForecast([modelF,modelMF]);
plotter.set('startGraph','2015Q1');
nb_graphSubPlotGUI(plotter);

%% Recursive estimation over one period 
% Test how it is called in the nb_model_vintages class

modelR = set(model,'recursive_estim',true,'recursive_estim_start_date',data.endDate,'estim_end_date',data.endDate);
modelR = estimate(modelR);
print(modelR)

modelMR = set(modelM,'recursive_estim',true,'recursive_estim_start_date',data.endDate-1,'estim_end_date',data.endDate-1);
modelMR = estimate(modelMR);
print(modelMR)
