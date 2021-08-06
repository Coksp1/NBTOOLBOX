%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

% nb_graphSubPlotGUI(sim);

%% Estimate VAR (OLS)

% Options
t              = nb_var.template();
t.data         = sim;
t.estim_method = 'ols';
t.dependent    = sim.variables;
t.constant     = false;
t.nLags        = 2;
t.stdType      = 'h';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Solve model (Companion form)

modelS = solve(model);
sol    = modelS.solution

% help nb_var.solution

%% Bootstrap VAR

rng('default'); % Set to default seed

% Get the parameters only (struct)
param    = parameterDraws(modelS,1000);

% Get the solution (Companion form)
solution = parameterDraws(modelS,1000,'','solution');

% Return one object for each bootstrapped parameter value
models   = parameterDraws(modelS,1000,'','object');
