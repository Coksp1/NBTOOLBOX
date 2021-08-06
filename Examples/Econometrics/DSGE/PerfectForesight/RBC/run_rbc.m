%% Help on this example

nb_dsge.help
help nb_dsge.perfectForesight

%% Parse model

m = nb_dsge('nb_file','rbc.nb');

%% Assign parameters

p.rho   = 0.8;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Solve steady-state

m  = checkSteadyState(m,'steady_state_file','rbc_steadystate');
ss = m.getSteadyState()

%% Solve for the trajectory

init.k        = 3;
init.a        = 1;
[sim,plotter] = perfectForesight(m,'initVal',init);
nb_graphSubPlotGUI(plotter);

%% Solve for the trajectory (Automatic)

init.k          = 3;
[simA,plotterA] = perfectForesight(m,'initVal',init,...
                        'derivativeMethod','automatic');
nb_graphSubPlotGUI(plotterA);
