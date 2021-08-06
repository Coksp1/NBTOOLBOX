%% Help on this example

nb_dsge.help
help nb_dsge.simulate

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

%% Simulate

y = simulate(mr,40,'draws',1);
y = y.taylor;

%% Simulate on some conditional information

data      = nan(40,2);
data(1,1) = 0.5;
data(2,1) = 0.5;
condDB    = nb_ts(data,'','1',{'i','e'});

shockProps = struct('Name','e','Horizon',1,'Periods',40);

yc = simulate(mr,40,'draws',1,'condDB',condDB,'shockProps',shockProps);
yc = yc.taylor;
