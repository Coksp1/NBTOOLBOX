%% Generate artificial data

rng(1); % Set seed

obs         = 100;
lambda      = [0.5, 0.1,  0.3,  0.6, 0.2,  0.2, -0.1, 0;
               0.5,-0.1, -0.2,  0.4,   0,  0.1, -0.2, 0;
               0.6,-0.2,  0.1, -0.2,   0,  0.4, -0.1, 0;
               0,   0,    0,  0.7,   0,    0,    0, 0]; % Block exogenous
rho         = [1;1;1;1];  
simBloxkExo = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3','VAR4'},1,lambda,rho);

% nb_graphSubPlotGUI(sim);

%% Help on nb_var class

nb_var.help('prior')
help nb_var.priorTemplate

%% B-VAR (Jeffrey prior)
% Block exogenous variable

% Options
t                 = nb_var.template();
t.data            = simBloxkExo;
t.dependent       = {'VAR1','VAR2','VAR3'};
t.block_exogenous = {'VAR4'};
t.prior           = nb_var.priorTemplate('jeffrey');
t.constant        = false;
t.nLags           = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print_estimation_results(model)

%% Solve model, point forecast and evaluate

model   = solve(model);
model   = forecast(model,8,'fcstEval','SE');
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Solve model, density forecast and evaluate

model = forecast(model,8,...
            'draws',1000,'parameterDraws',100,...
            'perc',[0.3,0.5,0.7,0.9]);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);

%% Identify model

model = set_identification(model,'cholesky',...
            'ordering',{'VAR1','VAR2','VAR3','VAR4'});
model = solve(model);

%% Produce irfs 
% With error bands using posterior draws

[~,~,plotter] = irf(model,'replic',100,'perc',0.68);
nb_graphInfoStructGUI(plotter);
