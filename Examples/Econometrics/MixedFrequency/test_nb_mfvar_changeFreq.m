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

% Partly quarterly and partly monthly
freqChange = nb_week(52,1997);
dataQS     = window(dataQWT,'',freqChange);
dataMS     = window(dataMWT,freqChange + 1);
dataQMW    = [dataQS;dataMS];
dataQMW    = addPrefix(dataQMW,'QM_');
data      = [dataQMW,dataQW,dataMW,dataW];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','M_VAR2','QM_VAR3'};
t.frequency = {'M_VAR2',12,'QM_VAR3',{4,freqChange,12}};
t.mapping   = {'M_VAR2','diffAverage','QM_VAR3','diffAverage'};
t.constant  = true;
t.nLags     = 2;
t.prior     = prior;
t.draws     = 500;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)
% Here AUX_ is added to the variable in the VAR model, so AUX_M_VAR2
% is the monthly estimate of M_VAR2 series.

s  = getFiltered(model);
sd = s('AUX_M_VAR2');
d  = data('VAR2');
d  = merge(d,sd);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'monthly_freqChanged','pdf','-noflip');

sd = s('AUX_QM_VAR3');
d  = data('VAR3');
d  = merge(d,sd);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);
% nb_saveas(gcf,'quarterly_freqChanged','pdf','-noflip');

