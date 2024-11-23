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

algorithm       = 'almon';
AR              = 0;
nStep           = 2;
polyLags        = 2;
recursive_estim = false;
covidDates      = nb_covidDates(4);

%% MIDAS
% 1 leads on exogenous

% Options
t                 = nb_midas.template();
t.data            = data;
t.algorithm       = algorithm;
t.dependent       = {'Q_VAR1'};
t.exogenous       = {'VAR2','VAR3'};
t.frequency       = {'Q_VAR1',4};
t.constant        = true;
t.nStep           = nStep;
t.nLags           = 2;
t.doTests         = 1;
t.AR              = AR;
t.unbalanced      = true;
t.polyLags        = polyLags;
t.recursive_estim = recursive_estim;
t.covidAdj        = covidDates; 

% Create model and estimate
model = nb_midas(t);
model = estimate(model);
print(model)

% Solve model
model = solve(model);

% Forecast model
if recursive_estim
    model   = forecast(model,2,'fcstEval','SE');
    plotter = plotForecast(model,'hairyplot');
    nb_graphSubPlotGUI(plotter);
else
    model   = forecast(model,2);
    plotter = plotForecast(model);
    nb_graphSubPlotGUI(plotter);
end
