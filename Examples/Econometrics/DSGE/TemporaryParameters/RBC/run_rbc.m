%% Help on this example

nb_dsge.help

%% Parse model

m = nb_dsge('nb_file','rbc_stoch3.nb','tempParametersVerbose',false);

%% Assign parameters

p.rho   = 0.2;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Solve model

m = set(m,'steady_state_default',@ones,'steady_state_solve',true);
m = solve(m);
