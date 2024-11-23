%% Help on the nb_rfModel class

nb_manualCalculator.help
help nb_manualCalculator
help nb_manualCalculator.estimate

%% Simulate some AR-X process and add NaNs

rng(1) % Set seed

T       = 100;
e       = randn(T,1);
ex      = randn(T,1);
x       = nan(T,1);
x(1)    = randn(1,1);
lambdaX = 0.6;
for ii = 2:T
    x(ii) = lambdaX*x(ii-1) + ex(ii); 
end
y       = nan(T,1);
y(1)    = randn(1,1);
lambdaY = 0.8;
beta    = 0.4;
for ii = 2:T
    y(ii) = lambdaY*y(ii-1) + beta*x(ii) + e(ii); 
end

% Transform to nb_ts object
data                 = nb_ts(x,'','2000Q1',{'Original'});
data.data(1:2:end,:) = NaN;

%% Construct model

t               = nb_manualCalculator.template;
t.data          = data;
t.dependent     = {'Original'};
t.calcFunc      = 'myCalcFunc';
t.outVariables  = {'Calculated'};
t.handleMissing = 1;
model           = nb_manualCalculator(t);
model           = estimate(model);
print(model)

%% Plot

p = nb_graph_ts(merge(model.getCalculated,data));
p.missingValues = 'interpolate';
nb_graphPagesGUI(p);

%% Recursive Model

recStartD = '2015Q1';
modelRec = set(model,...
    'recursive_estim',true,...
    'recursive_estim_start_date',recStartD...
);
modelRec = estimate(modelRec);

%% Plot recursive
p = nb_graph_ts(merge(modelRec.getCalculated,data));
p.missingValues = 'interpolate';
nb_graphPagesGUI(p);

%% Construct model and call custom function that also fetches data

t               = nb_manualCalculator.template;
t.dependent     = {'Original'};
t.calcFunc      = 'myFetchDataAndCalcFunc';
t.outVariables  = {'Calculated'};
t.handleMissing = 1;
modelCustData   = nb_manualCalculator(t);
modelCustData   = estimate(modelCustData);
print(modelCustData)

%% Plot

p = nb_graph_ts(merge(modelCustData.getCalculated,data));
p.missingValues = 'interpolate';
nb_graphPagesGUI(p);

%% Recursive Model

recStartD        = '2015Q1';
modelCustDataRec = set(modelCustData,...
    'recursive_estim',true,...
    'recursive_estim_start_date',recStartD...
);
modelCustDataRec = estimate(modelCustDataRec);
print(modelCustDataRec)

%% Plot recursive custom data

p = nb_graph_ts(merge(modelCustDataRec.getCalculated,data));
p.missingValues = 'interpolate';
nb_graphPagesGUI(p);
