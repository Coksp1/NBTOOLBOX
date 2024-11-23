%% Help on this example
% You need the optimization toolbox to run this example as it uses
% the linprog function

nb_singleEq.help
help nb_qreg

%% Generate artificial data

rng(1) % Set seed

draws = randn(100,1)*4;
sim1  = filter(1,[1,-0.5],draws); % ARIMA(1,0,0)

% Transform to nb_ts object
data    = nb_ts(sim1,'','2000Q1',{'VAR1'});
datalag = nb_lag(data);
datalag = addPostfix(datalag,'_lag1');
data    = [data,datalag]; % Append lagged series to data object

%% Dynamic nb_singleEq (quantile) 

q   = [0.05,0.15,0.25,0.35,0.5,0.65,0.75,0.85,0.95];
dep = {'VAR1'};
exo = {'VAR1_lag1'};
seq = nb_singleEq(...
    'constant',         true,...
    'data',             data,...
    'dependent',        dep,...
    'estim_method',     'quantile',...
    'exogenous',        exo,...
    'quantile',         q,...  
    'stdType',          'sparsity');

seq = estimate(seq);
print_estimation_results(seq)
seq = solve(seq);

%% Median forecast (dynamic)

seq     = forecast(seq,4,'output','all');            
plotter = plotForecast(seq);
nb_graphSubPlotGUI(plotter);

%% Quantile forecast (dynamic)
% To trigger the forecast of the quantiles you need to set the 'draws'
% option to a number greater than 1!

perc    = setdiff(nb_interpretPerc(q*100,true),0);
seq     = forecast(seq,4,'output','all','draws',2);            
plotter = plotForecast(seq);
plotter.set('fanPercentiles',perc,...
            'startGraph','2000Q1');
nb_graphSubPlotGUI(plotter);           
