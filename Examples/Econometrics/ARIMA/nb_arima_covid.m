%% Help on the nb_arima class

nb_arima.help

%% Simulate some ARIMA processes

rng(1); % Set seed
obs = 110;

% Define covid names and dates
[covidDates,drop] = nb_covidDates(4);
covidDates        = covidDates(1:end-drop);
covidDummyNames   = nb_covidDummyNames(4);
covidDummyNames   = covidDummyNames(1:end-drop);

% Set up covid dummies for simulation
covid = nb_ts.zeros('1996Q1',obs,{'ZEROS'});
covid = double(keepVariables(covidDummy(covid,covidDates),covidDummyNames));

% Simulate some ARIMA processes
B     = -[8, -3, 1, -1, 0, 0]';
draws = randn(obs,1);
x     = randn(obs,1);
x2    = randn(obs,1);
sim1  = ones(obs + 1,1);
for tt = 1:obs
   sim1(tt+1) = 0.9*sim1(tt) + 0.5*x(tt) + covid(tt,:)*B + draws(tt);
end
sim1 = sim1(2:end);

sim2  = ones(obs + 1,1);
for tt = 1:obs
   sim2(tt+1) = 0.9*sim2(tt) + covid(tt,:)*B + draws(tt);
end
sim2 = sim2(2:end) + 0.5*x2;

sim3  = ones(obs + 1,1);
for tt = 1:obs
   sim3(tt+1) = 0.9*sim3(tt) + 0.5*x(tt) + covid(tt,:)*B + draws(tt);
end
sim3 = sim3(2:end) + 0.5*x2;

% Transform to nb_ts object
sim = nb_ts([sim1,sim2,sim3,x,x2,covid],'','1996Q1',...
 [{'Sim1','Sim2','Sim3','x','x2'},covidDummyNames]);

%nb_graphSubPlotGUI(sim);

%% AR
% Using covid dummies

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = 0;
t.data             = sim;
t.dependent        = {'Sim2'};
t.exogenous        = covidDummyNames;
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;

% t.removeZeroRegressors = true;
% t.estim_end_date       = '2020Q4';

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X
% Using covid dummies

t                      = nb_arima.template;
t.algorithm            = 'hr';
t.constant             = 0;
t.data                 = sim;
t.dependent            = {'Sim3'};
t.exogenous            = [{'x','x2'},covidDummyNames];
t.transition           = [true,false(1, 1 + length(covidDummyNames))];
t.AR                   = 1;
t.MA                   = 0;
t.integration          = 0;
t.recursive_estim      = true;
t.removeZeroRegressors = true;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X, recursive
% Removing all rows of the estimation data from the covid periods

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = true;
t.data             = sim;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;
t.recursive_estim  = true;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR
% Removing all rows of the estimation data from the covid periods

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = 0;
t.data             = sim;
t.dependent        = {'Sim1'};
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X
% Removing all rows of the estimation data from the covid periods

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = true;
t.data             = sim;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X, recursive
% Removing all rows of the estimation data from the covid periods

t                  = nb_arima.template;
t.algorithm        = 'hr';
t.constant         = true;
t.data             = sim;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;
t.recursive_estim  = true;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X
% Removing all rows of the estimation data from the covid periods

t                  = nb_arima.template;
t.algorithm        = 'ml';
t.constant         = true;
t.data             = sim;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;

model  = nb_arima(t);
model = estimate(model);
print(model)

%% AR-X
% Removing all rows of the estimation data from the covid periods

prior = nb_arima.priorTemplate();

t                  = nb_arima.template;
t.prior            = prior;
t.constant         = true;
t.data             = sim;
t.dependent        = {'Sim3'};
t.exogenous        = {'x','x2'};
t.transition       = [true,false];
t.AR               = 1;
t.MA               = 0;
t.integration      = 0;
t.covidAdj         = covidDates;

model  = nb_arima(t);
model = estimate(model);
print(model)

