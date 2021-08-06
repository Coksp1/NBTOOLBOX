%% Help on this example

nb_dsge.help
help nb_dsge.getEndVal
help nb_dsge.perfectForesight

%% Parse model

% Do we want to display the optimizer output or not?
opt         = nb_getDefaultOptimset(struct(),'fsolve');
opt.Display = 'off';

% Call parser and set some options
m = nb_dsge('nb_file','rbc_stoch.nb','silent',false,'optimset',opt);

%% Assign parameters

p.rho   = 0.7;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Solve steady-state

m  = checkSteadyState(m,'steady_state_file','rbc_steadystate');
ss = m.getSteadyState();

%% Solve for a permanent shock to productivity

periods       = 80;
e_a_val       = 0.1;
endVal        = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val));
exoVal        = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                   'periods',periods);
nb_graphSubPlotGUI(plotter);

%% Solve for a permanent shock to productivity
% Using homotopy to solve for end values
% 
% Equally spaced grid during homotopy

periods       = 80;
e_a_val       = 0.1;
endVal        = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val),...
                            'homotopyAlgorithm',1,'homotopySteps',10);
exoVal        = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                   'periods',periods);
nb_graphSubPlotGUI(plotter);

%% Solve for a permanent shock to productivity
% Using homotopy and block decomposition to solve for end values
% 
% Equally spaced grid during homotopy

periods       = 80;
e_a_val       = 0.1;
endVal        = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val),...
                            'homotopyAlgorithm',1,'homotopySteps',10,...
                            'steady_state_block',true);
exoVal        = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                   'periods',periods);
nb_graphSubPlotGUI(plotter);

%% Solve for a permanent shock to productivity
% Using homotopy to solve for end values
% 
% Equally spaced grid during homotopy, but doing one shock at the time
% (Stupid in this case as we only have one shock)

periods       = 80;
e_a_val       = 0.1;
endVal        = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val),...
                            'homotopyAlgorithm',2,'homotopySteps',10);
exoVal        = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                   'periods',periods);
nb_graphSubPlotGUI(plotter);

%% Solve for a permanent shock to productivity
% Using homotopy to solve for end values
% 
% Split problem if one step fails (In this case we have a easy problem,
% so we will jump directly to the solution!)

periods       = 80;
e_a_val       = 0.1;
endVal        = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val),...
                            'homotopyAlgorithm',3,'homotopySteps',10);
exoVal        = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,plotter] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                   'periods',periods);
nb_graphSubPlotGUI(plotter);
