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
data   = nb_ts([double(sim),agg],'','2000Q1',...
                {'Sim1','Sim2','Sim3','Sim4','Agg'},false);
    
% Plot
plot(data)
      
%% Estimate, solve and forecast aggregated series

% Set options shared by all models
options                            = nb_arima.template;
options.AR                         = 1;
options.MA                         = 0;
options.integration                = 0;
options.constant                   = 0;
options.data                       = data;
options.dependent                  = {'Agg'};
options.recursive_estim            = 1;
options.recursive_estim_start_date = '2010Q1';
options.data                       = data;
model                              = nb_arima(options);

% Estimate all models
model   = estimate(model);
model   = solve(model);
modelPF = forecast(model,8,'fcstEval',{'SE'});

%% Estimate dissagregated models

% Set options shared by all models
options                            = nb_arima.template;
options.AR                         = 1;
options.MA                         = 0;
options.integration                = 0;
options.constant                   = 0;
options.recursive_estim            = 1;
options.recursive_estim_start_date = '2010Q1';
options.data                       = data;
models                             = nb_arima(options);

% Replicate the model
models  = repmat(models,1,nDis);

% Loop through fro each variable 
variables = data.variables(1:nDis);
for ii = 1:nDis
   models(ii) = set(models(ii),'dependent',variables(ii)); 
end

% Estimate all models
models = estimate(models);

%% Solve the models

models = solve(models);

%% Forecast (recursive)

modelsPF = forecast(models,8,'fcstEval',{'SE'});

%% Aggregate models

modelGroupPF = nb_model_group(modelsPF);
modelGroupPF = aggregateForecast(modelGroupPF,...
                'weights',      weights,...
                'newVar',       'Agg',...
                'variables',    variables,...
                'fcstEval',     {'SE'});
 
% Plot the aggregated forecast with history
plotter = plotForecast(modelGroupPF);
nb_graphSubPlotGUI(plotter);

% See the individual forecast
plotter = plotForecast(modelsPF);
nb_graphSubPlotGUI(plotter);            
            
%% Root mean squared error

score = getScore(modelGroupPF,'RMSE');
score.Model1

score = getScore(modelPF,'RMSE');
score.Model1

%% Density Forecast (recursive)

modelsDF = forecast(models,8,...
            'fcstEval',{'logScore'},...
            'draws',   1000,...
            'perc',    []);

%% Aggregate models
% The autocorrelation matrix is estimated based on the emprirical data 
% only.

modelGroup = nb_model_group(modelsDF);
modelGroup = aggregateForecast(modelGroup,...
                'density',      true,...
                'method',       'copula',...
                'weights',      weights,...
                'newVar',       'Agg',...
                'variables',    variables,...
                'fcstEval',     {'logScore'},...
                'nLags',        4,...
                'perc',         []);
     
rC = modelGroup.getScore('MLS');
rC = rC.Model1;
            
%% Aggregate density forecast
% The autocorrelation matrix is estimated using the theoretical 
% conditional moments of the forecast from a VAR on the disaggregated
% series.

modelGroupV = nb_model_group(modelsDF);
modelGroupV = aggregateForecast(modelGroupV,...
                'density',      true,...
                'method',       'copula',...
                'weights',      weights,...
                'newVar',       'Agg',...
                'variables',    variables,...
                'fcstEval',     {'logScore'},...
                'nLags',        4,...
                'perc',         [],...
                'sigmaMethod',  'var');            
       
rV = modelGroupV.getScore('MLS');
rV = rV.Model1;
rV = addPostfix(rV,'(VAR)');
                         
%% Plotting            
            
% Plot the aggregated forecast with history
plotter = plotForecast(modelGroup,'hairyplot');
nb_graphSubPlotGUI(plotter);

% Plot the aggregated forecast with history
plotter = plotForecast(modelGroupV,'hairyplot');
nb_graphSubPlotGUI(plotter);

% See the individual forecast
for ii = 1:length(modelsDF)
    plotter = plotForecast(modelsDF(ii));
    nb_graphSubPlotGUI(plotter);  
end

%% Density forecast aggregated series

modelDF = forecast(model,8,...
            'fcstEval',{'logScore'},...
            'draws',   1000,...
            'perc',    []);
rA = modelDF.getScore('MLS');
rA = rA.Model1;
rA = addPostfix(rA,'(AGG)');
        
%% Merge and display scores

[rC,rV,rA]

