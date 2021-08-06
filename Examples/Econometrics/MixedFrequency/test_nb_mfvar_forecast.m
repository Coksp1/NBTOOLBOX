%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency
help nb_mfvar.forecast

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
dataQ   = nb_ts.simulate('1990Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataQ   = setToNaN(dataQ,'2014Q4','2014Q4','VAR2'); % Add missing observation
dataA   = convert(dataQ,1,'diffAverage');
dataAQ  = convert(dataA,4,'','interpolateDate','end');
dataAQ  = addPrefix(dataAQ,'A_');
data    = [dataAQ,dataQ];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Normal-Wishart)

% Prior
prior       = nb_mfvar.priorTemplate('nwishartMF');

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','A_VAR2','A_VAR3'};
t.frequency = {'A_VAR2',1,'A_VAR3',1};
t.mapping   = {'A_VAR2','diffAverage','A_VAR3','diffAverage'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Solve 

modelS = solve(model);

%% Forecast

modelF = forecast(modelS,12);

%% Plot forecast of the highest frequency
% Fixed dashed for missing data!!!

p = plotForecast(modelF);
p.set('startGraph','2000Q1');
nb_graphSubPlotGUI(p);

%% Get forecast on the lower frequencies
% Monthly

% Without history
[fcstData,fcstDates] = getForecastLowFreq(modelF,1)

% With history
[fcstData,fcstDates] = getForecastLowFreq(modelF,1,'',true)

%% Plot 

p = plotForecastLowFreq([modelF,modelF],1);
p.set('startGraph','2005');
nb_graphSubPlotGUI(p);
