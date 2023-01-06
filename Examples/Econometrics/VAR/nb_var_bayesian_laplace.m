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

%% B-VAR (Laplace prior)

% Setup prior
prior           = nb_var.priorTemplate('laplace');
prior.lam2Prior = [];

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
modelRec = nb_var(t);
modelRec = estimate(modelRec);
print(modelRec)

%% B-VAR (Laplace prior)

% Setup prior
prior           = nb_var.priorTemplate('laplace');
prior.lam2Prior = 0.5;

% Options
t            = nb_var.template();
t.data       = sim;
t.dependent  = {'VAR1','VAR2','VAR3'};
t.draws      = 1000; % Return posterior mean estimate (using posterior sim)
t.prior      = prior;
t.constant   = false;
t.nLags      = 2;

% Create model and estimate
modelRec = nb_var(t);
modelRec = estimate(modelRec);
print(modelRec)

%% B-VAR (Laplace prior)

% Setup prior
prior           = nb_var.priorTemplate('laplace');
prior.lam2Prior = 0.5;

% Options
t               = nb_var.template();
t.data          = sim;
t.dependent     = {'VAR1','VAR2','VAR3'};
t.draws         = 1000; % Return posterior mean estimate (using posterior sim)
t.prior         = prior;
t.constant      = false;
t.nLags         = 2;
t.hyperLearning = 1;

% Create model and estimate
modelRec = nb_var(t);
modelRec = estimate(modelRec);
print(modelRec)
