%% Help on this example

nb_dsge.help

%% Parse and solve model under optimal policy
% See model file for how to implement optimal policy in this case
%
% Reference: Foerster, Rubio-Ramirez, Waggoner and Zha (2013)
% Perturbation Methods for Markov Switching Models.

m        = nb_dsge('nb_file','frwz_nk.nb','silent',false);
p        = struct();
p.betta  = 0.99;
p.kappa  = 161;
p.eta    = 10;
p.mu     = 0.03;
p.lam_y  = 0.1;
p.lam_dr = 0.1;
m        = assignParameters(m,p);
m        = solve(m,'steady_state_file','frwz_nk_nb_steadystate');

m.printDecisionRules
