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
dataQ   = nb_ts.simulate('2000Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataA   = convert(dataQ,1,'diffAverage');
dataAQ  = convert(dataA,4,'','interpolateDate','end');
dataAQ  = addPrefix(dataAQ,'A_');
data    = [dataAQ,dataQ];

[covidDates,drop] = nb_covidDates(4);
covidDates        = covidDates(1:end-drop);

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

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
t.covidAdj  = covidDates;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_A_VAR2
% is the quarterly estimate of A_VAR2 series.

s  = getFiltered(model);

s1 = s('AUX_VAR1');
d  = data('VAR1');
d  = merge(d,s1);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'});
nb_graphPagesGUI(p);

s2 = s('AUX_A_VAR2');
d2 = data('VAR2');
d2 = merge(d2,s2);
p2  = nb_graph_ts(d2);
p2.set('legends',{'Predicted','Actual'});
nb_graphPagesGUI(p2);

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
t.recursive_estim_start_date = '2020Q1'; 
t.covidAdj                   = covidDates;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Solve model,forecast and evaluate the forecast (Recursive)

model   = solve(model);
model   = forecast(model,8,...
            'fcstEval',   'SE',...
            'startDate',  '2020Q2');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter)
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Solve model and density forecast (Recursive)

model = solve(model);
model = forecast(model,8,...
    'startDate',        '2020Q2',...
    'draws',            2,...
    'parameterDraws',   500,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
