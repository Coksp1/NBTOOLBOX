%% Help on this example

nb_dsge.help
help nb_dsge.getEndVal
help nb_dsge.perfectForesight

%% Parse model

% Do we want to display the optimizer output or not?
opt         = nb_getDefaultOptimset(struct(),'fsolve');
opt.Display = 'off';

% Call parser and set some options
m = nb_dsge('nb_file','rbc_stoch.nb','silent',false,'optimset',opt,...
            'steady_state_debug',true,'steady_state_default',@ones,...
            'steady_state_solve',true);

%% Assign parameters

p       = struct();
p.rho   = 0.7;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Options

periods = 80;
e_a_val = 0.1;

%% Solve for a permanent shock to productivity
% Perfect foresight

[sim,plotter,ssTable] = permanentShock(m,...
    'addSS',            true,...
    'blockDecompose',   true,...
    'plotSS',           true,...
    'addEndVal',        true,...
    'periods',          periods,...
    'steady_state_exo', struct('e_a',e_a_val));

% nb_graphSubPlotGUI(plotter);

%% Solve for a permanent shock to productivity
% Break-point

[simB,plotterB,ssTableB] = permanentShock(m,...
    'addSS',            true,...
    'blockDecompose',   true,...
    'plotSS',           true,...
    'addEndVal',        true,...
    'periods',          periods,...
    'steady_state_exo', struct('e_a',e_a_val),...
    'algo',             'breakPoint');

% nb_graphSubPlotGUI(plotterB);

%% Merge plots

mPlotter = merge(plotter,plotterB);
mPlotter.set('legends',{'Perfect foresight','','Break-point','SS'},...
             'subPlotSize',[3,2],'variablesToPlot',{'log(y)','alpha.*y'})
nb_graphSubPlotGUI(mPlotter);
