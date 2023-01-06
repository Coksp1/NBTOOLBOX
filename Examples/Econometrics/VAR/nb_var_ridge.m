%% Get help on the nb_var class

nb_var.help

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Estimate VAR (OLS)

% Options
t              = nb_var.template();
t.data         = sim;
t.estim_method = 'ridge';
t.dependent    = sim.variables;
t.constant     = false;
t.nLags        = 2;
t.doTests      = 1;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (Recursive)

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ridge';
t.dependent       = sim.variables;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Estimate VAR (Rolling window)

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ridge';
t.dependent       = sim.variables;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;
t.rollingWindow   = 40;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)
