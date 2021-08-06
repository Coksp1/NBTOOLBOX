%% Help on this example

nb_dsge.help
help nb_dsge.irf
help nb_dsge.reporting

%% Parse model

m = nb_dsge('nb_file','nk_rule_ext.nb','silent',false);

%% Parameterization

par            = struct();
par.beta       = 0.99;
par.eta        = 1;
par.alpha      = 0.33;
par.epsilon    = 6;
par.theta      = 0.67;
par.varphi     = 1;
par.rho_u      = 0.7;
par.rho_e      = 0.7;
par.rho_m      = 0.7;
par.gamma_pie  = 1.2;
par.gamma_pie1 = 0;
par.gamma_y    = 0.05;
m              = assignParameters(m,par);

%% Solve

m = solve(m);

%% IRFs (sperate graph for each shock)

[~,~,plotter] = irf(m,'variables',  {'i','pie','y','gamma_y.*(y-steady_state(y)).^2','i-lag(i)'},...
                      'shocks',     {'e_u','e_e','e_i'},...
                      'settings',   {'subPlotSize',[2,2]});
nb_graphInfoStructGUI(plotter);


%% IRFs (compare shocks in one graph)


[~,~,plotter] = irf(m,'variables',      {'i','pie','y','gamma_y.*(y-steady_state(y)).^2'},...
                      'shocks',         {'e_u','e_e','e_i'},...
                      'settings',       {'subPlotSize',[2,2]},...
                      'compareShocks',  1);
nb_graphSubPlotGUI(plotter);

%% IRFs (compare shocks in one graph)
% Normalize the response to one variable

[~,~,plotter] = irf(m,'variables',      {'i','pie','y'},...
                      'shocks',         {'e_u','e_e','e_i'},...
                      'settings',       {'subPlotSize',[2,2]},...
                      'compareShocks',  1,...
                      'normalize',      {'y',1,2});
nb_graphSubPlotGUI(plotter);

%% IRFs (compare variables in one graph)

[~,~,plotter] = irf(m,'variables',      {'i','pie','y','gamma_y.*(y-steady_state(y)).^2'},...
                      'shocks',         {'e_u','e_e','e_i'},...
                      'settings',       {'subPlotSize',[2,2]},...
                      'compareVars',    1);
nb_graphSubPlotGUI(plotter);
