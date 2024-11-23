%% Simulate some ARIMA processes

rng(1) % Set seed

draws = randn(100,1);
sim1  = filter(1,[1,-0.5],draws);           % ARIMA(1,0,0)
sim2  = filter([1,0.5],1,draws);            % ARIMA(0,0,1)
sim3  = filter([1,0.5],[1,-0.2],draws);     % ARIMA(1,0,1)
sim4  = filter([1,0.5,0.2],[1,-0.2],draws); % ARIMA(1,0,2)

% Transform to nb_ts object
data   = nb_ts([sim1,sim2,sim3,sim4],'','2000Q1',...
                {'Sim1','Sim2','Sim3','Sim4'});
            
% Construct variable that are I(1) and merge with rest            
dataUR = undiff(data('Sim1'),100,1);
dataUR = rename(dataUR,'variables','Sim1','Sim5');
data   = merge(data,dataUR);

%% Help on the nb_arima class

nb_arima.help
help nb_arima.forecast

%% nb_arima (using template)

prior = nb_arima.priorTemplate();

t = nb_arima.template;
t.constant         = 0;
t.covrepair        = true;
t.data             = data;
t.dependent        = {'Sim3'};
t.AR               = 1;
t.MA               = 1;
t.integration      = 0;
t.estim_start_date = '';
t.estim_end_date   = data.endDate - 11;
t.prior            = prior;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% Solve AR model

modelS = solve(model);

%% Unconditional forecast (point)

modelF  = forecast(modelS);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Unconditional forecast (density)
% TODO: This example does not work yet!

modelF = forecast(modelS,8,...
            'draws',            2,...
            'parameterDraws',   200,...
            'perc',             [0.3,0.5,0.7,0.9]);

plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% I(1) variable

model = nb_arima(...
    'recursive_estim_start_date','2020Q1',...
    'prior',                     prior,...
    'constant',                  1,...
    'data',                      data,...
    'dependent',                 {'Sim5'},...
    'AR',                        1,...
    'MA',                        2,...
    'integration',               1,...
    'recursive_estim',           1);

model = estimate(model);
print(model)

%% Solve model

modelS = solve(model);

%% Unconditional forecast (Point)
% Recursive

modelF = forecast(modelS,8,...
            'fcstEval','SE');
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Unconditional forecast (Density)
% Recursive

modelF = forecast(modelS,8,...
            'parameterDraws',    1,...
            'startDate',         '2022Q1',...
            'perc',              [0.2,0.4,0.6,0.8],...
            'draws',             1000,...
            'fcstEval',          'SE');
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);
