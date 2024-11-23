%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% Options

constant        = true;
constantDiffuse = true;

%% B-VAR (OLS)

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.constant   = constant;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR (Laplace prior, mean)

% Setup prior
prior                 = nb_var.priorTemplate('laplace');
prior.lambda          = [];
prior.constantDiffuse = constantDiffuse;

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = constant;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR (Laplace prior, mode)

% Setup prior
prior                 = nb_var.priorTemplate('laplace');
prior.lambda          = 20; % Must be set in this case!
prior.constantDiffuse = constantDiffuse;

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = constant;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% Density forecast from end of sample

nSteps  = 8;
modelS  = solve(model);
modelF  = forecast(modelS,nSteps,...
            'draws',1,...
            'parameterDraws',2000);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% B-VAR (Laplace prior)

% Setup prior
prior                 = nb_var.priorTemplate('laplace');
prior.lambda          = 40;
prior.constantDiffuse = constantDiffuse;

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = constant;
t.nLags      = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Density forecast from end of sample

nSteps  = 8;
modelS  = solve(model);
modelF  = forecast(modelS,nSteps,...
            'draws',1,...
            'parameterDraws',2000);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

%% B-VAR (Laplace prior, mean, recursive)

% Setup prior
prior                 = nb_var.priorTemplate('laplace');
prior.lambda          = [];
prior.constantDiffuse = constantDiffuse;

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.draws     = 1000; % Return posterior mean estimate (using posterior sim)
t.prior     = prior;
t.constant  = constant;
t.nLags     = 2;

t.recursive_estim            = true;
t.recursive_estim_start_date = '2019M1';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)

%% B-VAR (Laplace prior, mode)

% Setup prior
prior                 = nb_var.priorTemplate('laplace');
prior.lambda          = 20; % Must be set in this case!
prior.constantDiffuse = constantDiffuse;

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1; % Return posterior mode estimate
t.prior      = prior;
t.constant   = constant;
t.nLags      = 2;

t.recursive_estim            = true;
t.recursive_estim_start_date = '2019M1';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)
printCov(model)
