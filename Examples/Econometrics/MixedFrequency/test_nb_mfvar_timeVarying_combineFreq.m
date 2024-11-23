%% Get help on this example

nb_mfvar.help
help nb_mfvar.setMapping
help nb_mfvar.setFrequency

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
dataQ   = convert(dataM,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data    = [dataQM,dataM];

dataDA = 1/3*dataM + 2/3*nb_lag(dataM,1) + nb_lag(dataM,2) + 2/3*nb_lag(dataM,3) + 1/3*nb_lag(dataM,4);

plotter = nb_graph_ts(data);
plotter.set('missingValues','interpolate','variablesToPlot',...
    {'VAR1','VAR2','Q_VAR1','Q_VAR2'},'title','Monthly correlated raw data');
nb_graphPagesGUI(plotter);

%% TVP-MF-SV with a variable observed at multiple frequencies

% Prior
prior = nb_mfvar.priorTemplate('kkse');

% -------------------------- TVP and SV -----------------------------------
% Here we set l_2_endo_update and l_4_endo_update to true to update
% the forgetting factors endogenously during estimation of the model
%
% prior.l_2 and prior.l_4 are in this case the starting values of the 
% forgetting factors
%
% for more information type "help nb_var.priorTemplate"
% -------------------------------------------------------------------------

prior.l_2             = 1;
prior.l_4             = 1;
prior.l_2_endo_update = 1;
prior.l_4_endo_update = 1;

%prior.V0VarScale = 0.05; Make smoothed series closer to observed series.

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
t.constant  = true;
t.nLags     = 5;
t.prior     = prior;
t.draws     = 500;
t.recursive_estim = 0;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Solve

modelS = solve(model);

%% Forecast

modelF  = forecast(modelS,4);
plotter = plotForecast(modelF);
% set(plotter,'startGraph','2017M1')
nb_graphSubPlotGUI(plotter);

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

%% TVP-MF-SV with monthly variable of interest with short history

% Prior
prior = nb_mfvar.priorTemplate('kkse');

% VAR2 is only observed from 1994, but quarterly series has full history
VAR2 = dataM.window('01.01.1994','','VAR2');
data = [data.window('','',{'VAR1','VAR3','Q_VAR1','Q_VAR2','Q_VAR3'}),VAR2];

prior.l_2             = 1;
prior.l_4             = 1;
prior.l_2_endo_update = 1;
prior.l_4_endo_update = 1;

%prior.V0VarScale = 0.1; % Make smoothed series closer < 0.10 or farther > 0.10 from observed series.

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
t.constant  = true;
t.nLags     = 5;
t.prior     = prior;
t.draws     = 500;
t.recursive_estim = 0;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Get smoothed estimates of VAR2 for entire history

% VAR2 is unobserved before 1994M1 by the econometrician
s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
dM = dataM('VAR2');
dM = addPrefix(dM,'A_');
d  = [d,dQ,sd,dM];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'A_VAR2','EST_AUX_VAR2','Q_VAR2'},...
      'lineStyles',{'A_VAR2',{':','1994M1','-'}},...
      'title','Weakly correlated data',...
      'legends',{'','Monthly Predicted','Actual Quarterly','','Actual Monthly (unobserved)','Actual Monthly (observed)'},...
      'fakeLegend',{'Actual Monthly (unobserved)',{'cData','deep blue','linestyle',':'},'Actual Monthly (observed)',{'cData','deep blue','lineStyle','-'}});
             
nb_graphPagesGUI(p);

% Compare moments before/after observations begin
nb_cs([std(window(s,'','1993M12','VAR2'),0,'double');std(window(s,'1994M1','','VAR2'),0,'double')],'',...
    {'Unobserved','Observed'},{'VAR2'})

%% Generate correlated data

rng(1); % Set seed

obs     = 100;
lambda  = 0.8;
rho     = 1;  
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1'},1,lambda,rho);
dataEPS = nb_ts(randn(obs,1),'','1990M1',{'EPS'});
dataM   = [dataM,dataEPS];
dataM   = createVariable(dataM,'VAR2','VAR1 + EPS');
dataM   = deleteVariables(dataM,{'EPS'});
dataQ   = convert(dataM,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data    = [dataQM,dataM];

plotter = nb_graph_ts(data);
plotter.set('missingValues','interpolate');
nb_graphPagesGUI(plotter);

%% TVP-MF-SV with monthly variable of interest with short history
% Now, VAR1 is more informative about VAR2

% Prior
prior = nb_mfvar.priorTemplate('kkse');

% VAR2 is only observed from 1992, but quarterly series has full history
VAR2 = dataM.window('01.01.1994','','VAR2');
data = [data.window('','',{'VAR1','Q_VAR1','Q_VAR2'}),VAR2];

prior.l_2             = 1;
prior.l_4             = 1;
prior.l_2_endo_update = 1;
prior.l_4_endo_update = 1;

%prior.V0VarScale = 0.001; % Make smoothed series closer < 0.10 or farther > 0.10 from observed series.

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
t.constant  = true;
t.nLags     = 5;
t.prior     = prior;
t.draws     = 500;
t.recursive_estim = 0;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Get smoothed estimates of VAR2 for entire history
% VAR2 is unobserved before 1994M1 by the econometrician
s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
dM = dataM('VAR2');
dM = addPrefix(dM,'A_');
d  = [d,dQ,sd,dM];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'A_VAR2','EST_AUX_VAR2','Q_VAR2'},...
      'lineStyles',{'A_VAR2',{':','1994M1','-'}},...
      'title','Strongly correlated data',...
      'legends',{'','Monthly Predicted','Actual Quarterly','','Actual Monthly (unobserved)','Actual Monthly (observed)'},...
      'fakeLegend',{'Actual Monthly (unobserved)',{'cData','deep blue','linestyle',':'},'Actual Monthly (observed)',{'cData','deep blue','lineStyle','-'}});
             
