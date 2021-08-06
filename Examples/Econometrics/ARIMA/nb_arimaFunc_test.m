%% Simulate some ARIMA processes

rng(1) % Set seed

draws = randn(100,1);
sim1  = filter(1,[1,-0.5],draws);           % ARIMA(1,0,0)
sim2  = filter([1,0.5],1,draws);            % ARIMA(0,0,1)
sim3  = filter([1,0.5],[1,-0.2],draws);     % ARIMA(1,0,1)
sim4  = filter([1,0.5,0.2],[1,-0.2],draws); % ARIMA(1,0,2)

%% Hannan-Rissanen

results1 = nb_arimaFunc(sim1,1,0,0)
results2 = nb_arimaFunc(sim2,0,0,1)
results3 = nb_arimaFunc(sim3,1,0,1) 

%% Maximum likelihood
% Here nan mean that the number is to be estimated

results1ml  = nb_arimaFunc(sim1,  1,  0,  0,0,0,'method','ml','constant',0)
results1mlu = nb_arimaFunc(sim1,nan,  0,nan,0,0,'method','ml','constant',0)
results2ml  = nb_arimaFunc(sim2,  0,  0,  1,0,0,'method','ml','constant',0)
results3ml  = nb_arimaFunc(sim2,  1,nan,  2,0,0,'method','ml','constant',0)
results4ml  = nb_arimaFunc(sim3,  1,  0,  1,0,0,'method','ml',...
              	'filter',true,'constant',0)
