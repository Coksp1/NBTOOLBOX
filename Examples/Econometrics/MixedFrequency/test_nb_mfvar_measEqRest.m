%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency
help nb_mfvar.setMeasurementEqRestriction

%% Generate artificial data (monthly)

rng(1); % Set seed

obs     = 200;
lambda  = [0.5, 0.1, 0.2, -0.1;
           0.5,-0.1,   0,  0.1];
rho     = [1;1]; 

% Simulate monthly data
dataM = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2'},1,lambda,rho);
dataW = nb_ts.simulate('1990M1',obs,{'WEIGHT1'},1,0.9,0.01) + 0.4;
dataW = createVariable(dataW,'WEIGHT2','1-WEIGHT1');
dataM = merge(dataM,dataW);
dataM = createVariable(dataM,'VAR3','VAR1*WEIGHT1+VAR2*WEIGHT2');

% Convert to quarterly, before it converted back to monthly with missing
% observations
dataQ   = convert(deleteVariables(dataM,{'WEIGHT1','WEIGHT2'}),4,'diffAverage');
dataQMT = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQMT,'Q_');
data    = [dataM,dataQM];

dataDA = 1/3*dataM + 2/3*lag(dataM,1) + lag(dataM,2) + 2/3*lag(dataM,3) + 1/3*lag(dataM,4);

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 
% Monthly and quarterly

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';
prior.mixing  = 'high';

% Set how important it is to match the high frequency observations
% on the variable 'VAR1' and 'VAR2'. Higher number means less measurement  
% errors allowed. The prior is set as sigma/R_scale, where sigma is the
% variance of 'VAR2'.
% 
% It also set how important it is to match the restrictions
prior.R_scale = 100; 

% Apply restriction between 'VAR3','Var1' and 'Var2' 
restrictionQ = struct(...
    'restricted','Q_VAR3',...
    'parameters',{{'WEIGHT1','WEIGHT2'}},...
    'variables',{{'VAR1','VAR2'}},...
    'frequency',4,...
    'mapping','diffAverage',...
    'R_scale',100 ...
);
restrictionM = struct(...
    'restricted','VAR3',...
    'parameters',{{'WEIGHT1','WEIGHT2'}},...
    'variables',{{'VAR1','VAR2'}},...
    'frequency',[],...
    'mapping','',...
    'R_scale',100 ...
);
restrictions = [restrictionQ,restrictionM];

% Options
t           = nb_mfvar.template();
t.data      = dataEst;
t.dependent = {'VAR1','VAR2','Q_VAR1','Q_VAR2'}; % TODO: Restricted variables should not be dependent variables!
t.frequency = {'Q_VAR1',4,'Q_VAR2',4};
t.mapping   = {'Q_VAR1','diffAverage','Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR1','VAR1','Q_VAR2','VAR2'}; % First low, then high
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Assign measurement equation restrictions
t.measurementEqRestriction = restrictions;

% Create model and estimate
model = nb_mfvar(t);

%% Estimate model

model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values
% As seen from the graph we are perfectly replicating VAR2, as 
% the restriction given by VAR3 is as informative, as observing VAR2!

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
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

condDB           = keepVariables(s,{'VAR1','VAR2','Q_VAR1','Q_VAR2','VAR3','Q_VAR3'});
condDB           = extrapolate(condDB,{},'2006M12','method','ar');
condDB           = window(condDB,dataEst.endDate+1);
condDB.dataNames = {'Conditional information'};
modelCF          = forecast(model,4,'startDate',dataEst.endDate+1,...
    'condDB',condDB,'kalmanFilter',true);
plotterC = plotForecast(modelCF);
set(plotterC,'startGraph','2004M1')

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