nb_graphPagesGUI(p);

% Compare moments before/after observations begin
nb_cs([std(window(s,'','1993M12','VAR2'),0,'double');std(window(s,'1994M1','','VAR2'),0,'double')],'',...
    {'Unobserved','Observed'},{'VAR2'})

%% Generate correlated data with more dependent variables

rng(1); % Set seed

obs     = 100;
lambda  = 0.8;
rho     = 1;  
dataM   = nb_ts.simulate('1990M1',obs,{'VAR1'},1,lambda,rho);
dataEPS = nb_ts(randn(obs,1),'','1990M1',{'EPS'});
dataM   = [dataM,dataEPS];
dataM   = createVariable(dataM,'VAR2','VAR1 + EPS');
dataM   = deleteVariables(dataM,{'EPS'});

nVar = 2;
for ii = 1:nVar
   dataEPS = nb_ts(randn(obs,1),'','1990M1',{'EPS'});
   dataM   = [dataM,dataEPS]; %#ok<AGROW>
   dataM   = createVariable(dataM,['VAR' num2str(2 + ii)],'VAR2 + EPS');
   dataM   = deleteVariables(dataM,{'EPS'});
end

dataQ   = convert(dataM,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data    = [dataQM,dataM];

plotter = nb_graph_ts(data);
plotter.set('missingValues','interpolate');
nb_graphPagesGUI(plotter);

%% TVP-MF-SV with monthly variable of interest with short history
% Now, we have more variables that are informative about VAR2

% Prior
prior = nb_mfvar.priorTemplate('kkse');

% VAR2 is only observed from 1992, but quarterly series has full history
VAR2 = dataM.window('01.01.1994','','VAR2');
data = [data.window('','',{'VAR1','VAR2','VAR3','VAR4','Q_VAR1','Q_VAR2','Q_VAR3','Q_VAR4'}),VAR2];

prior.l_2             = 1;
prior.l_4             = 1;
prior.l_2_endo_update = 1;
prior.l_4_endo_update = 1;

prior.V0VarScale = 0.01; % Make smoothed series closer < 0.10 or farther > 0.10 from observed series.

% Options
t           = nb_mfvar.template();
t.data      = data;
t.dependent = {'VAR1','VAR2','VAR3','VAR4','Q_VAR2'};
t.frequency = {'Q_VAR2',4};
t.mapping   = {'Q_VAR2','diffAverage'};
t.mixing    = {'Q_VAR2','VAR2'}; % First low, then high
t.constant  = true;
t.nLags     = 5;
t.prior     = prior;
t.draws     = 500;
t.recursive_estim = 0;

% Create model and estimate
model = nb_mfvar(t);
model = estimate(model);
print(model)

%% Get smoothed estimates of VAR2 for entire history
% VAR2 is unobserved before 1994M1 by the econometrician
s  = getFiltered(model);
sd = s('Q_VAR2','AUX_VAR2');
sd = addPrefix(sd,'EST_');
d  = data('VAR2');
dQ = dataDA('VAR2');
dQ = addPrefix(dQ,'Q_');
dM = dataM('VAR2');
dM = addPrefix(dM,'A_');
d  = [d,dQ,sd,dM];
p  = nb_graph_ts(d);
p.set('variablesToPlot',{'A_VAR2','EST_AUX_VAR2','Q_VAR2'},...
      'lineStyles',{'A_VAR2',{':','1994M1','-'}},...
      'title','(Many) strongly correlated data',...
      'legends',{'','Monthly Predicted','Actual Quarterly','','Actual Monthly (unobserved)','Actual Monthly (observed)'},...
      'fakeLegend',{'Actual Monthly (unobserved)',{'cData','deep blue','linestyle',':'},'Actual Monthly (observed)',{'cData','deep blue','lineStyle','-'}});
             
nb_graphPagesGUI(p);

% Compare moments before/after observations begin
nb_cs([std(window(s,'','1993M12','VAR2'),0,'double');std(window(s,'1994M1','','VAR2'),0,'double')],'',...
    {'Unobserved','Observed'},{'VAR2'})
