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
dataQ   = nb_ts.simulate('1990Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataA   = convert(dataQ,1,'diffAverage');
dataAQ  = convert(dataA,4,'','interpolateDate','end');
dataAQ  = addPrefix(dataAQ,'A_');
data    = [dataAQ,dataQ];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Maximum likelihood)

% Options
t              = nb_mfvar.template();
t.data         = data;
t.estim_method = 'ml';
t.dependent    = {'VAR1','A_VAR2'};
t.frequency    = {'A_VAR2',1};
t.mapping      = {'A_VAR2','diffAverage'}; % Approximation
t.constant     = true;
t.nLags        = 2;
t.optimizer    = 'fmincon';
t.covrepair    = true;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_A_VAR2
% is the quarterly estimate of A_VAR2 series.

s = getFiltered(model);
s = s('AUX_A_VAR2');
d = data('VAR2');
d = merge(d,s);
p = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'});
nb_graphPagesGUI(p);

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

%% Solve model,forecast and evaluate the forecast
% Here we do not return nowcast, due to missingMethod not used!
%
% This means that the smoothed estimates will appear as history in the 
% graph. This will be updated in a future release.

model   = solve(model);
model   = forecast(model,8);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast

model = solve(model);
model = forecast(model,8,...
    'method',           'asymptotic',...
    'draws',            2,...
    'parameterDraws',   500,...
    'perc',             [0.3,0.5,0.7,0.9],...
    'estimateDensities', false);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Test MF-VAR (Normal-Wishart)

% Prior
prior       = nb_mfvar.priorTemplate('nwishartMF');

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','A_VAR2'};
t.frequency = {'A_VAR2',1};
t.mapping   = {'A_VAR2','diffAverage'}; % Approximation
t.constant  = true;
t.nLags     = 8;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_A_VAR2
% is the quarterly estimate of A_VAR2 series.

s = getFiltered(model);
s = s('AUX_A_VAR2');
d = data('VAR2');
d = merge(d,s);
p = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'});
nb_graphPagesGUI(p);

%% Test MF-VAR (Independent Normal-Wishart)

% Prior
prior       = nb_mfvar.priorTemplate('inwishartMF');

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','A_VAR2'};
t.frequency = {'A_VAR2',1};
t.mapping   = {'A_VAR2','diffAverage'}; % Approximation
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Test MF-VAR (GLP; Normal-Wishart type) 

% Prior
prior = nb_mfvar.priorTemplate('glpMF');

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','A_VAR2'};
t.frequency = {'A_VAR2',1};
t.mapping   = {'A_VAR2','diffAverage'}; % Approximation
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

% Get smoothed estimates of missing value (Mean of the posterior draws)
smoothed = getFiltered(model);


%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','A_VAR2'};
t.frequency = {'A_VAR2',1};
t.mapping   = {'A_VAR2','diffAverage'}; % Approximation
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

% Get smoothed estimates of missing value (Mean of the posterior draws)
smoothed = getFiltered(model);

%% Draw from the parameter from the posterior

modelS   = solve(model);
param    = parameterDraws(modelS,1000,'posterior');
solution = parameterDraws(modelS,1000,'posterior','solution');
models   = parameterDraws(modelS,1000,'posterior','object');

%% Solve model and forecast
% Here we do not return nowcast, due to missingMethod not used!

model   = solve(model);
model   = forecast(model,8);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast
% Here we do not return uncertainty about the nowcast!

model = solve(model);
model = forecast(model,8,...
    'draws',            500,...
    'parameterDraws',   1,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast
% Here we do return uncertainty about the nowcast!

model = solve(model);
model = forecast(model,8,...
    'draws',            2,...
    'parameterDraws',   500,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Identify model

modelI = set_identification(model,'cholesky',...
                'ordering',model.dependent.name);
modelI = solve(modelI);

%% Produce IRFs

% Point
[~,~,plotter] = irf(modelI);
nb_graphInfoStructGUI(plotter);

% Point (Low frequency as well)
[~,~,plotter] = irf(modelI,...
    'variables',{'VAR1','A_VAR2','AUX_A_VAR2'});
nb_graphInfoStructGUI(plotter);

% With error bands
[~,~,plotter] = irf(modelI,'perc',0.68,'replic',500);
nb_graphInfoStructGUI(plotter);

%% Variance decomposition
% Only supported for the high frequency state variables (for now)

% With uncertainty bands
[dec,decBand,plotterDec,plotterDecPerc] = variance_decomposition(modelI,...
    'perc',     0.68,...
    'replic',   500);%

nb_graphPagesGUI(plotterDec)
if ~isempty(plotterDecPerc)
    fields = fieldnames(plotterDecPerc);
    for ii = 1:length(fields)
        plotters = plotterDecPerc.(fields{ii});
        for kk = 1:length(plotters)
            nb_graphSubPlotGUI(plotters(kk));
        end
    end
end

%% Shock decomposition
% Only supported for the high frequency state variables for now

[sDec,sDecBand,plotterSDec] = shock_decomposition(modelI,...
    'startDate','','endDate','');
nb_graphPagesGUI(plotterSDec);

%% Test recursivly estimated MF-VAR (Minnesota)

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t                            = nb_mfvar.template();
t.data                       = data;
t.dependent                  = {'VAR1','A_VAR2'};
t.frequency                  = {'A_VAR2',1};
t.mapping                    = {'A_VAR2','diffAverage'}; % Approximation
t.constant                   = true;
t.nLags                      = 2;
t.prior                      = prior;
t.draws                      = 500;
t.recursive_estim            = true;
t.recursive_estim_start_date = '2012Q4'; 

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Solve model,forecast and evaluate the forecast (Recursive)

model   = solve(model);
model   = forecast(model,8,...
            'fcstEval',   'SE',...
            'startDate',  '2013Q1');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter)
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast (Recursive)

model = solve(model);
model = forecast(model,8,...
    'startDate',        '2013Q1',...
    'draws',            2,...
    'parameterDraws',   500,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
