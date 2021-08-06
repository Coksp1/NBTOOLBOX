%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
vars    = {'VAR1','VAR2','VAR3'};
sim     = nb_ts.simulate('1990Q1',obs,vars,1,lambda,rho);
data    = iegrowth(sim/100,ones(1,3)*100,1);

%nb_graphSubPlotGUI(data);

%% Simple VAR with missing data

% Add missing observations
data = setValue(data,'VAR1',nan,'2014Q4','2014Q4');
data = setValue(data,'VAR2',nan(2,1),'2014Q3','2014Q4');

% Options
t                  = nb_var.template();
t.data             = data;
t.constant         = 0;
t.nLags            = 4;

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


expressions = {% Name,  expression,  shift/trend,   description                                                                                                                               
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
model   = set(model,'dependent',VARvars,'missingMethod','forecast'); 

%% Estimate

model = estimate(model);
print(model)

%% Solve model and do point forecast

model   = solve(model);
model   = forecast(model,8,'varOfInterest',{'VAR1','VAR2','VAR3'});
plotter = plotForecast(model);
plotter.set('startGraph','2010Q1');
nb_graphSubPlotGUI(plotter);
