%% Help on the nb_rfModel class

nb_manualModel.help
help nb.nb_manualModel
help nb.nb_manualModel.estimate

%% Simulate some AR-X process

rng(1) % Set seed

T       = 100;
e       = randn(T,1);
ex      = randn(T,1);
x       = nan(T,1);
x(1)    = randn(1,1);
lambdaX = 0.6;
for ii = 2:T
    x(ii) = lambdaX*x(ii-1) + ex(ii); 
end
y       = nan(T,1);
y(1)    = randn(1,1);
lambdaY = 0.8;
beta    = 0.4;
for ii = 2:T
    y(ii) = lambdaY*y(ii-1) + beta*x(ii) + e(ii); 
end

% Transform to nb_ts object
data = nb_ts([y,x],'','2000Q1',{'y','x'});
     
%% Conditonal information on X

nSteps   = 4;
xFcst    = nan(nSteps+1,1);
xFcst(1) = x(end);
for ii = 2:nSteps+1
    xFcst(ii) = lambdaX*xFcst(ii-1); 
end
condDB = nb_ts(xFcst(2:end),'',data.endDate + 1,{'x'});

%% Best forecast

yFcst    = nan(nSteps+1,1);
yFcst(1) = y(end);
for ii = 2:nSteps+1
    yFcst(ii) = lambdaY*yFcst(ii-1) + beta*xFcst(ii); 
end
fcstT           = nb_ts(yFcst(2:end),'',data.endDate + 1,{'y'});
fcstT.dataNames = {'Best'};

%% Construct model

t               = nb_manualModel.template;
t.data          = data;
t.dependent     = {'y'};
t.exogenous     = {'x'};
t.AR            = 1;
t.estimFunc     = 'myEstimFunc';
t.solveFunc     = 'mySolveFunc';
t.drawParamFunc = 'myDrawParamFunc';
model           = nb_manualModel(t);
model           = estimate(model);
print(model)
printCov(model)

%% Get residual graph

p = getResidualGraph(model);
nb_graphInfoStructGUI(p);

%% Solve model

model = solve(model);

%% Forecast 

model = forecast(model,4,'condDB',condDB);
model = set(model,'name','Manual model');

%% Plot forecast

plotter    = plotForecast(model);
plotter.DB = addPages(plotter.DB,fcstT);
plotter.set('subPlotSize',[1,1],'startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Density forecast 
% It is important to set the method to 'asymptotic', as this will trigger
% calling the myDrawParamFunc function! Otherwise an error will be thrown!

modelD  = forecast(model,4,'condDB',condDB,'parameterDraws',500,...
    'method','asymptotic');
plotter = plotForecast(modelD);
plotter.set('subPlotSize',[1,1],'startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Make parameter draws

param = parameterDraws(model,1000,'asymptotic');

%% Recursive conditonal information on X

recStartD = '2015Q1';
dataExt   = merge(data('x'),condDB);
condDBRec = splitSample(dataExt,nSteps,false);
ind       = find(strcmpi(recStartD,condDBRec.dataNames),1);
condDBRec = condDBRec(:,:,ind+1:end);

%% Estimate model recursivly

modelRec = set(model,...
    'recursive_estim',true,...
    'recursive_estim_start_date',recStartD...
);
modelRec = estimate(modelRec);
print(modelRec)

% Plot recursively estimated paramters
p = getRecursiveEstimationGraph(modelRec);
nb_graphSubPlotGUI(p);

%% Solve model recursivly

modelRec = solve(modelRec);

%% Forecast model recursivly

modelRec = forecast(modelRec,4,'condDB',condDBRec,'fcstEval','SE');
plotter  = plotForecast(modelRec,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Construct model
% That only produce forecast, i.e. all analysis cannot be done!

t               = nb_manualModel.template;
t.condDB        = condDB.tonb_data();
t.data          = data;
t.dependent     = {'y'};
t.exogenous     = {'x'};
t.AR            = 1;
t.estimFunc     = 'myEstimAndFcstFunc';
t.solveFunc     = '';
t.drawParamFunc = '';
t.nFcstSteps    = 4;
model           = nb_manualModel(t);
model           = estimate(model);

%% Solve model
% Nothing to solve, but need to call this to tell the toolbox that
% we have done all the needed stuff before forecasting.

model = solve(model);

%% Forecast 
% The forecast has already been produced, but here we fetch the forecast
% from the results property, and put it into the needed format of the
% forecastOutput property.

model = forecast(model,4);
model = set(model,'name','Manual model');

%% Plot forecast

plotter    = plotForecast(model);
plotter.DB = addPages(plotter.DB,fcstT);
plotter.set('subPlotSize',[1,1],'startGraph','2020Q1');
nb_graphSubPlotGUI(plotter);

%% Estimate model recursivly

modelRec = set(model,...
    'condDB',condDBRec,...
    'recursive_estim',true,...
    'recursive_estim_start_date',recStartD...
);
modelRec = estimate(modelRec);

%% Solve model recursivly

modelRec = solve(modelRec);

%% Forecast model recursivly

modelRec = forecast(modelRec,4);
plotter  = plotForecast(modelRec,'hairyplot');
nb_graphSubPlotGUI(plotter);
