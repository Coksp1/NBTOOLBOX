%% Help on this example

nb_dsge.help
help nb_dsge.setLossFunction
help nb_dsge.calculateLoss
help nb_dsge.optimalSimpleRules
help nb_dsge.getLoss

%% Parse model

m = nb_dsge('nb_file','nk.nb','silent',false);

%% Parameterization

par         = struct();
par.beta    = 0.99;
par.eta     = 1;
par.alpha   = 0.33;
par.epsilon = 6;
par.theta   = 0.67;
par.varphi  = 1;
par.rho_u   = 0;
par.rho_e   = 0;
m           = assignParameters(m,par);

%% Set loss function

paramL = struct('lambda',0.1);
m      = setLossFunction(m,'0.5*(pie^2 + lambda*y^2)');
m      = assignParameters(m,paramL);

%% Optimal monetary policy commitment

mc        = solve(m,'lc_commitment',1,'lc_discount',1,'name','c');
[mc,loss] = calculateLoss(mc);
mc.printDecisionRules()
loss

%% Optimal simple rule (commitment)
% This replicate the commitment solution

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_pie_lag',1.2,'gamma_y_lag',0.6,...
                     'gamma_e',0,'gamma_u',0);
m_osr_c    = optimalSimpleRules(m,...
'i = gamma_pie*pie + gamma_y*y + gamma_pie_lag*pie(-1) + gamma_y_lag*y(-1) + gamma_e*e_e + gamma_u*e_u',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c');
m_osr_c.print()
m_osr_c.printDecisionRules()

%% Optimal monetary policy discretion

md        = solve(m,'lc_commitment',0,'lc_discount',1,'name','d');
[md,loss] = calculateLoss(md);
md.printDecisionRules()
loss

%% Optimal simple rule (discretion)
% This replicate the discretionary solution

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.1,...
                     'gamma_e',0,  'gamma_u',0);
m_osr_d    = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1) + gamma_e*e_e + gamma_u*e_u',...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d');
m_osr_d.print()
m_osr_d.printDecisionRules()

%% Model with rule

mr = nb_dsge('nb_file','nk_rule.nb','silent',false,'name','taylor');

% Parameterization
par           = struct();
par.beta      = 0.99;
par.eta       = 1;
par.alpha     = 0.33;
par.epsilon   = 6;
par.theta     = 0.67;
par.varphi    = 1;
par.rho_u     = 0;
par.rho_e     = 0;
par.gamma_pie = 1.2;
par.gamma_y   = 0.338;
mr              = assignParameters(mr,par);
mr              = solve(mr);
mr.printDecisionRules

% Set loss function
paramL    = struct('lambda',0.5);
mr        = setLossFunction(mr,'0.5*(lambda*pie^2 + (1 - lambda)*y^2)',false);
mr        = assignParameters(mr,paramL);
[mr,loss] = calculateLoss(mr);

%% Get loss of all models

[loss,names,table] = getLoss([mc,md,m_osr_c,m_osr_d])

%% Compare interest rules

printDecisionRules([mc,md,m_osr_c,m_osr_d],'i','',false)

%% Add uncertainty one parameter

etaDist = nb_distribution('type','normal','parameters',{par.eta,0.1});
plot(etaDist);

mu = declareUncertainParameters(m,{'eta'},etaDist);

%% Optimal linear rule (commitment) 
% With parameter uncertainty in eta

opt         = optimset('fmincon');
opt.Display = 'iter';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_pie_lag',1.2,'gamma_y_lag',0.6,...
                     'gamma_e',0,'gamma_u',0);
mu_osr_c    = optimalSimpleRules(mu,...
'i = gamma_pie*pie + gamma_y*y + gamma_pie_lag*pie(-1) + gamma_y_lag*y(-1) + gamma_e*e_e + gamma_u*e_u',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c_u');
mu_osr_c.print()
mu_osr_c.printDecisionRules()

%% Plot irfs (commitment)

[~,~,plotter] = irf([m_osr_c,mu_osr_c]);
nb_graphInfoStructGUI(plotter)

%% Optimal linear rule (discretion)
% With parameter uncertainty in eta

opt         = optimset('fmincon');
opt.Display = 'iter';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_e',0,  'gamma_u',0);
mu_osr_d    = optimalSimpleRules(mu,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1) + gamma_e*e_e + gamma_u*e_u',...
'fix_point_dampening',1,...
'fix_point_TolFun',1.0e-6,...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d_u');
mu_osr_d.print()
mu_osr_d.printDecisionRules()

%% Compare (discretion)

printDecisionRules([md,m_osr_d,mu_osr_d],'i','',false)

%% Plot irfs (commitment)

[~,~,plotter] = irf([m_osr_d,mu_osr_d]);
nb_graphInfoStructGUI(plotter)

%% Optimal monetary policy discretion

par.rho_u   = 0.9;
par.rho_e   = 0.9;
mRho        = assignParameters(m,par);
mdRho       = solve(mRho,'lc_commitment',0,'lc_discount',1,'name','d_rho');
[mdRho,loss] = calculateLoss(mdRho);
mdRho.printDecisionRules()
loss

%% Optimal simple rule (discretion)
% This replicate the discretionary solution

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_e',1.2,'gamma_u',0.6,...
                     'gamma_e_e',0,  'gamma_e_u',0);
m_osr_dRho    = optimalSimpleRules(mRho,...
'i = gamma_e*e(-1) + gamma_u*u(-1) + gamma_e_e*e_e + gamma_e_u*e_u',...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d_rho');
m_osr_dRho.print()
m_osr_dRho.printDecisionRules()

%% Optimal linear rule (discretion)
% With parameter uncertainty in eta

etaDist     = nb_distribution('type','normal','parameters',{par.eta,0.1});
muRho       = declareUncertainParameters(mRho,{'eta'},etaDist);
opt         = optimset('fmincon');
opt.Display = 'iter';
init        = struct('gamma_e',1.2,'gamma_u',0.6,...
                     'gamma_e_e',0,  'gamma_e_u',0);
mu_osr_dRho    = optimalSimpleRules(muRho,...
'i = gamma_e*e(-1) + gamma_u*u(-1) + gamma_e_e*e_e + gamma_e_u*e_u',...
'fix_point_dampening',1,...
'fix_point_TolFun',1.0e-6,...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d_u_rho');
mu_osr_dRho.print()
mu_osr_dRho.printDecisionRules()

%% Compare (discretion)

printDecisionRules([mdRho,m_osr_dRho,mu_osr_dRho],'i','',false)

%% Plot irfs (commitment)

[~,~,plotter] = irf([mdRho,m_osr_dRho,mu_osr_dRho]);
nb_graphInfoStructGUI(plotter)

