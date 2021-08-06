%% Open parallel session

ret = nb_openPool();

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Initalize many objects

t                 = nb_var.template(10);
t.data            = sim;
t.dependent       = {'VAR1','VAR2','VAR3'};
t.recursive_estim = true;
t.nLags           = {1,2,3,4,5,6,7,8,9,10};
t                 = [t,t,t]; % Just make a lot of models!
models            = nb_model_generic.initialize('nb_var',t);

%% Estimate 

tic
models = estimate(models,'waitbar');
toc

%% Estimate in parallel

tic
models = estimate(models,'parallel');
toc

%% Solve

models = solve(models);

%% Forecast

tic
models = forecast(models,8,'fcstEval','SE','waitbar');
toc

%% Forecast in parallel

tic
models = forecast(models,8,'fcstEval','SE','parallel',true);
toc

%% Parameter draws

t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.nLags     = 1;
model       = nb_var(t);
model       = estimate(model);
model       = solve(model);

% Normal
tic
modelD = parameterDraws(model,1000,'','object',false);
toc

% Parallel (This is very slow unless you really are struggeling with 
% identification or stationarity!!)      
tic
modelD = parameterDraws(model,1000,'','object',false,'parallel',true);
toc

%% Parameter draws

t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.nLags     = 1;
t.prior     = nb_var.priorTemplate();
model       = nb_var(t);
model       = estimate(model);
model       = solve(model);

% Normal
tic
modelD = parameterDraws(model,1000,'','object',false);
toc

% Parallel (This is very slow unless you really are struggeling with 
% identification or stationarity!!)      
tic
modelD = parameterDraws(model,1000,'','object',false,'parallel',true);
toc

%% Close parallel session

nb_closePool(ret)
