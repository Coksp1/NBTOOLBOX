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
par.gamma_pie  = 1.2;
par.gamma_pie1 = 0;
par.gamma_y    = 0.05;
m              = assignParameters(m,par);

%% Solve

m = solve(m);

%% Reporting

rep = {% 'VarName','Expression','notes'
'r',    'i - lead(pie)', ''
};
m = set(m,'reporting',rep);

%% IRFs

[~,~,plotter] = irf(m,'variables',{'i','pie','y','r'},...
                      'settings',{'subPlotSize',[2,2]});
nb_graphInfoStructGUI(plotter);

%% Normalize IRFs

[~,~,plotter] = irf(m,'variables',{'i','pie','y','r'},...
                      'settings',{'subPlotSize',[2,2]},...
                      'normalize',{'i',1,2});
nb_graphInfoStructGUI(plotter);

%% Normalize IRFs (of reported variable)

[~,~,plotter] = irf(m,'variables',{'i','pie','y','r'},...
                      'settings',{'subPlotSize',[2,2]},...
                      'normalize',{'r',1,2});
nb_graphInfoStructGUI(plotter);
