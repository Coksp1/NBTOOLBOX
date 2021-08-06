

%% Parse model

rbc = nb_dsge('nb_file','rbc.nb',...
              'steady_state_debug',true,...
              'steady_state_file','rbc_steadystate',...
              'name','RBC');
p   = rbc_param(1);
rbc = assignParameters(rbc,p);   

%% Solve model

rbc = solve(rbc);

%% Parse model
% With observation model

rbcObs = nb_dsge('nb_file','rbc_obs.nb',...
                 'steady_state_file','rbc_steadystate',...
                 'name','RBC OBS');
p      = rbc_param(2);
rbcObs = assignParameters(rbcObs,p);   

%% Solve model
% With observation model

rbcObs = solve(rbcObs);

%% IRF
% To check that they lead to the same result for the core model...

[~,~,p] = irf([rbc,rbcObs]);
nb_graphInfoStructGUI(p)

%% IRF
% Of all shocks of the model with the observation model included

[~,~,p] = irf(rbcObs);
nb_graphInfoStructGUI(p)
