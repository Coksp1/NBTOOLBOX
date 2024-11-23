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

%% Test VAR (Minnesota; Normal-Wishart type) 
% No measurement error

% Prior
prior        = nb_var.priorTemplate('minnesotaMF');
prior.method = 'mci';

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Plot

smoothed           = getFiltered(model);
smoothed           = keepVariables(smoothed,sim.variables);
smoothed.dataNames = {'Smoothed'};
plotted            = addPages(smoothed,sim);
nb_graphSubPlotGUI(plotted);

%% Test VAR (Minnesota; Normal-Wishart type) 
% Measurement errors using a dogmatic prior, same for all variables

% Prior
prior         = nb_var.priorTemplate('minnesotaMF');
prior.method  = 'mci';
prior.R_scale = 10;

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
modelMEAll = nb_var(t);
modelMEAll = estimate(modelMEAll);
print(modelMEAll)

%% Plot

smoothed           = getFiltered(modelMEAll);
smoothed           = keepVariables(smoothed,sim.variables);
smoothed.dataNames = {'Smoothed'};
plotted            = addPages(smoothed,sim);
nb_graphSubPlotGUI(plotted);

%% Forecast
% Caution: The plotted history are with measurement errors removed!

modelMEAll = solve(modelMEAll);
modelMEAll = forecast(modelMEAll,4);
pf         = plotForecast(modelMEAll);
nb_graphSubPlotGUI(pf);

%% Shock decomposition
% Caution: The decomposed history are with measurement errors removed!

modelMEAllI = set_identification(modelMEAll,'cholesky',...
                'ordering',modelMEAll.dependent.name);
modelMEAllI = solve(modelMEAllI);

[sDec,~,plotterSDec] = shock_decomposition(modelMEAllI,...
    'variables',modelMEAllI.dependent.name,'startDate','','endDate','');
nb_graphPagesGUI(plotterSDec)

%% Test VAR (Minnesota; Normal-Wishart type) 
% Measurement errors using a dogmatic prior, different prior for different
% variables

% Prior
prior        = nb_var.priorTemplate('minnesotaMF');
prior.method = 'mci';
prior.R_scale = {
    'VAR1',10
    'VAR2',inf
    'VAR3',20
};

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
modelMESome = nb_var(t);
modelMESome = estimate(modelMESome);
print(modelMESome)

%% Plot

smoothed           = getFiltered(modelMESome);
smoothed           = keepVariables(smoothed,sim.variables);
smoothed.dataNames = {'Smoothed'};
plotted            = addPages(smoothed,sim);
nb_graphSubPlotGUI(plotted);
