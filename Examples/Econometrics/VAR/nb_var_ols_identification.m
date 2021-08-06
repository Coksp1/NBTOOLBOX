%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Get help on the nb_var class

nb_var.help
help nb_var.set_identification
help nb_var.getIdentifiedResidual
help nb_model_generic.irf
help nb_model_generic.variance_decomposition
help nb_model_generic.shock_decomposition

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

%% Identify model (cholesky)

modelI = set_identification(model,'cholesky',...
                'ordering',model.dependent.name);

%% Solve model with identification assumption,
% i.e. we know have a structural VAR

modelS = solve(modelI);
            
%% Get identified residual

residual = getIdentifiedResidual(modelS)

%% Produce irfs

% Point
[irfsPoint,~,plotter] = irf(modelS);
nb_graphInfoStructGUI(plotter)

% With error bands
rng(1); % Set seed
[~,irfsBands,plotter] = irf(modelS,'perc',0.68,'replic',500);
nb_graphInfoStructGUI(plotter)

% Return all simulations
rng(1); % Set seed
[~,irfsSim,plotter] = irf(modelS,'perc',[],'replic',500);
nb_graphInfoStructGUI(plotter)

%% Variance decomposition

[dec,decBand,plotterDec,plotterDecPerc] = variance_decomposition(modelS,...
    'variables',modelS.dependent.name,'perc',0.68,'replic',500);
nb_graphPagesGUI(plotterDec)

if ~isempty(plotterDecPerc)
    fields = fieldnames(plotterDecPerc);
    for ii = 1:length(fields)
        plotters = plotterDecPerc.(fields{ii});
        for kk = 1:length(plotters)
            nb_graphSubPlotGUI(plotters(kk));
        end
    end
end

%% Shock decomposition

[sDec,~,plotterSDec] = shock_decomposition(modelS,...
    'variables',modelS.dependent.name,'startDate','','endDate','');
nb_graphPagesGUI(plotterSDec)
