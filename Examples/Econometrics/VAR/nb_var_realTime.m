%% Get help on the nb_var class

nb_var.help

%% Load data
% For now we need each vintage to supply us with new observations for all
% real-time variables. And there can be no lost vintages
plot   = true;
data   = nb_ts('realTimeLevel');

% QSA_PCPIJAE : Norwegian core CPI
% QSA_YMN     : GDP mainland Norway
% QUA_RNFOLIO : The Norwegian policy rate.

%% Do transformations (To store shift/trend)
%
% When producing point forecast transformations of variables may be done
% after the forecast has been produced, but for density forecast it is
% important to do the transformation before for example calculating
% percentiles (for non-linear expressions)
%
% If the forecast should be evaluated based on some transformation
% of variables it is also important to do them in code, at least it is 
% much easier then write your own code for it! (Both point and density)

expressions = {% Name,  expression,  shift/trend,   description                                                                                                                               
'QSA_DPY_PCPIJAE_GAP',  'growth(QSA_PCPIJAE,4)',    {'avg'}, ''
'QSA_DPY_YMN_GAP',      'growth(QSA_YMN,4)',        {'avg'}, ''
'QUA_RNFOLIO_GAP',      'QUA_RNFOLIO/100',          {'avg'}, ''
};

%% Assign inverse transformations 
%(shift/trend will be added automatically)

reporting = {% Name,  expression,   description
'QSA_DPY_PCPIJAE', 'QSA_DPY_PCPIJAE_GAP', ''
'QSA_DPY_YMN',     'QSA_DPY_YMN_GAP',     ''
'QUA_RNFOLIO',     'QUA_RNFOLIO_GAP*100', ''
};

%% Simple VAR

% Options
nLags              = 4;
t                  = nb_var.template();
t.data             = data;
t.estim_start_date = data.startDate + 4 + nLags;
t.constant         = 0;
t.nLags            = nLags;
t.real_time_estim  = 1;
t.dependent        = {'QSA_DPY_PCPIJAE_GAP','QSA_DPY_YMN_GAP',...
                      'QUA_RNFOLIO_GAP'};
% t.rollingWindow    = 50;

% Create model
model = nb_var(t);

%% Model variables transformation
% 1. De-trending will be done in real time!
% 2. Only last de-trending will be plotted!

[model,plotter] = model.createVariables(expressions,9);
nb_graphInfoStructGUI(plotter);

%% Check reporting

model = set(model,'reporting',reporting);
model = checkReporting(model);

%% Estimate in real-time

model = estimate(model);
print(model)

%% Recursive real-time estimation graph

plotter = getRecursiveEstimationGraph(model);
nb_graphSubPlotGUI(plotter);

%% Solve model

model = solve(model);

%% Forecast real-time
% Here we evaluate the forecast against the 3 release

model = forecast(model,8,'fcstEval','SE');%,'compareToRev',3

%% Get forecast

fcst = getForecast(model,'2015Q3',true);

%% Plot forecast

plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Plot recurive forecast in real-time

plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter)

%% Get forecasting score

score = getScore(model,'RMSE');
score.Model1

%% Mincer-Zarnowitz test

[test,pval,printed] = mincerZarnowitzTest(model)

%% Get roots

model       = solve(model);
[r,plotter] = getRoots(model);
nb_graphPagesGUI(plotter);
