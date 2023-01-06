%% Transformations

newVariables = {'QSA_DPQ_YMN','QSA_DPQ_PCPIJAE','QSA_DPQ_CP',...
                'QSA_DPQ_PCPIJAEIMP'};
expressions  = {'pcn(QSA_YMN)','pcn(QSA_PCPIJAE)','pcn(QSA_CP)',...
                'pcn(QSA_PCPIJAEIMP)'};
VARvars      = {'QSA_DPQ_YMN','QSA_DPQ_PCPIJAE','QSA_URR',...
                'QSA_DPQ_CP','QSA_DPQ_PCPIJAEIMP'};

%% Generate artificial data

data = nb_ts('VARdata.xlsx');

% Transform and add variables
data = data.createVariable(newVariables,expressions);

% Cut sample (remove missing values)
data = cutSample(data);

% Demean data
data = data - mean(data);

%% Get help on the nb_var class

nb_var.help
help nb_var.forecast

%% Estimate VAR (OLS)
% With two exogenous variables

% Options
tExo                = nb_var.template();
tExo.data           = data;
tExo.dependent      = VARvars(1:3);
tExo.exogenous      = VARvars(4:5);
tExo.estim_end_date = nb_quarter('2016Q1');
tExo.constant       = true;
tExo.nLags          = 3;

% Create model and estimate
modelExo = nb_var(tExo);
modelExo = estimate(modelExo);

% Solve model
modelExo = set_identification(modelExo,'cholesky','ordering',tExo.dependent);
modelExo = solve(modelExo);

%% Estimate VAR (OLS)
% No exogenous variables

% Options
t                = nb_var.template();
t.data           = data;
t.dependent      = VARvars(1:3);
t.estim_end_date = nb_quarter('2016Q1');
t.constant       = true;
t.nLags          = 3;

% Create model and estimate
model = nb_var(t);
model = estimate(model);

% Solve model
model   = set_identification(model,'cholesky','ordering',t.dependent);
model   = solve(model);

%% Set how to intepret the conditional information

condDBType = 'hard';
% condDBType = 'soft';
% varOfInterest = t.dependent;
varOfInterest = {};
output = 'all';
% output =  'endo';

%% Conditional point forecast (exogenous)

% Solve model and do cond forecast on exogenous variables (point)
condExoDB = data.window(tExo.estim_end_date+1,'',tExo.exogenous);
modelF    = forecast(modelExo,8,'startDate',tExo.estim_end_date+1,...
   'condDB',condExoDB,'condDBType',condDBType,'output',output,...
   'varOfInterest',varOfInterest);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional point forecast (exogenous)
% Extrapolate exogenous with AR model where missing!

% Solve model and do cond forecast on exogenous variables (point)
condExoDB          = data.window(tExo.estim_end_date+1,'',tExo.exogenous);
condExoDB(4:end,1) = nan;
condExoDB(6:end,2) = nan;
modelF             = forecast(modelExo,8,'startDate',tExo.estim_end_date+1,...
   'condDB',condExoDB,'condDBType',condDBType,'output',output,...
   'exoProj','ar','varOfInterest',varOfInterest);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional point forecast (endogenous)

% Solve model and do cond forecast on endogenous and exogenous variables 
condDBE = data.window(t.estim_end_date+1,t.estim_end_date+2,t.dependent);
condDBE = condDBE.setValue('QSA_DPQ_YMN',nan,t.estim_end_date+2,t.estim_end_date+2);
SP      = struct('Name',model.solution.res,...
                 'Periods',{1,2,2});
modelF  = forecast(model,8,'startDate',t.estim_end_date+1,...
   'condDB',condDBE,'output','all','shockProps',SP,'condDBType',condDBType,...
   'output',output,'varOfInterest',varOfInterest);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional point forecast (endogenous)
% Using Kalman filter

% Solve model and do cond forecast on endogenous and exogenous variables 
condDBE = data.window(t.estim_end_date+1,t.estim_end_date+2,t.dependent);
condDBE = condDBE.setValue('QSA_DPQ_YMN',nan,t.estim_end_date+2,t.estim_end_date+2);
modelF  = forecast(model,8,'startDate',t.estim_end_date+1,...
    'condDB',condDBE,'output','all','kalmanFilter',true,'condDBType',condDBType,...
   'output',output,'varOfInterest',varOfInterest);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Density forecast

