%% Help on this example

nb_dsge.help
help nb_dsge.forecast
help nb_dsge.interpretForecast

%% Parse model

m = nb_dsge('nb_file','rbc.nb','name','RBC');

%% Assign parameters

p          = struct();
p.alpha    = 0.17;
p.beta     = 0.99;
p.delta    = 0.1;
p.rho_a    = 0.7;
p.rho_i    = 0.7;
p.rho_y    = 0.7;
p.std_a    = 0.005;
p.std_i    = 0.01;
p.std_y    = 0.005;
m          = assignParameters(m,p);

%% Solve steady-state

m  = checkSteadyState(m,'steady_state_file','rbc_steadystate');
ss = m.getSteadyState()

%% Solve

m = solve(m);

%% Simulate

y = simulate(m,75,'draws',1,'startDate','1990Q1');
y = y.RBC;
% nb_graphSubPlotGUI(y);

%% Filter with the DSGE model

m = set(m,'data',y);
m = filter(m);

%% Set up a VAR in dc, di and dy

t           = nb_var.template();
t.constant  = true;
t.dependent = {'dc','di','dy'};
t.data      = y;
varM        = nb_var(t);
varM        = set(varM,'name','VAR');
varM        = estimate(varM);
varM        = solve(varM);

%% Forecast both models

mFcst = forecast([m,varM],8,'varOfInterest',{'di','dc','dy'});
pFcst = plotForecast(mFcst);
pFcst.set('startGraph','2000Q1');
nb_graphSubPlotGUI(pFcst)

%% Get forecast to interpret

fcstDB = getForecast(mFcst(2),y.endDate + 1);

%% Interpret forecast

opt             = nb_getDefaultOptimset('fmincon');
opt.Display     = 'iter';
opt.MaxFunEvals = inf;
opt.MaxIter     = 500;

[mInt,lik,normDiff] = interpretForecast(m,...
    'fcstDB',fcstDB,...
    'scale',0,...
    'periods',2,...
    'optimset',opt);
mInt = set(mInt,'name','RBC(interpreted)');
                    
%% Plot updated forecast

pFcst = plotForecast([mInt;mFcst]);
pFcst.set('startGraph','2007Q1');
nb_graphSubPlotGUI(pFcst)

%% Get forecast

fcstDBRBC = getForecast(mFcst(1),y.endDate + 1)
fcstDBInt = getForecast(mInt,y.endDate + 1)

%% Interpret forecast
% Using weights

opt             = nb_getDefaultOptimset('fmincon');
opt.Display     = 'iter';
opt.MaxFunEvals = inf;
opt.MaxIter     = 500;

h       = fcstDB.numberOfObservations;
weights = nb_ts([ones(h,1)*0.5,ones(h,1)*0.25,ones(h,1)*0.25],'',...
                fcstDB.startDate,{'dy','dc','di'},false);

[mIntW,lik,normDiff] = interpretForecast(m,...
    'fcstDB',fcstDB,...
    'scale',0,...
    'periods',2,...
    'optimset',opt,...
    'weights',weights);
mIntW = set(mIntW,'name','RBC(weighted)');
                    
%% Plot updated forecast

pFcst = plotForecast([mInt;mIntW;mFcst]);
pFcst.set('startGraph','2007Q1');
nb_graphSubPlotGUI(pFcst)

%% Let us also allow changes in parameters

% Priors
priors       = struct();
priors.rho_a = {0.7, 0, 0.99};
priors.rho_i = {0.7, 0, 0.99};
priors.rho_y = {0.7, 0, 0.99};
m            = set(m,'prior',priors);

%% Interpret forecast
% Where we also let the persistent of the shock processes change!

opt             = nb_getDefaultOptimset('fmincon');
opt.Display     = 'iter';
opt.MaxFunEvals = inf;
opt.MaxIter     = 500;

[mIntEst,lik,normDiff] = interpretForecast(m,...
    'fcstDB',fcstDB,...
    'scale',1,...
    'periods',2,...
    'optimset',opt,...
    'parameters',{'rho_a','rho_i','rho_y'});
mIntEst = set(mIntEst,'name','RBC(changed parameters)');

%% The new parameter values

param = getParameters(mIntEst)

%% Plot updated forecast

pFcst = plotForecast([mIntEst;mInt;mFcst]);
pFcst.set('startGraph','2007Q1');
nb_graphSubPlotGUI(pFcst)
