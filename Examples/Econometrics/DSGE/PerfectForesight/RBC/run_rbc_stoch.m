%% Help on this example

nb_dsge.help
help nb_dsge.getEndVal
help nb_dsge.perfectForesight
help nb_dsge.irf

%% Parse model

m = nb_dsge('nb_file','rbc_stoch.nb');

%% Assign parameters

p       = struct();
p.rho   = 0.7;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Solve steady-state

m  = checkSteadyState(m,'steady_state_file','rbc_steadystate');
ss = m.getSteadyState()

%% Solve for the trajectory

init.k = 3;

[sim,plotter] = perfectForesight(m,'initVal',init);
nb_graphSubPlotGUI(plotter);

%% Solve for the trajectory given a shock to productivity

exoVal        = nb_data(ones(1,1),'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'exoVal',exoVal);
nb_graphSubPlotGUI(plotter);

%% Normal IRF

m       = solve(m);
[~,~,p] = irf(m,'periods',150);
p.set('spacing',20);
nb_graphInfoStructGUI(p)
