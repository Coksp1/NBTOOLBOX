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

p       = struct();
p.rho   = 0.7;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Solve steady-state

m  = checkSteadyState(m,'steady_state_file','rbc_steadystate');
ss = m.getSteadyState();

%% Solve for a permanent shock to productivity

periods      = 80;
e_a_val      = 0.1;
endVal       = getEndVal(m,'steady_state_exo',struct('e_a',e_a_val));
exoVal       = nb_data(ones(periods,1)*e_a_val,'',1,{'e_a'});
[sim,pFirst] = perfectForesight(m,'endVal',endVal,'exoVal',exoVal,...
                                  'periods',periods);
% nb_graphSubPlotGUI(pFirst);

%% Solve for a permanent shock to productivity that happend some periods
% ahead (expected from period 1!)

periods    = 80;
e_a_val    = 0.1;
per        = 10;
endVal     = getEndVal(m,'steady_state_exo',struct('e_a',0.1));
exoVal     = nb_data([zeros(per-1,1);ones(periods-per+1,1)*e_a_val],'',1,{'e_a'});
[sim,pExp] = perfectForesight(m,'exoVal',exoVal,'endVal',endVal,...
                                'periods',periods);
% nb_graphSubPlotGUI(pExp);

%% Solve for a permanent shock to productivity that happend some periods
% ahead (expected from period per!)

periods              = 80;
e_a_val              = 0.1;
per                  = 10;
endValInit           = getEndVal(m); % End at the current steady-state
endValPerm           = getEndVal(m,'steady_state_exo',struct('e_a',0.1));
endVal               = [endValInit,endValPerm];
exoData              = nan(periods,1,2);
exoData(:,:,1)       = 0;
exoData(per:end,:,2) = e_a_val;
exoVal               = nb_data(exoData,'',1,{'e_a'});
[sim,pUnexp]         = perfectForesight(m,'exoVal',exoVal,'endVal',endVal,...
                                          'periods',periods);
% nb_graphSubPlotGUI(pUnexp);

%% Plot together

p = merge(pFirst,pExp,pUnexp);
p.set('legends',{'First period','Expected','Unexpected'});
nb_graphSubPlotGUI(p);


