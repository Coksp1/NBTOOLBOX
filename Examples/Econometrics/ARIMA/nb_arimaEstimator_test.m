%% Simulate some ARIMA processes

draws = randn(100,1);
sim1  = filter(1,[1,-0.5],draws);           % ARIMA(1,0,0)
sim2  = filter([1,0.5],1,draws);            % ARIMA(0,0,1)
sim3  = filter([1,0.5],[1,-0.2],draws);     % ARIMA(1,0,1)
sim4  = filter([1,0.5,0.2],[1,-0.2],draws); % ARIMA(1,0,2)

% Transform to nb_ts object
data   = nb_ts([sim1,sim2,sim3,sim4],'','2000Q1',...
                {'Sim1','Sim2','Sim3','Sim4'});
            
% Construct variable that are I(1) and merge with rest            
dataUR = undiff(data('Sim1'),100,1);
dataUR = rename(dataUR,'variables','Sim1','Sim5');
data   = merge(data,dataUR);

%% Estimation (Unspecified, Hannan-Rissanen)

options               = nb_arimaEstimator.template();
options.constant      = 0;
options.data          = data.data;
options.dataVariables = data.variables;
options.dataStartDate = toString(data.startDate);
options.dependent     = {'Sim1'};
[results,outOpt]      = nb_arimaEstimator.estimate(options);
nb_arimaEstimator.print(results,outOpt)

%% Estimation (Unspecified, Maximum likelihood)

options               = nb_arimaEstimator.template();
options.algorithm     = 'ml';
options.constant      = 0;
options.data          = data.data;
options.dataVariables = data.variables;
options.dataStartDate = toString(data.startDate);
options.dependent     = {'Sim1'};
[results,outOpt]      = nb_arimaEstimator.estimate(options);
nb_arimaEstimator.print(results,outOpt)

