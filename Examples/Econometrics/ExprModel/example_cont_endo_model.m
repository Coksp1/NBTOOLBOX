%% Help on this example

nb_exprModel.help

%% Simulate some data

rng(1); % Set seed

T     = 100;
dxAR  = 0.5;
dx    = nan(T+1,1);
dx(1) = 0;
dxe   = randn(T,1);
for t = 1:T
   dx(t+1) = dxAR*dx(t) + dxe(t); 
end

dyAR  = 0.7;
beta  = 0.4;
e     = 0.5*randn(T,1);
dy    = nan(T+1,1);
dy(1) = 0;
for t = 1:T
   dy(t+1) = dyAR*dy(t) + beta*dx(t+1) + e(t); 
end

dy = dy(2:end);
dx = dx(2:end);

% Construct level data
y = ipcn(dy,100);
x = ipcn(dx,100);

% Create nb_ts object
data = nb_ts([y,x],'','2000Q1',{'y','x'});

%% Plot simulated data

nb_graphPagesGUI(data);

%% Formulate the model

t                 = nb_exprModel.template();
t.constant        = true;
t.data            = data;
t.dependent       = {'growth(x(t))','growth(y(t))'};
t.exogenous       = {{'growth(x(t-1))'},{'growth(y(t-1))','growth(x(t))'}};
t.recursive_estim = true;
model             = nb_exprModel(t);

%% Estimate 

model = estimate(model);
print(model)
printCov(model)

%% Solve model

model = solve(model);

%% Forecast model

model   = forecast(model,2,'startDate','2025Q1');
plotter = plotForecast(model);
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Recursive out-of-sample forecast

model   = forecast(model,2,'fcstEval','SE');
plotter = plotForecast(model,'hairyplot');
plotter.set('startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Get evaluation score

score = model.getScore('RMSE',false,'','',true);
score.Model1
