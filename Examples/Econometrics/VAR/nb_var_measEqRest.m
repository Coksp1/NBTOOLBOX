%% Get help on this example

nb_mfvar.help
help nb_var.setMeasurementEqRestriction

%% Generate artificial data (monthly)

rng(1); % Set seed

obs     = 200;
lambda  = [0.5, 0.1, 0.2, -0.1;
           0.5,-0.1,   0,  0.1];
rho     = [1;1]; 

% Simulate monthly data
data  = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2'},1,lambda,rho);
dataW = nb_ts.simulate('1990M1',obs,{'WEIGHT1'},1,0.9,0.01) + 0.4;
dataW = createVariable(dataW,'WEIGHT2','1-WEIGHT1');
data  = merge(data,dataW);
data  = createVariable(data,'VAR3','VAR1*WEIGHT1+VAR2*WEIGHT2');

%% Test Missing-VAR (Minnesota; Independent Normal-Wishart type) 

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Prior
prior        = nb_var.priorTemplate('minnesotaMF');
prior.method = 'inwishart';

% Apply restriction between 'VAR3','Var1' and 'Var2' 
restrictions = struct(...
    'restricted','VAR3',...
    'parameters',{{'WEIGHT1','WEIGHT2'}},...
    'variables',{{'VAR1','VAR2'}},...
    'R_scale',100 ...
);

% Options
t           = nb_var.template();
t.data      = dataEst;
t.dependent = {'VAR1','VAR2'}; 
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Assign measurement equation restrictions
t.measurementEqRestriction = restrictions;

% Create model and estimate
model = nb_var(t);

%% Estimate model

model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values
% As seen from the graph we are perfectly replicating VAR2, as 
% the restriction given by VAR3 is as informative, as observing VAR2!

s  = getFiltered(model);
sd = s('VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
d  = [d,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted'});
nb_graphPagesGUI(p);

%% Solve model

model = solve(model);

%% Unconditional forecast

model   = forecast(model,4);
plotter = plotForecast(model);
set(plotter,'startGraph','2004M1')
nb_graphSubPlotGUI(plotter);

%% Conditional forecast
% Project all variables by AR processes and condition on this information

condDB           = extrapolate(dataEst,{'VAR1','VAR2','VAR3'},'2006M12','method','ar');
condDB           = window(condDB,dataEst.endDate+1);
condDB.dataNames = {'Conditional information'};
modelCF          = forecast(model,4,'startDate',dataEst.endDate+1,...
    'condDB',condDB,'kalmanFilter',true);
plotterC = plotForecast(modelCF);
set(plotterC,'startGraph','2004M1');

% Merge with unconditional forecast and conditional information
plotterC.DB        = addPages(plotterC.DB,condDB);
uncondDB           = plotter.DB;
uncondDB.dataNames = {'Uncond'};
plotterC.DB        = addPages(plotterC.DB,uncondDB);

nb_graphSubPlotGUI(plotterC);

%% Estimate model recursively

modelRec = set(model,'recursive_estim',true,'recursive_estim_start_date','2006M7');
modelRec = estimate(modelRec);
print(modelRec)
printCov(modelRec)

%% Solve model

modelRec = solve(modelRec);

%% Unconditional forecast
% At last iteration

modelRec = forecast(modelRec,4);
plotter  = plotForecast(modelRec);
nb_graphSubPlotGUI(plotter);

%% Unconditional forecast
% Hairy plot

modelRec = forecast(modelRec,4,'fcstEval','SE');
plotter  = plotForecast(modelRec,'hairyplot');
nb_graphSubPlotGUI(plotter);

%% Test OLS-VAR 
% Caution: Does not handel missing data!
% Caution: Restrictions are not taken into account during estimation!

% Apply restriction between 'VAR3','Var1' and 'Var2' 
restrictions = struct(...
    'restricted','VAR3',...
    'parameters',{{'WEIGHT1','WEIGHT2'}},...
    'variables',{{'VAR1','VAR2'}},...
    'R_scale',100 ...
);

% Options
t           = nb_var.template();
t.data      = data;
t.dependent = {'VAR1','VAR2'}; 
t.estim_method 
t.constant  = true;
t.nLags     = 2;

% Assign measurement equation restrictions
t.measurementEqRestriction = restrictions;

% Create model and estimate
model = nb_var(t);

%% Estimate model

model = estimate(model);
print(model)
printCov(model)

%% Solve model

model = solve(model);

%% Unconditional forecast

model   = forecast(model,4);
plotter = plotForecast(model);
set(plotter,'startGraph','2004M1')
nb_graphSubPlotGUI(plotter);

%% Conditional forecast
% Project all variables by AR processes and condition on this information

condDB           = extrapolate(data,{'VAR1','VAR2','VAR3'},'2006M12','method','ar');
condDB           = window(condDB,dataEst.endDate+1);
condDB.dataNames = {'Conditional information'};
modelCF          = forecast(model,4,'startDate',dataEst.endDate+1,...
    'condDB',condDB,'kalmanFilter',true,'output','all');
plotterC = plotForecast(modelCF);
set(plotterC,'startGraph','2004M1');

% Merge with unconditional forecast and conditional information
plotterC.DB        = addPages(plotterC.DB,condDB);
uncondDB           = plotter.DB;
uncondDB.dataNames = {'Uncond'};
plotterC.DB        = addPages(plotterC.DB,uncondDB);

nb_graphSubPlotGUI(plotterC);

%% Estimate model recursively

modelRec = set(model,'recursive_estim',true,'recursive_estim_start_date','2006M7');
modelRec = estimate(modelRec);
print(modelRec)
printCov(modelRec)

%% Solve model

modelRec = solve(modelRec);
