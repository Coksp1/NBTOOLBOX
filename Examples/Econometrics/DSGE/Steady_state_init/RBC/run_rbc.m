%% Help on this example

nb_dsge.help

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
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
p.rho_a = 0.5;
p.rho_i = 0.7;
p.rho_y = 0.2;
p.std_a = 0.1;
p.std_i = 0.15;
p.std_y = 0.05;
m       = assignParameters(m,p);

%% Solve steady state of the model

m  = solve(m);
ss = m.getSteadyState()

%% Add break point

mBP = addBreakPoint(m,{'alpha'},0.2,'2000Q2');

%% Solve steady state of the model

mBP  = solve(mBP);
ssBP = mBP.getSteadyState()

%% IRF (Of break)

% IRFs
periods = 40;
[~,~,p] = irf(mBP,...
            'periods',periods,...
            'shocks',{'states'},...
            'variables',{'y','y_gap','y_gap_init'},...
            'states',ones(periods,1)*2,...
            'startingValues','steady_state(1)',...
            'plotSS',true,...
            'plotDevInitSS',false,...
            'factor',{'*_gap',100});
p.set('spacing',5,'startGraph','1');        
nb_graphInfoStructGUI(p);
