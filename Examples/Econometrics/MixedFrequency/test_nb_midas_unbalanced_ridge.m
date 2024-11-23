%% Get help on this example

nb_midas.help

%% Generate artificial data

rng(1); % Set seed

obs     = 412;
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

%% Settings

algorithm       = 'ridge';
AR              = 0;
nStep           = 2;
recursive_estim = false;
covidDates      = nb_covidDates(4);
regularization  = 0.5;
perc            = 0.5;

%% RIDGE-MIDAS

% Options
t                  = nb_midas.template();
t.data             = data;
t.algorithm        = algorithm;
t.dependent        = {'Q_VAR1'};
t.exogenous        = {'VAR2','VAR3'};
t.frequency        = {'Q_VAR1',4};
t.constant         = true;
t.nStep            = nStep;
t.nLags            = 10;
t.doTests          = 1;
t.AR               = AR;
t.unbalanced       = true;
t.recursive_estim  = recursive_estim;
t.regularization   = regularization;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
if recursive_estim
    model   = forecast(model,nStep,'fcstEval','SE');
    plotter = plotForecast(model,'hairyplot');
    nb_graphSubPlotGUI(plotter);
else
    model   = forecast(model,nStep);
    plotter = plotForecast(model);
    nb_graphSubPlotGUI(plotter);
end

%% RIDGE-MIDAS
% Calibrate regularization

% Options
t                    = nb_midas.template();
t.data               = data;
t.algorithm          = algorithm;
t.dependent          = {'Q_VAR1'};
t.exogenous          = {'VAR2','VAR3'};
t.frequency          = {'Q_VAR1',4};
t.constant           = true;
t.nStep              = nStep;
t.nLags              = 10;
t.doTests            = 1;
t.AR                 = AR;
t.unbalanced         = true;
t.recursive_estim    = recursive_estim;
t.regularizationPerc = perc;

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
if recursive_estim
    model   = forecast(model,nStep,'fcstEval','SE');
    plotter = plotForecast(model,'hairyplot');
    nb_graphSubPlotGUI(plotter);
else
    model   = forecast(model,nStep);
    plotter = plotForecast(model);
    nb_graphSubPlotGUI(plotter);
end

%% RIDGE-MIDAS
% "Optimize" regularization, using percentage of unrestricted

gridPerc = 0.2:0.01:0.9;

% Options
t                    = nb_midas.template(length(gridPerc));
t.data               = data;
t.algorithm          = algorithm;
t.dependent          = {'Q_VAR1'};
t.exogenous          = {'VAR2','VAR3'};
t.frequency          = {'Q_VAR1',4};
t.constant           = true;
t.nStep              = nStep;
t.nLags              = 10;
t.doTests            = 1;
t.AR                 = AR;
t.unbalanced         = true;
t.recursive_estim    = true;
t.regularizationPerc = num2cell(gridPerc);

% Create model and estimate
models = nb_model_generic.initialize('nb_midas',t);
models = estimate(models,'waitbar');

% Solve model
models = solve(models);

% Forecast model
models = forecast(models,nStep,'fcstEval','SE','waitbar');

% Score models
scores     = getScore(models,'RMSE',false,'','',true);
modelNames = fieldnames(scores);
scoresDP   = nan(nStep,length(modelNames));
for ii = 1:length(modelNames) 
    scoresDP(:,ii) = double(scores.(modelNames{ii}));
end

% Fin optimal regularizationPerc for each horizon
[~,ind] = min(scoresDP,[],2);
percOpt = nan(1,nStep);
for ii = 1:nStep
    percOpt(ii) = gridPerc(ind(ii));
end
percOpt

%% RIDGE-MIDAS
% Covid adjustment

% Options
t                    = nb_midas.template();
t.data               = data;
t.algorithm          = algorithm;
t.dependent          = {'Q_VAR1'};
t.exogenous          = {'VAR2','VAR3'};
t.frequency          = {'Q_VAR1',4};
t.constant           = true;
t.nStep              = nStep;
t.nLags              = 10;
t.doTests            = 1;
t.AR                 = AR;
t.unbalanced         = true;
t.recursive_estim    = recursive_estim;
t.regularizationPerc = perc;
t.covidAdj           = covidDates; 

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)