modelF  = forecast(model,2,...
    'startDate',        t.estim_end_date+1,...
    'output',           'all',...
    'draws',            1000,...
    'parameterDraws',   1,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (endogenous + normal)
% If condDBType == 'hard' we assume a no uncertainty 
% If condDBType == 'soft' we assume a normal density for the uncertainty

% Solve model and do cond forecast on endogenous and exogenous variables 
condDBE = data.window(t.estim_end_date+1,t.estim_end_date+2,t.dependent);
condDBE = condDBE.setValue('QSA_DPQ_YMN',nan,t.estim_end_date+2,t.estim_end_date+2);
SP      = struct('Name',model.solution.res,...
                 'Periods',{1,2,2});
modelF  = forecast(model,2,...
    'startDate',        t.estim_end_date+1,...
    'condDB',           condDBE,...
    'condDBType',       condDBType,...
    'output',           'all',...
    'shockProps',       SP,...
    'draws',            1000,...
    'parameterDraws',   10,...
    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (endogenous + normal)
% Using Kalman filter
% If condDBType == 'hard' we assume a no uncertainty 
% If condDBType == 'soft' we assume a normal density for the uncertainty

% Solve model and do cond forecast on endogenous and exogenous variables 
condDBE = data.window(t.estim_end_date+1,t.estim_end_date+2,t.dependent);
condDBE = condDBE.setValue('QSA_DPQ_YMN',nan,t.estim_end_date+2,t.estim_end_date+2);
SP      = struct('Name',model.solution.res,...
                 'Periods',{1,2,2});
modelF  = forecast(model,2,...
    'startDate',        t.estim_end_date+1,...
    'condDB',           condDBE,...
    'condDBType',       condDBType,...
    'output',           'all',...
    'shockProps',       SP,...
    'draws',            1000,...
    'parameterDraws',   1,...
    'perc',             [0.3,0.5,0.7,0.9],...
    'kalmanFilter',     true);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (endogenous + manual distribution)

% Calculate covariance matrix of endogenous variables
nSteps = 4;
sigma  = empiricalMoments(model,...
    'output',   'double',...
    'stacked',  true,...
    'nLags',    nSteps-1);

% Solve model and do cond forecast on endogenous marginals 
clear condDBE
condDBMean   = data.window(t.estim_end_date+1,t.estim_end_date+4,t.dependent);
condDBMean   = reorder(condDBMean,t.dependent);
condDBMean   = condDBMean.data;
condDBE(4,3) = nb_distribution;
perc         = [0.1,0.3,0.5,0.7,0.9]*100;
values       = [-1.8,-0.75,0,0.7,1.1];
for ii = 1:length(t.dependent)
    for jj = 1:nSteps
        if ii == 2
            valuesT = values./2 + condDBMean(jj,ii);
        else
            valuesT = values + condDBMean(jj,ii);
        end
        condDBE(jj,ii) = nb_distribution.perc2DistCDF(perc,valuesT,-3.5,2.5);
    end
end

SP      = struct('Name',model.solution.res,...
                 'Periods',{4,4,4});
modelF  = forecast(model,nSteps,...
            'startDate',        t.estim_end_date+1,...
            'condDB',           condDBE,...
            'condDBVars',       t.dependent,...
            'sigma',            sigma,...
            'output',           'all',...
            'shockProps',       SP,...
            'draws',            1000,...
            'parameterDraws',   10,...
            'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (endogenous + manual distribution)
% Using constant distribution to assume no uncertainty in conditional
% information

% Calculate covariance matrix of endogenous variables
nSteps = 4;
sigma  = empiricalMoments(model,...
    'output',   'double',...
    'stacked',  true,...
    'nLags',    nSteps-1);

% Solve model and do cond forecast on endogenous marginals 
clear condDBE
condDBMean   = data.window(t.estim_end_date+1,t.estim_end_date+4,t.dependent);
condDBMean   = reorder(condDBMean,t.dependent);
condDBMean   = condDBMean.data;
condDBE(4,3) = nb_distribution;
perc         = [0.1,0.3,0.5,0.7,0.9]*100;
values       = [-1.8,-0.75,0,0.7,1.1];
nStepsHard   = [2,2,2];
for ii = 1:length(t.dependent)
    for jj = 1:nSteps
        if ii == 2
            valuesT = values./2 + condDBMean(jj,ii);
        else
            valuesT = values + condDBMean(jj,ii);
        end
        if jj <= nStepsHard(ii)
            condDBE(jj,ii) = nb_distribution('type','constant','parameters',{condDBMean(jj,ii)});
        else
            condDBE(jj,ii) = nb_distribution.perc2DistCDF(perc,valuesT,-3.5,2.5);
        end
    end
end

SP      = struct('Name',model.solution.res,...
                 'Periods',{4,4,4});
modelF  = forecast(model,nSteps,...
            'startDate',        t.estim_end_date+1,...
            'condDB',           condDBE,...
            'condDBVars',       t.dependent,...
            'sigma',            sigma,...
            'output',           'all',...
            'shockProps',       SP,...
            'draws',            1000,...
            'parameterDraws',   10,...
            'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1')
nb_graphSubPlotGUI(plotter);

%% Conditional point forecast (shocks)

% Solve model and do cond forecast on shocks
% This is not draws from the proper distribution!
shockNs = strcat('E_',t.dependent);
condDB  = nb_ts.rand(t.estim_end_date+1,10,shockNs); 
modelF  = forecast(model,8,'startDate',t.estim_end_date+1,...
                   'condDB',condDB,'output','all');%,'endDate','2010Q1'
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (shocks + normal)

% Solve model and do cond forecast on endogenous and exogenous variables 
shockNs = strcat('E_',t.dependent);
condDB  = nb_ts.rand(t.estim_end_date+1,10,shockNs); 
modelF  = forecast(model,8,...
            'startDate',        t.estim_end_date+1,...
            'condDB',           condDB,...
            'output',           'all',...
            'draws',            1000,...
            'parameterDraws',   10,...
            'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
set(plotter,'startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);

%% Conditional density forecast (shocks + manual distribution)

% Make a skewed distribution (Which is at really odd with the estimated!)
perc   = [0.1,0.3,0.5,0.7,0.9]*100;
values = [-1.8,-0.75,0,0.7,1.1];
skewed = nb_distribution.perc2DistCDF(perc,values,-3.5,2.5);
plot([nb_distribution,skewed]);

% Solve model and do cond forecast on endogenous and exogenous variables 
clear condDB
nSteps        = 8;
condDBVars    = strcat('E_',t.dependent);
condDB(8,3)   = nb_distribution; 
condDB(1:4,:) = skewed;
modelF        = forecast(model,nSteps,...
                    'startDate',        t.estim_end_date+1,...
                    'condDB',           condDB,...
                    'condDBVars',       condDBVars,...
                    'output',           'all',...
                    'draws',            1000,...
                    'parameterDraws',   10,...
                    'perc',             [0.3,0.5,0.7,0.9]);
plotter = plotForecast(modelF);
nb_graphSubPlotGUI(plotter);

%% Conditional recursive point forecast (exogenous)

% Create model and estimate
recFcstDate = nb_quarter('1999Q4');
modelExoRec = set(modelExo,...
                'recursive_estim',true,...
                'recursive_estim_start_date',recFcstDate);
modelExoRec = estimate(modelExoRec);

% Solve model
modelExoRec = set_identification(modelExoRec,'cholesky','ordering',t.dependent);
modelExoRec = solve(modelExoRec);

% Solve model and do cond forecast on exogenous variables (point)
condExoDB = data.window(recFcstDate+1,'',tExo.exogenous);
condExoDB = splitSample(condExoDB,8);
modelF    = forecast(modelExoRec,8,'condDB',condExoDB,'output','all',...
                'fcstEval','SE','endDate',tExo.estim_end_date+1);
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter)

