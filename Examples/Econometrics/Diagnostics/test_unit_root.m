%% Generate artificial data 

rng(1); % Set seed

draws  = randn(100,1);
simNUR = filter(1,[1,-0.5],draws); % No unit root
simUR  = filter(1,[1,-1],draws);   % Unit root
sim    = [simNUR,simUR];
data   = nb_ts(sim,'','2012Q1',{'NUR','UR'});

%% Test ADF 

[results,est] = nb_adf(data('UR'),'nLags',2)
nb_olsEstimator.print(est.results,est.options)

%% Test ADF (auto)

[results,est] = nb_adf(data('UR'),'lagLengthCrit','aic')
nb_olsEstimator.print(est.results,est.options)

%% Test P-P

[results,est] = nb_phillipsPerron(data('UR'),'bandWidth',3)
nb_olsEstimator.print(est.results,est.options)


%% Test P-P (auto)

[results,est] = nb_phillipsPerron(data('UR'),'bandWidthCrit','nw')
nb_olsEstimator.print(est.results,est.options)

%% Unit root class (adf)

test = nb_unitRootTest(data,'adf');
print(test)

%% Unit root class (pp)

test = nb_unitRootTest(data,'pp');
print(test)
