%% Get help on this example

help nb_model_group
help nb_model_group.aggregateForecast

%% Simulate some artificial data

rng(1); % Set seed

nDis    = 4;
obs     = 100;
lambda  = [ 0.5,  0.1,  0.3,  0.6, 0.2,  0.2, -0.1, 0;
            0.5, -0.1, -0.2,  0.4,   0,  0.1, -0.2, 0;
            0.6, -0.2,  0.1, -0.2,   0,  0.4, -0.1, 0;
           -0.2, -0.4,    0,  0.7,   0,    0,    0, 0]; 
rho     = [1;1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3','VAR4'},1,lambda,rho);
weights = [0.3,0.2,0.4,0.1];
agg     = sum(bsxfun(@times,weights,double(sim)),2);

% Transform to nb_ts object
dataG   = nb_ts([double(sim),agg],'','2000Q1',...
                {'Sim1','Sim2','Sim3','Sim4','Agg'},false);
data    = iepcn(dataG);   
            
% Plot
plot(dataG)
plot(data)
      
%% Estimate, solve and forecast aggregated series

% Set options shared by all models
options             = nb_arima.template;
options.AR          = 1;
options.MA          = 0;
options.integration = 0;
options.constant    = 0;
options.dependent   = {'Agg_G'};
model               = nb_arima(options);

trans = {
    'Agg_G', 'epcn(Agg)','',''
};
rep = {
    'Agg', 'iepcn(Agg_G,Agg)',''
};

model = set(model,'transformations',trans,'reporting',rep,'data',data);

% Estimate all models
model   = estimate(model);
model   = solve(model);
modelPF = forecast(model,8);

%% Estimate dissagregated models

% Set options shared by all models
options             = nb_arima.template;
options.AR          = 1;
options.MA          = 0;
options.integration = 0;
options.constant    = 0;
models              = nb_arima(options);

% Replicate the model
models  = repmat(models,1,nDis);

% Loop through fro each variable 
variables = data.variables(1:nDis);
for ii = 1:nDis
     
    trans = {
        [variables{ii} '_G'], ['epcn(' variables{ii} ')'],'',''
    };
    rep = {
        variables{ii}, ['iepcn(' variables{ii} '_G,' variables{ii} ')'],''
    };

    models(ii) = set(models(ii),'transformations',trans,'reporting',rep,...
        'data',data,'dependent',strcat(variables(ii), '_G'));
end

models   = estimate(models);
models   = solve(models);
modelsPF = forecast(models,8);

%% Harmonize forecast

condDB = window(getForecast(modelPF),'','',{'Agg'});
for ii = 1:nDis
    condDB = merge(condDB,window(getForecast(modelsPF(ii)),'','',variables(ii)));
end

lossFunc = {
'epcn(Sim1)'
'epcn(Sim2)'
'epcn(Sim3)'
'epcn(Sim4)'
};

constraints = {
'epcn(Agg)-0.3*epcn(Sim1)-0.2*epcn(Sim2)-0.4*epcn(Sim3)-0.1*epcn(Sim4)'
};

restrictions = nb_SMARTHarmonizeLossFunc(...
    'Restriction',...
    'Apply the restriction that the Sim variables adds upp to Agg',...
    lossFunc, ...
    [2,2,2,1],...
    constraints ...
);


t             = nb_harmonizer.template;
t.algorithm   = 'lossFunc';
t.data        = data;
t.condDB      = condDB.tonb_data();
t.harmonizers = {restrictions};

model = nb_harmonizer(t);
model = estimate(model);
model = solve(model);
model = forecast(model,8);

%% Plot harmonization vs input forecasts

plotter = plotHarmonization(model);
plotter.set('subPlotSize',[3,2]);
nb_graphSubPlotGUI(plotter);

%% Harmonize forecast
% Ragged-edge

condDB = window(getForecast(modelPF),'','',{'Agg'});
for ii = 1:nDis
    condDB = merge(condDB,window(getForecast(modelsPF(ii)),'','',variables(ii)));
end
condDB = condDB.tonb_data();

% Set the userData property to handle ragged-edge
endHist         = data.getRealEndDateVariables('nb_date');
endHist(2)      = nb_quarter('2025Q1');
condDB.userData = endHist;

lossFunc = {
'epcn(Sim1)'
'epcn(Sim2)'
'epcn(Sim3)'
'epcn(Sim4)'
};

constraints = {
'epcn(Agg)-0.3*epcn(Sim1)-0.2*epcn(Sim2)-0.4*epcn(Sim3)-0.1*epcn(Sim4)'
};

restrictions = nb_SMARTHarmonizeLossFunc(...
    'Restriction',...
    'Apply the restriction that the Sim variables adds upp to Agg',...
    lossFunc, ...
    [2,2,2,1],...
    constraints ...
);


t             = nb_harmonizer.template;
t.algorithm   = 'lossFunc';
t.data        = data;
t.condDB      = condDB;
t.harmonizers = {restrictions};

model = nb_harmonizer(t);
model = estimate(model);
model = solve(model);
model = forecast(model,8);

%% Plot forecast

plotter = plotHarmonization(model);
plotter.set('subPlotSize',[3,2]);
nb_graphSubPlotGUI(plotter);

%% Estimate, solve and forecast aggregated series
% Yearly frequency

dataY = convert(data,1,'average');
dataY = addPostfix(dataY,'_y');

% Set options shared by all models
options             = nb_arima.template;
options.AR          = 1;
options.MA          = 0;
options.integration = 0;
options.constant    = 0;
options.dependent   = {'Agg_y_G'};
modelY               = nb_arima(options);

trans = {
    'Agg_y_G', 'epcn(Agg_y)','',''
};
rep = {
    'Agg_y', 'iepcn(Agg_y_G,Agg_y)',''
};

modelY = set(modelY,'transformations',trans,'reporting',rep,'data',dataY);

% Estimate all models
modelY = estimate(modelY);
modelY = solve(modelY);
modelY = forecast(modelY,8);

%% Harmonize forecast
% Mixed frequency

% Get data of the forecasts
dataYQ = convert(window(dataY,'','',{'Agg_y'}),4,'none','interpolateDate','end');
dataQ  = merge(data,dataYQ);

% Get forecasts to harmonize
condDB  = window(getForecast(modelPF,data.endDate+1),'','',{'Agg'});
condDBY = convert(window(getForecast(modelY,dataY.endDate+1),'','',{'Agg_y'}),4,'none','interpolateDate','end');
condDB  = merge(condDB,condDBY);
condDB  = condDB.tonb_data();

% Set the userData property to handle ragged-edge
endHist         = [nb_quarter('2025Q1'),nb_quarter('2024Q4')];
condDB.userData = endHist;

lossFunc = {
'epcn(Agg)'
};

constraints = {
'Agg_y-Agg'
};

restrictions = nb_SMARTHarmonizeLossFunc(...
    'Restriction',...
    'Apply the restriction that the Agg should conver to Agg_y',...
    lossFunc, ...
    2,...
    constraints, ...
    [],...
    1, ...
    'average' ...
);


t             = nb_harmonizer.template;
t.algorithm   = 'lossFunc';
t.data        = dataQ;
t.condDB      = condDB;
t.harmonizers = {restrictions};
t.frequency   = {'Agg_y',1};

model = nb_harmonizer(t);
model = estimate(model);
model = solve(model);
model = forecast(model,condDBY.numberOfObservations);

%% Plot forecast

plotter = plotHarmonization(model);
plotter.set('subPlotSize',[3,2]);
nb_graphSubPlotGUI(plotter);

%% Estimate dissagregated models
% Yearly frequencies

% Set options shared by all models
options             = nb_arima.template;
options.AR          = 1;
options.MA          = 0;
options.integration = 0;
options.constant    = 0;
modelsY             = nb_arima(options);

% Replicate the model
modelsY  = repmat(modelsY,1,nDis);

% Loop through fro each variable 
variables = dataY.variables(1:nDis);
for ii = 1:nDis
     
    trans = {
        [variables{ii} '_G'], ['epcn(' variables{ii} ')'],'',''
    };
    rep = {
        variables{ii}, ['iepcn(' variables{ii} '_G,' variables{ii} ')'],''
    };

    modelsY(ii) = set(modelsY(ii),'transformations',trans,'reporting',rep,...
        'data',dataY,'dependent',strcat(variables(ii), '_G'));
end

% Estimate all models
modelsY = estimate(modelsY);
modelsY = solve(modelsY);
modelsY = forecast(modelsY,8);

%% Harmonize forecast
% Mixed frequency, but restrictions are on the low variables only

% Get data of the forecasts
dataYQ = convert(dataY,4,'none','interpolateDate','end');

% Get forecasts to harmonize
condDB = convert(window(getForecast(modelY,dataY.endDate+1),'','',{'Agg_y'}),4,'none','interpolateDate','end');
for ii = 1:nDis
    condDB = merge(condDB,convert(window(getForecast(modelsY(ii),dataY.endDate+1),'','',variables(ii)),4,'none','interpolateDate','end'));
end
condDB = expand(condDB,convert(dataYQ.endDate + 1,4),'','nan');
condDB = condDB.tonb_data();

% Set the userData property to handle ragged-edge
endHist         = dataYQ.getRealEndDateVariables('nb_date');
condDB.userData = endHist;

lossFunc = {
'epcn(Sim1_y)'
'epcn(Sim2_y)'
'epcn(Sim3_y)'
'epcn(Sim4_y)'
};

constraints = {
'epcn(Agg_y)-0.3*epcn(Sim1_y)-0.2*epcn(Sim2_y)-0.4*epcn(Sim3_y)-0.1*epcn(Sim4_y)'
};

restrictions = nb_SMARTHarmonizeLossFunc(...
    'Restriction',...
    'Apply the restriction that the Sim_y variables adds upp to Agg_y',...
    lossFunc, ...
    [2,2,2,1],...
    constraints, ...
    [],...
    1, ...
    'average' ...
);


t             = nb_harmonizer.template;
t.algorithm   = 'lossFunc';
t.data        = dataYQ;
t.condDB      = condDB;
t.harmonizers = {restrictions};
t.frequency   = {'Agg_y',1,'Sim1_y',1,'Sim2_y',1,'Sim3_y',1,'Sim4_y',1};

model = nb_harmonizer(t);
model = estimate(model);
model = solve(model);
model = forecast(model,condDBY.numberOfObservations);

%% Plot forecast

plotter = plotHarmonization(model);
plotter.set('subPlotSize',[3,2]);
nb_graphSubPlotGUI(plotter);

%% Check that the restrictions has been followed

fcstY = convert(getForecast(model,'2025Q1',true),1);
fcstY = createVariable(fcstY,'restriction','epcn(Agg_y)-0.3*epcn(Sim1_y)-0.2*epcn(Sim2_y)-0.4*epcn(Sim3_y)-0.1*epcn(Sim4_y)');
