%% Generate artificial data

rng(1); % Set seed

obs         = 100;
lambda      = [0.5, 0.1,  0.3,  0.6, 0.2,  0.2, -0.1, 0;
               0.5,-0.1, -0.2,  0.4,   0,  0.1, -0.2, 0;
               0.6,-0.2,  0.1, -0.2,   0,  0.4, -0.1, 0;
               0,   0,    0,    0.7,   0,    0,    0, 0]; % Block exogenous
rho         = [1;1;1;1];  
simBlockExo = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3','VAR4'},1,lambda,rho);

% nb_graphSubPlotGUI(sim);


%% VAR (OLS)

% Options
t           = nb_var.template();
t.data      = simBlockExo;
t.dependent = {'VAR1','VAR2','VAR3','VAR4'};
t.constant  = false;
t.nLags     = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
% print_estimation_results(model)

model.results.beta'

%% VAR (OLS)
% with block exogenous variables

% Options
t                  = nb_var.template();
t.data             = simBlockExo;
t.dependent        = {'VAR1','VAR2','VAR3'};
t.block_exogenous  = {'VAR4'};
% t.blockLags        = 1;
t.constant         = false;
t.nLags            = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
% print_estimation_results(model)

model.results.beta'
