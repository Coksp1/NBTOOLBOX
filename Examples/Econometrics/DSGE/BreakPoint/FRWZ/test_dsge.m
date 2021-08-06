%% Help on this example

nb_dsge.help
help nb_dsge.addBreakPoint
help nb_dsge.getSteadyState
help nb_dsge.irf

%% Parse model 
% Reference: Foerster, Rubio-Ramirez, Waggoner and Zha (2013)
% Perturbation Methods for Markov Switching Models.

m = nb_dsge('nb_file','frwz_nk.nb','silent',false,...
            'steady_state_file','frwz_nk_nb_steadystate');

%% Assign baseline calibration

p.betta  = 0.99;
p.kappa  = 161;
p.eta    = 10;
p.sigr   = 0.0025;
p.mu     = 0.03;
p.lam_y  = 0.1;
p.lam_dr = 0.1;
p.PAI_SS = 1;
m        = assignParameters(m,p);

%% Assign new inflation target

mBP = addBreakPoint(m,{'PAI_SS'},1.1,'2000Q1'); % The date is not important in this example!

%% Solve model in both regimes

mBP = solve(mBP);

%% Compare old steady-state and steady-state after the break

ssBP = getSteadyState(mBP,'','headers')

%% IRF (Of break)

% IRFs
periods = 40;
[~,~,p] = irf(mBP,...
            'periods',periods,...
            'shocks',{'states'},...
            'variables',{'PAI','Y','R','RR','PAI_GAP','Y_GAP'},...
            'states',ones(periods,1)*2,...
            'startingValues','steady_state(1)',...
            'plotSS',true,...
            'plotDevInitSS',false,...
            'factor',{'*_GAP',100});
p.set('spacing',5,'startGraph','1');        
nb_graphInfoStructGUI(p);
