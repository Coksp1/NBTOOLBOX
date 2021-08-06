%% Help on this example

nb_exprModel.help

%% Simulate some data

rng(1); % Set seed

T              = 100;
covid          = zeros(T,2);
covid(end-3,1) = 1;
covid(end-2,2) = 1;
dxAR           = 0.5;
dx             = nan(T+1,1);
dx(1)          = 0;
dxe            = randn(T,1);
for t = 1:T
   dx(t+1) = dxAR*dx(t) + dxe(t); 
end

dyAR  = 0.7;
beta  = 0.4;
e     = 0.5*randn(T,1);
dy    = nan(T+1,1);
dy(1) = 0;
for t = 1:T
   dy(t+1) = dyAR*dy(t) + beta*dx(t) - 0.5*covid(t,1) - 0.2*covid(t,2) + e(t); 
end

dy = dy(2:end);
dx = dx(2:end);

% Construct level data
y = ipcn(dy,100);
x = ipcn(dx,100);

% Create nb_ts object
data = nb_ts([y,x],'','1996Q1',{'y','x'});
data = covidDummy(data);

%% Plot simulated data

nb_graphPagesGUI(data);

%% Formulate the model

t                      = nb_exprModel.template();
t.constant             = true;
t.data                 = data;
t.dependent            = {'growth(y(t))'};
t.exogenous            = [strcat(nb_covidDummyNames(4),'(t)'), {'growth(y(t-1))','growth(x(t-1))'}];
t.recursive_estim      = true;
t.removeZeroRegressors = true;
model                  = nb_exprModel(t);

%% Estimate 

model = estimate(model);
print(model)
printCov(model)

%% Recursive estimation graph

plotter = getRecursiveEstimationGraph(model);
nb_graphSubPlotGUI(plotter);

%% Solve model

model = solve(model);

%% Forecast model

model   = forecast(model,2,'startDate','2021Q1');
plotter = plotForecast(model);
plotter.set('startGraph','2018Q1');
nb_graphSubPlotGUI(plotter);

%% Forecast model
% Extrapolate exogenous with AR processes

model   = forecast(model,2,'startDate','2021Q1','exoProj','ar');
plotter = plotForecast(model);
plotter.set('startGraph','2018Q1');
nb_graphSubPlotGUI(plotter);

%% Conditional forecast

startDate = '2021Q1';
condDB    = nb_ts(90,'',startDate,{'x'});
model     = forecast(model,2,'startDate',startDate,'condDB',condDB,...
            'output','all','exoProj','ar');
plotter   = plotForecast(model);
plotter.set('startGraph','2018Q1');
nb_graphSubPlotGUI(plotter);

%% Recursive out-of-sample forecast
% You can set the second input to a larger number than one to condition the
% recursive forecast on actual data on the exogenous. You will get a
% warning that some information is missing on the last recursions, but
% that is OK.

model   = forecast(model,2,'fcstEval','SE');
plotter = plotForecast(model,'hairyplot');
plotter.set('startGraph','1996Q1');
nb_graphSubPlotGUI(plotter);

%% Get evaluation score

score = model.getScore('RMSE',false,'','',true);
score.Model1

%% Recursive out-of-sample forecast
%  Extrapolate exogenous with AR processes recursively

model   = forecast(model,2,'fcstEval','SE','exoProj','ar',...
                           'startDate','2005Q1');
plotter = plotForecast(model,'hairyplot');
plotter.set('startGraph','2005Q1');
nb_graphSubPlotGUI(plotter);
