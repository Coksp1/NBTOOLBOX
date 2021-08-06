%% Help on this example

nb_dsge.help
help nb_dsge.checkSteadyState
help nb_dsge.getSteadyState 

%% NB Toolbox
% Nonlinear New Keynesian Model
% Reference: Foerster, Rubio-Ramirez, Waggoner and Zha (2013)
% Perturbation Methods for Markov Switching Models.

% Parse
m = nb_dsge('nb_file','frwz_nk.nb');

%% Assign parameters
p       = struct();
p.betta = 0.99;
p.kappa = 161;
p.eta   = 10;
p.rhor  = 0.8;
p.sigr  = 0.0025;
p.mu    = 0.03;
p.psi   = 3.1;
m       = assignParameters(m,p);

% Get parameters
pOut = m.getParameters();

%% Check steady-state solution provided by a file

m1 = checkSteadyState(m,'steady_state_file','frwz_nk_nb_steadystate');
ss = getSteadyState(m1);
ss = getSteadyState(m1,'RR*2');

%% Solve steady-state numerically

init     = struct();
init.Y   = 0.9;
init.RR  = 1.0509;
init.R   = 1.0509;
init.PAI = 0.8;

m1 = checkSteadyState(m,...
    'solver','fsolve',...
    'steady_state_init',init,...
    'steady_state_solve',true);
ss = getSteadyState(m1)

%% Solve steady-state numerically, fixing PAI
% This amount to solve a non-square systems, and the solver must handle
% that to be able to solve the problem!

init      = struct();
init.Y    = 0.1;
init.RR   = 1.7;
init.R    = 1.0509;
fixed     = struct();
fixed.PAI = 1;

m1 = checkSteadyState(m,...
    'solver','fsolve',...
    'steady_state_fixed',fixed,...
    'steady_state_init',init,...
    'steady_state_solve',true);
ss = getSteadyState(m1)

%% Compute derivatives
m1 = derivative(m1);
m2 = derivative(m1,'derivativeMethod','symbolic');
% Found in m1.solution or m2.solution

%% Solve for the companion form
m1 = solve(m1);
% Found in m1.solution

%% Directly jump to companion form
m = solve(m,'steady_state_file','frwz_nk_nb_steadystate');

%% Total time

t       = tic;
m       = nb_dsge('nb_file','frwz_nk.nb','silent',false);
p.betta = 0.99;
p.kappa = 161;
p.eta   = 10;
p.rhor  = 0.8;
p.sigr  = 0.0025;
p.mu    = 0.03;
p.psi   = 3.1;
m       = assignParameters(m,p);
m       = solve(m,'steady_state_file','frwz_nk_nb_steadystate');

disp(' ')
elapsedTime = toc(t);
disp(['NB Toolbox done in ' num2str(elapsedTime) ' seconds'])
disp(' ')

%% Assign posterior draws (In this case just simulated from a dummy 
% distribution)

param = {'kappa','psi'};
value = [p.kappa + randn(1,1,1000)*100;
         p.psi + randn(1,1,1000)*5];
mDraws = assignPosteriorDraws(m,'param',param,'value',value);     

[~,~,plotter] = irf(mDraws,'replic',1000,'perc',[0.68]);
nb_graphInfoStructGUI(plotter);

