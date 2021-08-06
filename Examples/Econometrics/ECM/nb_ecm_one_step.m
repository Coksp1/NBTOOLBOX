%% Get help on the nb_ecm class

nb_ecm.help
help nb_ecm.solution
help nb_ecm.forecast

%% Simulate some data

rng(1) % Set seed

z     = nan(100,1);
scale = 10;
z(1)  = scale*rand;
for ii = 2:100
    z(ii) = z(ii-1) + scale*rand;
end
x1 = z + randn(100,1);
x2 = z + randn(100,1);
y  = 0.2 + 0.6*x1 + 0.4*x2 + 2*randn(100,1);
w1 = randn(100,1);
w2 = randn(100,1);

% plot(z)
% plot([x1,x2,y])

data = nb_ts([y,x1,x2,w1,w2],'','1990Q1',{'y','x1','x2','w1','w2'});

%% Estimate ECM model
% Set lags manually

t = nb_ecm.template;
t.data           = data;
t.dependent      = {'y'};
t.endogenous     = {'x1','x2'};
t.estim_end_date = '2012Q4';
t.exogenous      = {'w1','w2'};
t.constant       = 1;
t.nLags          = [2,1,0];
t.exoLags        = {[0,2],[1,2,3]};%[0,2];

model = nb_ecm(t);
model = estimate(model);
print(model)

%% Solve ECM model

modelS = solve(model);
modelS.solution

%% Forecast ECM model 
% with AR projections of exogenous variables

modelF = forecast(modelS,8,... 
                'output',  'all',...
                'exoProj', 'AR');
            
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Forecast ECM model with conditional forecast

modelF = forecast(modelS,8,... 
                'output', 'all',...
                'condDB', deleteVariables(window(data,'2013Q1'),'y'));
            
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Estimate ECM model
% Set lags manually

t = nb_ecm.template;
t.data           = data;
t.dependent      = {'y'};
t.endogenous     = {'x1','x2'};
t.constant       = 1;
t.nLags          = [2,1,3];

model = nb_ecm(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Historical decomposition (Not grouped)

[dec,~,p] = shock_decomposition(model);
nb_graphPagesGUI(p);

%% Historical decomposition (grouped)

% trans = 'level';
trans   = 'diff';
[dec,p] = grouped_decomposition(model,'transformation',trans,...
                                      'method','recursive_forecast');
nb_graphPagesGUI(p);

[dec,p] = grouped_decomposition(model,'transformation',trans,...
                                      'method','shock_decomposition');
nb_graphPagesGUI(p);

%% Estimate ECM model
% Set full lag structure manually

t = nb_ecm.template;
t.data           = data;
t.dependent      = {'y'};
t.endogenous     = {'x1','x2'};
t.constant       = 1;
t.nLags          = {[0,1,2],[0,2],[1]};

model = nb_ecm(t);
model = estimate(model);
print(model)

%% Estimate ECM model

t = nb_ecm.template;
t.data           = data;
t.dependent      = {'y'};
t.endogenous     = {'x1','x2'};
t.constant       = 1;
t.modelSelection = 'autometrics';

model = nb_ecm(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Forecast ECM model with AR projections of exogenous variables

model = forecast(model,8,... 
                'output',  'all',...
                'exoProj', 'AR');
            
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);    

%% Density forecast ECM model with AR projections of exogenous variables
% There are some problems with kernel density estimation of level variables
% so set varOfInterest to the differenced series!

model = forecast(model,8,...
                'varOfInterest',    {'diff_y','y'},...
                'output',           'all',...
                'draws',            10,...
                'parameterDraws',   100,...
                'exoProj',          'AR');
            
plotterD = plotForecast(model);
nb_graphSubPlotGUI(plotterD);   

%% Conditional forecast (Level)

condDB = window(plotter.DB,data.endDate+1,'',{'x1_lag1','x2_lag1'});
condDB = lead(condDB,1);
condDB = rename(condDB,'variable','x1_lag1','x1');
condDB = rename(condDB,'variable','x2_lag1','x2');
condDB = window(condDB,'',condDB.endDate-1);

modelC = forecast(model,7,...
                'output','all',...
                'condDB',condDB);

plotterC = plotForecast(modelC);
nb_graphSubPlotGUI(plotterC);    

%% Conditional forecast (Diff)

condDB = window(plotter.DB,data.endDate+1,'',{'diff_x1','diff_x2'});
modelC = forecast(model,8,...
                'output','all',...
                'condDB',condDB);

plotterC = plotForecast(modelC);
nb_graphSubPlotGUI(plotterC);          

%% Estimate ECM model
% Recursive estimation

t = nb_ecm.template;
t.data            = data;
t.dependent       = {'y'};
t.endogenous      = {'x1','x2'};
t.recursive_estim = 1;
t.constant        = 1;

model = nb_ecm(t);
model = estimate(model);
print(model)

%% Solve ECM model recursivly

modelS = solve(model); 
modelS.solution

%% Estimate ECM model
% Model selection

t = nb_ecm.template;
t.data            = data;
t.dependent       = {'y'};
t.endogenous      = {'x1','x2'};
t.modelSelection  = 'autometrics';
t.constant        = 1;

model = nb_ecm(t);
model = estimate(model);
print(model)
