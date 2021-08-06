%% Get help on this example

nb_var.help('missingMethod')
help nb_model_group
help nb_model_group.combineForecast

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
vars    = {'VAR1','VAR2','VAR3'};
sim     = nb_ts.simulate('1990Q1',obs,vars,1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Add missing observations

dataM = setValue(sim,'VAR1',nan,'2014Q4','2014Q4');
dataM = setValue(dataM,'VAR2',nan(2,1),'2014Q3','2014Q4');

%% Set up VAR
% When estimating the VAR reecursivly with the use of the missingMethod 
% option we act as the variables that are missing today is also missing
% during the recursive estimation. This is done so we can evaluate
% the nowcasting properties of the given missingMethod!

% Options
t                            = nb_var.template();
t.data                       = dataM;
t.estim_method               = 'ols';
t.dependent                  = vars;
t.constant                   = false;
t.nLags                      = 2;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';
t.missingMethod              = 'forecast';

% Create model and estimate
modelM = nb_var(t);
modelM = estimate(modelM);
print(modelM)

% Solve model
modelM = solve(modelM);

%% Point nowcast and forecast
% Here we act as the variables that are missing today are also missing
% recursivly, we do this to evaluate how good the nowcast are!

modelF  = forecast(modelM,6,'fcstEval','SE');
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Estimate and forecast

% Options
t                            = nb_arima.template();
t.constant                   = false;
t.data                       = dataM;
t.dependent                  = vars(1);
t.AR                         = 1;
t.MA                         = 0;
t.integration                = 0;
t.recursive_estim            = 1;
t.recursive_estim_start_date = '2000Q1';

% Create model and estimate
arModel = nb_arima(t);
arModel = estimate(arModel);
arModel = solve(arModel);
arModel = forecast(arModel,6,...
            'startDate','2000Q2',...
            'fcstEval','SE');       
        
%% Combine point forecast

modelG = nb_model_group([modelF,arModel]);
modelG = combineForecast(modelG,...
            'varOfInterest','VAR1',...
            'type',         'RMSE',...
            'allPeriods',   true,...
            'fcstEval',     'SE');

plotter = plotForecast([modelF,arModel]);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);        
   
plotter = plotForecast(modelG);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter); 

% Make a way to plot forecast from nb_model_group and nb_model_generic
% objects in same graph???

%% Recursive density "nowcast" and forecast
% Here we act as the variables that are missing today are also missing
% recursivly, we do this to evaluate how good the nowcast are!

modelFD  = forecast(modelM,6,...
            'startDate','2010Q1',...
            'fcstEval','logScore',...
            'draws',1000,...
            'parameterDraws',1);

%% Recursive density forecast of the AR model

arModelD = forecast(arModel,6,...
                'startDate','2010Q1',...
                'fcstEval','logScore',...
                'draws',1000,...
                'parameterDraws',1);

%% Combine density forecast

modelG = nb_model_group([modelFD,arModelD]);
modelG = combineForecast(modelG,...
            'varOfInterest','VAR1',...
            'type',         'EELS',...
            'allPeriods',   true,...
            'density',      true,...
            'check',        true,...
            'perc',         [0.3,0.5,0.7,0.9],...
            'fcstEval',     'logScore');

plotter = plotForecast(modelFD);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);        
   
plotter = plotForecast(arModelD);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter); 

plotter = plotForecast(modelG);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter); 
