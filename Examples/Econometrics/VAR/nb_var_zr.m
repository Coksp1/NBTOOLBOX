%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
covPer  = nb_month(1,2020):nb_month(5,2020);
sim     = covidDummy(sim,covPer);

%nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Setup prior
% Giannone, Lenza and Primiceri (2014)

prior = nb_var.priorTemplate('glp');

%% B-VAR

% Options
t                      = nb_var.template();
t.data                 = sim;
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = nb_covidDummyNames(12,covPer);
t.draws                = 1; % Return posterior mode estimate
t.prior                = prior;
t.constant             = true;
t.nLags                = 2;
t.removeZeroRegressors = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR

% Options
t                      = nb_var.template();
t.data                 = sim;
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = nb_covidDummyNames(12,covPer);
t.draws                = 1; % Return posterior mode estimate
t.prior                = prior;
t.constant             = true;
t.nLags                = 2;
t.removeZeroRegressors = true;
t.recursive_estim      = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Setup prior
% Giannone, Lenza and Primiceri (2014)

prior = nb_var.priorTemplate('glpMF');

%% B-VAR
% Missing observations

simM        = sim;
simM(end,1) = nan;

% Options
t                      = nb_var.template();
t.data                 = simM;
t.dependent            = {'VAR1','VAR2','VAR3'};
t.exogenous            = nb_covidDummyNames(12,covPer);
t.draws                = 500; 
t.prior                = prior;
t.constant             = true;
t.nLags                = 2;
t.removeZeroRegressors = true;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR
% Missing observations

simM        = sim;
simM(end,1) = nan;

% Options
t                            = nb_var.template();
t.data                       = simM;
t.dependent                  = {'VAR1','VAR2','VAR3'};
t.exogenous                  = nb_covidDummyNames(12,covPer);
t.draws                      = 500; 
t.prior                      = prior;
t.constant                   = true;
t.nLags                      = 2;
t.removeZeroRegressors       = true;
t.recursive_estim            = true;
t.recursive_estim_start_date = '2019M12';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)
