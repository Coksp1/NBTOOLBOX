%% Get help on this example

nb_var.help
help nb_var.createVariables
help nb_var.reporting
help nb_ts.isUpdateable

%% Generate/load artificial data

% This is how the series where generated in levelData.xlsx

% rng(1); % Set seed
% 
% obs     = 100;
% lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
%            0.5,-0.1,-0.2,0,  0.1,-0.2;
%            0.6,-0.2,0.1, 0,  0.4,-0.1];
% rho     = [1;1;1];  
% vars    = {'VAR1','VAR2','VAR3'};
% sim     = nb_ts.simulate('1990Q1',obs,vars,1,lambda,rho);
% data    = igrowth(sim/100+0.01,ones(1,3)*100,1);

% Load artificial data
folder = nb_folder();
data   = nb_ts([folder '\Examples\Econometrics\VAR\levelData.xlsx']);
data.isUpdateable % This should be true!

% By giving the full path to the excel file, a link to the dataset is
% created, which means that the objects can be updated given changes in
% the data.

%nb_graphSubPlotGUI(data);

%% Simple VAR

% Options
t          = nb_var.template();
t.data     = data;
t.constant = 0;
t.nLags    = 2;

% Create model
model = nb_var(t);

%% Do transformations (To store shift/trend)
%
% When producing point forecast transformations of variables may be done
% after the forecast has been produced, but for density forecast it is
% important to do the transformation before for example calculating
% percentiles (for non-linear expressions)
%
% If the forecast should be evaluated based on some transformation
% of variables it is also important to do them in code, at least it is 
% much easier then write your own code for it! (Both point and density)

expressions = {% Name,  expression,  detrending,   description                                                                                                                               
'VAR1_growth',  'growth(VAR1)',  {'avg'}, ''
'VAR2_growth',  'growth(VAR2)',  {'avg'}, ''
'VAR3_growth',  'growth(VAR3)',  {'avg'}, ''
};

[model,plotter] = model.createVariables(expressions,9);
nb_graphInfoStructGUI(plotter);

%% Assign inverse transformations (shift/trend will be added automatically)
% We also want to forecast the level variables!

expressions = {% Name,  expression,   description
'VAR1',   'igrowth(VAR1_growth,VAR1)', ''
'VAR2',   'igrowth(VAR2_growth,VAR2)', ''
'VAR3',   'igrowth(VAR3_growth,VAR3)', ''
};

model = set(model,'reporting',expressions);

% Check reporting
model = checkReporting(model);

%% Formulate model

VARvars = {'VAR1_growth','VAR2_growth','VAR3_growth'};
model   = set(model,'dependent',VARvars); 

%% Estimate

model = estimate(model,...
    'recursive_estim',true,...
    'recursive_estim_start_date','2009Q4');
print(model)

%% Solve model and do point forecast

vars    = {'VAR1','VAR2','VAR3',...
            'VAR1_growth','VAR2_growth','VAR3_growth'};
model   = solve(model);
model   = forecast(model,8,...
            'fcstEval','SE',...
            'varOfInterest',vars);
plotter = plotForecast(model,'hairyplot');
plotter.set('startGraph','2005Q1');
nb_graphSubPlotGUI(plotter);

%% Get forecast

fcst = getForecast(model);

%% Get actual data

actual = getHistory(model,vars);
actual = splitSample(actual,8,true);
actual = window(actual,'','','',fcst.dataNames(1:end-1));

%% Evaluate forecast

fcstEval = tonb_data(window(fcst,'','','',actual.dataNames));
SE       = (fcstEval - actual).^2;

%% Get forecast evaluation score

% Directly
score = getScore(model,'RMSE',false,'','',true);
score.Model1

% From manual calculations
RMSE = sqrt(mean(SE,'nb_data_scalar',3))

%% Update data of model, re-estimate, re-solve and re-produce forecast
% Warning: This is only possible if the data given to the model is
% updateable

% modelD = update(model);
% modelE = update(model,'estimate');
% modelS = update(model,'solve');
modelF = update(model,'forecast','off','on');

plotter = plotForecast(modelF,'hairyplot');
plotter.set('startGraph','2005Q1');
nb_graphSubPlotGUI(plotter);

%% Solve model and do density forecast

vars    = {'VAR1','VAR2','VAR3',...
            'VAR1_growth','VAR2_growth','VAR3_growth'};
model   = solve(model);
model   = forecast(model,8,...
            'varOfInterest',vars,...
            'draws',1000);
plotter = plotForecast(model);
plotter.set('startGraph','2005Q1');
nb_graphSubPlotGUI(plotter);
