%% Help on this example

nb_exprModel.help

%% Simulate some data

rng(1); % Set seed

T       = 100;
dyAR    = [0.7,0;0.3,0.5];
d       = [1,-1;0,0];
alpha   = -0.1;
e       = 0.5*randn(2,T);
dy      = nan(2,T+1);
y       = 100*ones(2,T+1);
dy(:,1) = 0;
for t = 1:T
   dy(:,t+1) = dyAR*dy(:,t) + alpha*d*y(:,t) + e(:,t); 
   y(:,t+1)  = y(:,t) + dy(:,t+1);
end
dy = dy(:,2:end)';
y  = y(:,2:end)';

% Construct level data
y = ipcn(dy,100*ones(1,2));

% Create nb_ts object
data = nb_ts(y,'','2000Q1',{'y','x'});
    
%% Plot simulated data

nb_graphPagesGUI(data);

%% Formulate the model (VECM)

t           = nb_exprModel.template();
t.constant  = false;
t.data      = data;
t.dependent = {'growth(y(t))','growth(x(t))'};
t.exogenous = {{'growth(y(t-1))','y(t-1) - x(t-1)'},...
                {'growth(y(t-1))','growth(x(t-1))'}};
model       = nb_exprModel(t);

%% Estimate 

model = estimate(model);
print(model)

%% Solve model

model = solve(model);

%% Forecast model

model   = forecast(model,4,'output','all');
plotter = plotForecast(model);
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Residual uncertainty

model   = forecast(model,4,'output','all','draws',1000);
plotter = plotForecast(model);
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Residual and parameter uncertainty

model   = forecast(model,4,'output','all','draws',2,...
            'parameterDraws',500);
plotter = plotForecast(model);
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Recursive estimation

model = set(model,'recursive_estim',true);
model = estimate(model);
print(model)

%% Recursive estimation graph

plotter = getRecursiveEstimationGraph(model);
nb_graphSubPlotGUI(plotter);

%% Solve model

model = solve(model);

%% Forecast model

model   = forecast(model,4,'fcstEval','SE');
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Residual uncertainty

model   = forecast(model,4,'draws',1000,'fcstEval','logScore');

plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

plotter = plotForecast(model,'default','2022Q1');
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Residual and parameter uncertainty

model   = forecast(model,4,'draws',2,...
            'parameterDraws',500,...
            'fcstEval','logScore',...
            'startDate','2022Q1');
        
plotter = plotForecast(model,'hairyplot');
nb_graphSubPlotGUI(plotter);

plotter = plotForecast(model,'default','2022Q1');
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

