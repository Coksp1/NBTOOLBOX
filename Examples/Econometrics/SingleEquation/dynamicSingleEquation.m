%% Help on this example

nb_singleEq.help

%% Generate artificial data

rng(1) % Set seed

draws = randn(100,1)*4;
sim1  = filter(1,[1,-0.5],draws); % ARIMA(1,0,0)
sim2  = [0.3;nan(100-1,1)];
for tt = 2:100
    sim2(tt) = 0.6*sim2(tt-1) + sim1(tt) + randn;
end

% Transform to nb_ts object
data     = nb_ts([sim1,sim2],'','2000Q1',{'VAREXO','VAR'});
datalag  = nb_lag(data);
datalag  = addPostfix(datalag,'_lag1');
data     = [data,datalag]; % Append lagged series to data object

%% Dynamic nb_singleEq (ols) 

% In this case we need to add lag 3 as well
datalag3 = nb_lag(data,3);
datalag3 = addPostfix(datalag3,'_lag3');
dataT    = [data,datalag3];

dep  = {'VAR'};
exo  = {'VAR_lag1','VAR_lag3','VAREXO'};%
seq  = nb_singleEq(...
    'data',             dataT,...
    'dependent',        dep,...
    'exogenous',        exo,...
    'estim_end_date',   dataT.endDate - 11);

seq = estimate(seq);
print_estimation_results(seq)
seq = solve(seq);

%% Dynamic nb_singleEq (ols)
% Or using the 'nLags' option

dep  = {'VAR'};
exo  = {'VAR_lag1','VAREXO'};
seq  = nb_singleEq(...
    'data',             data,...
    'dependent',        dep,...
    'exogenous',        exo,...
    'estim_end_date',   data.endDate - 11,...
    'nLags',            {[0,2],0});
% Here we have that 0 means 'VAR_lag1' and 2 means 'VAR_lag(1+2)'

seq = estimate(seq);
print_estimation_results(seq)
seq = solve(seq);

%% Unconditional forecast will not work as we have an exogenous variable
% which is not a predetermind endogenous variable
seq = forecast(seq,8);

%% Forecast (dynamic)

dataC  = data.window(data.endDate - 10);
condDB = nb_model_generic.constructCondDB(dataC,{'VAREXO'});
seq    = forecast(seq,condDB.numberOfObservations,'condDB',condDB,...
                    'output','all');
plotter = plotForecast(seq);
nb_graphSubPlotGUI(plotter);                

%% Forecast (Endogenous conditional information) (dynamic)

dataC       = data.window(data.endDate - 10);
[condDB,SP] = nb_model_generic.constructCondDB(dataC,...
                {'VAREXO'},{'VAR'},4,{},...
                {'E_VAR'},4);
seq         = forecast(seq,condDB.numberOfObservations,'condDB',condDB,...
                    'output','all','shockProps',SP);
                
plotter = plotForecast(seq);
nb_graphSubPlotGUI(plotter);  
