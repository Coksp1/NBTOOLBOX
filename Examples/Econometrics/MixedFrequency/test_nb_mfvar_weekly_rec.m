%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency

%% Generate artificial data

rng(1); % Set seed

obs     = 500;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1]; 

% Simulate weekly data
dataW   = nb_ts.simulate('1990W1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

% Convert to monthly, before it converted back to weekly with missing
% observations
dataM   = convert(dataW,12,'diffAverage');
dataMWT = convert(dataM,52,'','interpolateDate','end');
dataMW  = addPrefix(dataMWT,'M_');

% Convert to quarterly, before it converted back to weekly with missing
% observations
dataQ   = convert(dataW,4,'diffAverage');
dataQWT = convert(dataQ,52,'','interpolateDate','end');
dataQW  = addPrefix(dataQWT,'Q_');
data    = [dataQW,dataMW,dataW];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Normal-Wishart)

parallel = true;
if parallel
    nb_openPool(4);
end

% Prior
% prior = nb_mfvar.priorTemplate('minnesotaMF'); 
% prior = nb_mfvar.priorTemplate('nwishartMF'); 
prior = nb_mfvar.priorTemplate('inwishartMF'); 

% Options
t                            = nb_mfvar.template();
t.data                       = data;
t.dependent                  = {'VAR1','M_VAR2'};
t.frequency                  = {'M_VAR2',12};
t.mapping                    = {'M_VAR2','diffAverage'};
t.constant                   = true;
t.nLags                      = 2;
t.prior                      = prior;
t.draws                      = 500;
t.recursive_estim            = true;
t.recursive_estim_start_date = data.endDate - 7;
t.parallel                   = parallel;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_M_VAR2
% is the weekly estimate of M_VAR2 series.

s  = getFiltered(model);
sd = s('AUX_M_VAR2');
d  = data('VAR2');
d  = merge(sd,d);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'monthly','pdf','-noflip');

sd = s('AUX_Q_VAR3');
d  = data('VAR3');
d  = merge(sd,d);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'quarterly','pdf','-noflip');

%% Solve 

modelS = solve(model);

%% Forecast

modelF = forecast(modelS,26 ...
,'fcstEval','SE'...
...,'varOfInterest',{'M_VAR2'}...
);

%% Plot forecast of the highest frequency 
% (latest forecast only)

p = plotForecast(modelF);
p.set('startGraph','1999W1','spacing',15);
nb_graphSubPlotGUI(p);

%% Plot forecast of the highest frequency 
% (latest forecast only)

p = plotForecast(modelF,'hairyplot');
p.set('startGraph','1999W1','spacing',15);
nb_graphSubPlotGUI(p);

%% Evaluate high frequency
% Note: The evaluation of the series M_VAR2 is here compared to the
% smoothed estimate, and is therefore of no value other than for a pure
% economtric interest. 

scores = getScore(modelF,'RMSE',false);
scores.Model1

%% Get forecast on the lower frequencies
% Monthly

% The end forecast, without history
[fcstData,fcstDates] = getForecastLowFreq(modelF,12)

% The end forecast, with history
[fcstData,fcstDates] = getForecastLowFreq(modelF,12,'',true)

% The recursive forecast, without history
fcstDataRec = getForecastLowFreq(modelF,12,'recursive')

%% Plot low frequency forecast

p = plotForecastLowFreq(modelF,12);
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

%% Plot low frequency forecast
% Hairy-plot

% Balanced
p = plotForecastLowFreq(modelF,12,'hairyplot');
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

% One week more
p = plotForecastLowFreq(modelF,12,'hairyplot','',1);
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

% Two week more
p = plotForecastLowFreq(modelF,12,'hairyplot','',2);
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

% Three week more
p = plotForecastLowFreq(modelF,12,'hairyplot','',3);
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

% Four week more
p = plotForecastLowFreq(modelF,12,'hairyplot','',4);
p.set('startGraph','1996M1');
nb_graphSubPlotGUI(p);

%% Evaluate low frequency forecast

% Evaluate forecast balanced 
scores = getScoreLowFreq(modelF,'RMSE',12);
scores.Model1

% Evaluate forecast with one extra weeks
scores = getScoreLowFreq(modelF,'RMSE',12,1);
scores.Model1

% Evaluate forecast with two extra weeks
scores = getScoreLowFreq(modelF,'RMSE',12,2);
scores.Model1

% Evaluate forecast with no extra weeks
scores = getScoreLowFreq(modelF,'RMSE',12,3);
scores.Model1

%% Test MF-VAR (Maximum likelihood)

parallel = true;
if parallel
    nb_openPool(4);
end

% Options
t                            = nb_mfvar.template();
t.data                       = data;
t.dependent                  = {'VAR1','M_VAR2'};
t.estim_method               = 'ml';
t.frequency                  = {'M_VAR2',12};
t.mapping                    = {'M_VAR2','diffAverage'};
t.constant                   = true;
t.nLags                      = 2;
t.recursive_estim            = true;
t.recursive_estim_start_date = data.endDate - 7;
t.parallel                   = parallel;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_M_VAR2
% is the weekly estimate of M_VAR2 series.

s  = getFiltered(model);
sd = s('AUX_M_VAR2');
d  = data('VAR2');
d  = merge(sd,d);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'monthly','pdf','-noflip');

sd = s('AUX_Q_VAR3');
d  = data('VAR3');
d  = merge(sd,d);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'quarterly','pdf','-noflip');
