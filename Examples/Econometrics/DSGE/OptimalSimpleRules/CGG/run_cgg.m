%% Help on this example

nb_dsge.help
help nb_dsge.setLossFunction
help nb_dsge.calculateLoss
help nb_dsge.optimalSimpleRules
help nb_dsge.getLoss

%% Parse model

m = nb_dsge('nb_file','cgg.nb','silent',false);

%% Parameterization

param        = struct();
param.alpha  = 0.1;
param.beta   = 1;
param.phi    = 0.5;
param.theta  = 0.5;
param.varphi = 0.8;
m            = assignParameters(m,param);

%% Set loss function

paramL = struct('lambda',0.5);
m      = setLossFunction(m,'0.5*(lambda*pie^2 + (1 - lambda)*y^2)');
m      = assignParameters(m,paramL);

%% Optimal monetary policy commitment

mc = solve(m,'lc_commitment',1,'lc_discount',1,'name','c');
mc = calculateLoss(mc);
mc.printDecisionRules()

%% Optimal monetary policy discretion

md = solve(m,'lc_commitment',0,'lc_discount',1,'name','d');
md = calculateLoss(md);
md.printDecisionRules()

%% Optimal simple rule (commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6);
m_osr_c     = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1)',...
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c');
m_osr_c.print()
m_osr_c.printDecisionRules()

%% Optimal simple rule, current variables(commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6);
m_osr_c2     = optimalSimpleRules(m,...
'i = gamma_pie*pie + gamma_y*y',...
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c2');
m_osr_c2.print()
m_osr_c2.printDecisionRules()

%% Optimal simple rule with one innovation (commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_eta',0);
m_osr_c3    = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1) + gamma_eta*eta',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c3');
m_osr_c3.print()
m_osr_c3.printDecisionRules()

%% Optimal simple rule with innovations (commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_eps',0,'gamma_eta',0);
m_osr_c4    = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1) + gamma_eps*eps + gamma_eta*eta',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c4');
m_osr_c4.print()
m_osr_c4.printDecisionRules()

%% Optimal simple rule with current values and innovations (commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_eps',0,'gamma_eta',0);
m_osr_c5    = optimalSimpleRules(m,...
'i = gamma_pie*pie + gamma_y*y + gamma_eps*eps + gamma_eta*eta',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c5');
m_osr_c5.print()
m_osr_c5.printDecisionRules()

%% Optimal simple rule with all (commitment)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_pie_lag',1.2,'gamma_y_lag',0.6,...
                     'gamma_eps',0,'gamma_eta',0);
m_osr_c6    = optimalSimpleRules(m,...
'i = gamma_pie*pie + gamma_y*y + gamma_pie_lag*pie(-1) + gamma_y_lag*y(-1) + gamma_eps*eps + gamma_eta*eta',... 
'osr_type',     'commitment',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_c6');
m_osr_c6.print()
m_osr_c6.printDecisionRules()

%% Optimal simple rule (discretion)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6);
m_osr_d = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1)',...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d');        
m_osr_d.print()        
m_osr_d.printDecisionRules()             

%% Optimal simple rule with innovations (discretion)

opt         = optimset('fmincon');
opt.Display = 'none';
init        = struct('gamma_pie',1.2,'gamma_y',0.6,...
                     'gamma_eps',0,  'gamma_eta',0);
m_osr_d2    = optimalSimpleRules(m,...
'i = gamma_pie*pie(-1) + gamma_y*y(-1) + gamma_eps*eps + gamma_eta*eta',...
'osr_type',     'discretion',...
'init',         init,...
'lc_discount',  1,...
'optimset',     opt,...
'name',         'osr_d2');
m_osr_d2.print()
m_osr_d2.printDecisionRules()

%% Model with rule

mr = nb_dsge('nb_file','cgg_rule.nb','silent',false,'name','taylor');

% Parameterization

param           = struct();
param.alpha     = 0.1;
param.beta      = 1;
param.gamma_eps = 0;
param.gamma_eta = 0;
param.gamma_i   = 0;
param.gamma_pie = 1.2;
param.gamma_y   = 0.338;
param.phi       = 0.5;
param.theta     = 0.5;
param.varphi    = 0.8;
mr              = assignParameters(mr,param);
mr              = solve(mr);
mr.printDecisionRules

% Set loss function
paramL    = struct('lambda',0.5);
mr        = setLossFunction(mr,'0.5*(lambda*pie^2 + (1 - lambda)*y^2)',false);
mr        = assignParameters(mr,paramL);
mr        = calculateLoss(mr);

%% Get loss of all models

[loss,names,table] = getLoss([mc,md,m_osr_c,m_osr_d,mr])

%% Compare interest rules

printDecisionRules([mc,md,m_osr_c,m_osr_d,mr],'i','',false)

