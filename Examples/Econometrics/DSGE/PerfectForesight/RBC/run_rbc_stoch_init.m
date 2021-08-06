%% Parse stochastic model

ms = nb_dsge('nb_file','rbc_stoch.nb');

%% Assign parameters

p       = struct();
p.rho   = 0.8;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
ms      = assignParameters(ms,p);

%% Solve steady-state

ms = checkSteadyState(ms,'steady_state_file','rbc_steadystate');
ss = ms.getSteadyState()

%% Solve for the trajectory
% Simulate starting point

init          = struct();
init.k        = [2.5,3.5];
[sim,plotter] = perfectForesight(ms,'initVal',init,'stochInitVal',true,...
                	'nLags',0,'draws',500,'plotInitSS',true);
nb_graphSubPlotGUI(plotter);

%% Solve for the trajectory
% Simulate starting point, using past dependence

init               = struct();
init.k             = [2.5,3.5];
[sim,plotter,dSim] = perfectForesight(ms,'initVal',init,'stochInitVal',true,...
                        'nLags',1,'draws',500,'plotInitSS',true);
nb_graphSubPlotGUI(plotter);

%% Solve for the trajectory
% Simulate starting point, using past dependence
% High consumption

init               = struct();
init.k             = [2.5,3.5];
init.c             = 1;
[sim,plotter,dSim] = perfectForesight(ms,'initVal',init,'stochInitVal',true,...
                        'nLags',5,'draws',500,'plotInitSS',true);
nb_graphSubPlotGUI(plotter);

%% Solve for the trajectory
% Simulate starting point, using past dependence
% Low consumption

init               = struct();
init.k             = [2.5,3.5];
init.c             = 0.3;
[sim,plotter,dSim] = perfectForesight(ms,...
    'initVal',init,...
    'stochInitVal',true,...
    'nLags',5,...
    'draws',500,...
    'plotInitSS',true);
nb_graphSubPlotGUI(plotter);

%% Do a permanent shock

e_a_val       = 0.1;
[sim,plotter] = permanentShock(ms,...
    'periods',80,...
    'plotInitSS',true,...
    'steady_state_block',true,...
    'steady_state_exo',struct('e_a',e_a_val));
nb_graphSubPlotGUI(plotter);

%% Do a permanent shock on top of drawing from initial conditions

init          = struct();
init.k        = [2.5,3.5];
init.c        = 1;
e_a_val       = 0.1;
[sim,plotter] = permanentShock(ms,...
    'periods',80,...
    'initVal',init,...
    'stochInitVal',true,...
    'nLags',5,...
    'draws',500,...
    'plotInitSS',true,...
    'steady_state_block',true,...
    'steady_state_exo',struct('e_a',e_a_val));
nb_graphSubPlotGUI(plotter);

%% Do a permanent shock
% Starting from a point of high capital and consumption

init          = struct();
init.k        = 3;
init.c        = 1;
init.a        = 2.75;
e_a_val       = 0.1;
[sim,plotter] = permanentShock(ms,...
    'initVal',init,...
    'periods',80,...
    'plotInitSS',true,...
    'steady_state_block',true,...
    'steady_state_exo',struct('e_a',e_a_val));
nb_graphSubPlotGUI(plotter);

%% Do a permanent shock on top of drawing from initial conditions
% Delta == true gives IRF

init          = struct();
init.k        = [2.5,3.5];
init.c        = 1;
e_a_val       = 0.1;
[sim,plotter] = permanentShock(ms,...
    'periods',80,...
    'delta',true,...
    'initVal',init,...
    'stochInitVal',true,...
    'nLags',5,...
    'draws',500,...
    'plotInitSS',true,...
    'steady_state_block',true,...
    'steady_state_exo',struct('e_a',e_a_val));
nb_graphSubPlotGUI(plotter);

%% Do a permanent shock
% Starting from a point of high capital and consumption

init          = struct();
init.k        = 3;
init.c        = 1;
init.a        = 2.75;
e_a_val       = 0.1;
[sim,plotter] = permanentShock(ms,...
    'delta',true,...
    'initVal',init,...
    'periods',80,...
    'plotInitSS',true,...
    'steady_state_block',true,...
    'steady_state_exo',struct('e_a',e_a_val));
nb_graphSubPlotGUI(plotter);
