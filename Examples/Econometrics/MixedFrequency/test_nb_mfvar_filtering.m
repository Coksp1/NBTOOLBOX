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

%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t                = nb_mfvar.template();
t.data           = data;
t.dependent      = {'VAR1','A_VAR2'};
t.frequency      = {'A_VAR2',1};
t.mapping        = {'A_VAR2','diffAverage'}; % Approximation
t.constant       = true;
t.nLags          = 2;
t.prior          = prior;
t.draws          = 500;
t.estim_end_date = data.endDate - 9;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

% Get smoothed estimates of missing value (Mean of the posterior draws)
smoothed = getFiltered(model);

%% Filter over a longer period
% Will overwrite old filtering results, and some estimation options!

modelFilt = filter(model,'estim_end_date',data.endDate);

%% Solve model, forecast and plot the forecast

modelFiltS = solve(modelFilt);
modelF     = forecast(modelFiltS,8);
plotter    = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);
