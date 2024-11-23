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

algorithm       = 'lasso';
AR              = 0;
nStep           = 2;
recursive_estim = false;
covidDates      = nb_covidDates(4);
regularization  = 0.5;
perc            = 0.5;

%% LASSO-MIDAS

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

%% LASSO-MIDAS
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

%% LASSO-MIDAS
% Calibrate regularization

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

% Create model and estimate
model       = nb_midas(t);
[reg,model] = getRegularization(model,'perc',perc);
model       = estimate(model);
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

%% LASSO-MIDAS
% "Optimize" regularization

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
t.recursive_estim  = true;

% Create model and estimate
model        = nb_midas(t);
[reg,models] = getRegularization(model,'grid',71,'gridPerc',0.2,'gridPercMax',0.9);
models       = estimate(models,'waitbar');

% Solve model
models = solve(models);

% Forecast model
models = forecast(models,nStep,'fcstEval','SE','waitbar');

% Score models
scores     = getScore(models,'RMSE',false,'','',true);
modelNames = fieldnames(scores);
scoresD    = nan(nStep,length(modelNames));
for ii = 1:length(modelNames) 
    scoresD(:,ii) = double(scores.(modelNames{ii}));
end

% Fin optimal regularization for each horizon
[~,ind] = min(scoresD,[],2);
regOpt  = nan(1,nStep);
for ii = 1:nStep
    regOpt(ii) = reg(ind(ii),ii);
end
regOpt

%% LASSO-MIDAS
% "Optimize" regularization, using percentage of unrestricted

% Caution: This is not the same optimization problem as the one above, 
% as holding regularizationPerc constant during recursive estimation,
% is not the same as holding regularization constant!

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

%% LASSO-MIDAS
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

%% Simulate some big dataset

rng(1) % Set seed

% y_h = a + b*x + e
T      = 50;
N      = 70;
y      = nan(T,1);
x      = nan(T,N);
x(1,:) = 1;
for n = 1:N
    for t = 2:T
        x(t,n) = 0.5*x(t-1,n) + randn;
    end
end
beta     = randn(N,1).*0.1;
y(2:T,1) = 0.2 + x(2:T,:)*beta + randn(T-1,1).*0.2;
xNames   = nb_appendIndexes('x',1:N)';
dataM    = nb_ts([y,x],'','1999M1',[{'y'},xNames]);
dataQ    = convert(dataM('y'),4,'diffAverage');
dataQM   = convert(dataQ,12,'','interpolateDate','end');
dataQM   = addPrefix(dataQM,'Q_');
data     = [dataQM,dataM];

%% LASSO-MIDAS
% Estimate model with N > T

% Options
t                            = nb_midas.template();
t.data                       = data;
t.algorithm                  = algorithm;
t.dependent                  = {'Q_y'};
t.exogenous                  = xNames;
t.frequency                  = {'Q_y',4};
t.constant                   = true;
t.nStep                      = nStep;
t.nLags                      = 10;
t.doTests                    = 1;
t.AR                         = AR;
t.unbalanced                 = true;
t.recursive_estim            = recursive_estim;
t.regularization             = regularization;
t.regularizationMode         = 'lagrangian';
t.recursive_estim_start_date = '2002M1';

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
