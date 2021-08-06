%% Help on this example

nb_dsge.help
help nb_dsge.perfectForsight

%% Pare model

mr = nb_dsge('nb_file','cgg_rule.nb','silent',false);

%% Parameterization

param            = struct();
param.alpha      = 0.1;
param.beta       = 1;
param.gamma_i    = 0;
param.gamma_pie  = 1.2;
param.gamma_y    = 0.338;
param.lambda_eps = 0.7;
param.lambda_eta = 0.7;
param.lambda_em  = 0.7;
param.phi        = 0.5;
param.theta      = 0.5;
param.varphi     = 0.8;
mr               = assignParameters(mr,param);

%% Solve steady-state

mr = checkSteadyState(mr);
ss = getSteadyState(mr)

%% Solve for a temorary shock to demand
% derivative free solving multivariate non-linear

periods       = 80;
e_eps_val     = -0.1;
endVal        = getEndVal(mr);
exoVal        = nb_data([ones(1,1)*e_eps_val;zeros(periods-1,1)],'',1,{'e_eps'});
[sim,plotter] = perfectForesight(mr,'endVal',endVal,'exoVal',exoVal,...
                                    'periods',periods);
plotter.set('subPlotSize',[3,3]);                               
nb_graphSubPlotGUI(plotter);

%% Dynare
% Dynare code must be added separatly

dynare('cgg_rule.dyn')
