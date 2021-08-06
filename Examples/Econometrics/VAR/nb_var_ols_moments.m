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
help nb_model_generic.simulate
help nb_model_generic.simulatedMoments
help nb_model_generic.theoreticalMoments
help nb_model_generic.empiricalMoments

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

%% Solve model

modelS = solve(model);

%% Simulate model

out   = simulate(modelS,1000,...
                 'parameterDraws',10,...
                 'draws',         100,...
                 'burn',          100,...
                 'output',        'all');

%% Simulated moments

[m,c,ac1,ac2] = simulatedMoments(modelS,...
                    'nSteps',   100,...
                    'output',   'nb_cs',...
                    'pDraws',   1,...
                    'draws',    1000,...
                    'perc',     [],...[0,0.3,0.5,0.7,0.9]
                    'type',     'covariance');             
             
%% Theoretical moments

model             = solve(model);
[mt,ct,ac1t,ac2t] = theoreticalMoments(modelS,...
                        'output',    'nb_cs',...
                        'maxIter',   1000,...
                        'pDraws',    500,...
                        'perc',      [0,0.9],...
                        'type',      'covariance');
     
%% Empirical moments

[me,ce,ac1e,ac2e] = empiricalMoments(modelS,...
                        'output',    'nb_cs',...
                        'type',      'covariance');                    
                   
%% Graph theoretical moments against empirical moments 
% With error bands
                    
plotter = nb_model_generic.graphCorrelation(...
    'VAR1',modelS.dependent.name,ct,ce,ac1t,ac1e,ac2t,ac2e);
nb_graphPagesGUI(plotter);
