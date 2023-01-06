%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency

%% Generate artificial data (monthly)

rng(1); % Set seed

obs     = 200;
lambda  = [0.5, 0.1, 0.2, -0.1;
           0.5,-0.1,   0,  0.1];
rho     = [1;1]; 

% Simulate monthly data
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2'},1,lambda,rho);

% Convert to quarterly, before it converted back to monthly with missing
% observations
dataQ   = convert(dataM,4,'diffAverage');
dataQMT = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQMT,'Q_');
data    = [dataM,dataQM];


dataDA = 1/3*dataM + 2/3*lag(dataM,1) + lag(dataM,2) + 2/3*lag(dataM,3) + 1/3*lag(dataM,4);

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);

%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 
% Monthly and quarterly

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
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

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_Q_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_Q_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
nb_graphPagesGUI(p);

%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 
% Monthly and quarterly

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';
prior.mixing  = 'high';

% Set how important it is to match the high frequency observations
% on the variable 'VAR2'. Higher number means less measurement errors 
% allow. The prior is set as sigma/R_scale, where sigma is the
% variance of 'VAR2'.
prior.R_scale = 100; 

% Options
t           = nb_mfvar.template();
t.data      = dataEst;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
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

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
nb_graphPagesGUI(p);

%% Test MF-VAR (Normal-Wishart)
% Monthly and quarterly

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Prior
prior       = nb_mfvar.priorTemplate('nwishartMF');

% Options
t           = nb_mfvar.template();
t.data      = dataEst;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
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

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
nb_graphPagesGUI(p);

%% Test MF-VAR (Independent Normal-Wishart)
% Monthly and quarterly

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Prior
prior       = nb_mfvar.priorTemplate('inwishartMF');

% Options
t           = nb_mfvar.template();
t.data      = dataEst;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
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

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
nb_graphPagesGUI(p);

%% Test MF-VAR (Maximum likelihood) 
% Monthly and quarterly

% dataEst = data;
dataEst = setToNaN(data,'','2001M12',{'VAR2'});

% Options
t              = nb_mfvar.template();
t.data         = dataEst;
t.dependent    = {'VAR1','VAR2','Q_VAR2'};
t.estim_method = 'ml';
t.frequency    = {'Q_VAR2',4};
t.mapping      = {'Q_VAR2','diffAverage'};
t.mixing       = {'Q_VAR2','VAR2'}; % First low, then high
t.constant     = true;
t.nLags        = 2;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)
printCov(model)

%% Get smoothed estimates of missing values (Mean of the posterior draws)

s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
d  = [d,dQ,sd];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'VAR2','EST_AUX_VAR2','Q_VAR2','EST_Q_VAR2'},...
      'legends',{'Monthly Actual','Monthly Predicted','Actual Quarterly',...
                 'Predicted Quarterly'});
nb_graphPagesGUI(p);

%% Generate artificial data (Weekly)

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
data    = [dataW,dataMW,dataQW];

% plotter = nb_graph_ts(data);
% plotter.set('missingValues','interpolate');
% nb_graphPagesGUI(plotter);


%% Test MF-VAR (Minnesota; Independent Normal-Wishart type) 
% Weekly, monthly and quarterly

% Prior
prior         = nb_mfvar.priorTemplate('minnesotaMF');
prior.method  = 'inwishart';

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','M_VAR2','M_VAR3','Q_VAR3'};
t.frequency = {'M_VAR2',12,'M_VAR3',12,'Q_VAR3',4};
t.mapping   = {'M_VAR2','diffAverage','M_VAR3','diffAverage','Q_VAR3','diffAverage'};
t.mixing    = {'Q_VAR3','M_VAR3'}; % First low, then high
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

s  = getFiltered(model);
sd = s('AUX_M_VAR2');
d  = data('VAR2');
d  = merge(d,sd);
p  = nb_graph_ts(d);
p.set('legends',{'Predicted','Actual'},'startGraph','1995W1');
nb_graphPagesGUI(p);

sd = s('AUX_M_VAR3','Q_VAR3','M_VAR3');
sd = addPrefix(sd,'EST_');
d  = data('VAR3','M_VAR3','Q_VAR3');
d  = merge(d,sd);
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'EST_AUX_M_VAR3','EST_M_VAR3','EST_Q_VAR3','VAR3','M_VAR3','Q_VAR3'},...
      'legends',{'Predicted (Week)','Predicted (Month)','Predicted (Quarter)','Actual','Actual (Month)','Actual (Quarter)'},...
      'startGraph','1995W1','lineStyles',{'Q_VAR3','none','M_VAR3','none'},...
      'markers',{'Q_VAR3','d','M_VAR3','o'},'markerSize',3);
nb_graphPagesGUI(p);
