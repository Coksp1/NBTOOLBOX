%% Help on this example

nb_dsge.help
help nb_dsge.setLossFunction
help nb_dsge.irf
help nb_dsge.estimate
help nb_dsge.getIRFMatchingFunc

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
par.rho_u   = 0.7;
par.rho_e   = 0.7;
m           = assignParameters(m,par);

%% Set loss function

paramL = struct('lambda',0.1);
m      = setLossFunction(m,'0.5*(pie^2 + lambda*y^2)');
m      = assignParameters(m,paramL);

%% Optimal monetary policy discretion

md        = solve(m,'lc_commitment',0,'lc_discount',1,'name','d');
[md,loss] = calculateLoss(md);
md.printDecisionRules()

%% Plot irfs (commitment)

[irfs,~,plotter] = irf(md,'variables',md.dependent.name(~md.dependent.isAuxiliary));
nb_graphInfoStructGUI(plotter);

%% Model with rule

mr = nb_dsge('nb_file','nk_rule_ext.nb','silent',false,'name','taylor');

% Parameterization
par           = struct();
par.beta        = 0.99;
par.eta        = 1;
par.alpha      = 0.33;
par.epsilon    = 6;
par.theta      = 0.67;
par.varphi     = 1;
par.rho_u      = 0.7;
par.rho_e      = 0.7;
par.gamma_pie  = 1.2;
par.gamma_pie1 = 0;
par.gamma_y    = 0.338;
mr             = assignParameters(mr,par);
mr             = solve(mr);
mr.printDecisionRules

%% Find the taylor rule that is closed to the optimal monetary policy
% under discretion

% Search area (Must be uniform!)
priors            = struct();
priors.gamma_pie  = {1.2,  1, 5};
priors.gamma_pie1 = {0,    0, 5};
priors.gamma_y    = {0.338,0, 3};
mr                = set(mr,'prior',priors);

% Get function handle to return the problem during estimation
getObjectiveFunc = getIRFMatchingFunc(mr,irfs,[],@(x)norm(x));
mrOpt            = set(mr,'getObjectiveFunc',getObjectiveFunc,...
                          'name','opt_taylor');

% Estimate
mrOpt = estimate(mrOpt);
print(mrOpt)

% Solve and print decision rules
mrOpt = solve(mrOpt);
printDecisionRules([md,mrOpt],'i')

%% IRFs

[~,~,plotter] = irf([md,mr,mrOpt],'variables',md.dependent.name(~md.dependent.isAuxiliary));
nb_graphInfoStructGUI(plotter);

%% Set loss function

paramL      = struct('lambda',0.1);
mrOpt       = setLossFunction(mrOpt,'0.5*(pie^2 + lambda*y^2)',false);
mrOpt       = assignParameters(mrOpt,paramL);
[~,lossOpt] = calculateLoss(mrOpt);
[~,lossD]   = calculateLoss(md);
