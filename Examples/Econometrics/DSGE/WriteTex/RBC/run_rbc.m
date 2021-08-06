%% Help on this example

nb_dsge.help
help nb_dsge.perfectForesight

%% Parse model

m = nb_dsge('nb_file','rbc_stoch3.nb');

%% Assign parameters

p.rho   = 0.2;
p.delta = 0.1;
p.beta  = 0.999;
p.alpha = 0.17;
m       = assignParameters(m,p);

%% Write model to PDF

m = assignTexNames(m,...
    m.parameters.name,...
    {'\rho','\delta','\beta','\alpha'});
m = assignTexNames(m,...
    {'y_gap','k_gap','i_gap','cy_gap','c_gap','a_gap','e_a'},...
    {'\widehat{y}','\widehat{k}','\widehat{i}','\widehat{cy}',...
     '\widehat{c}','\widehat{a}','\epsilon^{a}'});

writePDF(m,'rbc')
writePDF(m,'rbc_values','values')
