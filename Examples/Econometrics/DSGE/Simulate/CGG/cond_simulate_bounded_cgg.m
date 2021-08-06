%% Help on this example

nb_dsge.help
help nb_dsge.simulate

%% Model with rule

mr = nb_dsge('nb_file','cgg_rule.nb','silent',false,'name','taylor');

% Parameterization
param           = struct();
param.alpha     = 0.1;
param.beta      = 1;
param.gamma_eps = 0;
param.gamma_eta = 0;
param.gamma_i   = 0;
param.gamma_pie = 1.2;
param.gamma_y   = 0.338;
param.phi       = 0.5;
param.theta     = 0.5;
param.varphi    = 0.8;
mr              = assignParameters(mr,param);
mr              = solve(mr);

%% Simulate

y = simulate(mr,40,'draws',1);
y = y.taylor;

%% Simulate with bounds

bounds.i = struct('shock','e','lower',-3,'upper',inf);

yB = simulate(mr,40,'draws',1,'bounds',bounds);
yB = yB.taylor;

%% Compare

sim = addPages(y,yB);
nb_graphSubPlotGUI(sim);
