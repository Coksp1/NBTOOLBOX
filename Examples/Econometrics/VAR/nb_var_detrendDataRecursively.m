%% Get help on this example

help nb_var
help nb_model_recursive_detrending
nb_model_recursive_detrending.help
help nb_var.createVariables
help nb_var.reporting

%% Generate/load artificial data

% This is how the series where generated in levelData.xlsx

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [0.2;0.1;0.3];  
vars    = {'VAR1','VAR2','VAR3'};
sim     = nb_ts.simulate('1990Q1',obs,vars,1,lambda,rho);
data    = igrowth(sim/100+0.01,ones(1,3)*100,1);

%% Simple VAR

% Options
t          = nb_var.template();
t.data     = data;
t.constant = 0;
t.nLags    = 2;

% Create model
model = nb_var(t);

% Formulate model
variables = strcat(vars,'_hp');
model     = set(model,'dependent',variables);

%% Create a nb_model_recursive_detrending object
% This allow for example to do hp-filtering recursively!
%
% Caution: The 'recursive_start_date' option must be set!

modelRec = nb_model_recursive_detrending(model,...
            'recursive_start_date','2001Q1');

%% Do recursive transformations (To store shift/trend)
%
% When producing point forecast transformations of variables may be done
% after the forecast has been produced, but for density forecast it is
% important to do the transformation before for example calculating
% percentiles (for non-linear expressions)
%
% If the forecast should be evaluated based on some transformation
% of variables it is also important to do them in code, at least it is 
% much easier then write your own code for it! (Both point and density)

% This example extrapolates the trend with growth rate at the end of the
% hp-filter
[periods,dates] = modelRec.getRecursivePeriods();
expressions     = cell(3,4,periods);
for ii = 1:periods
    expressions(:,:,ii) = ...
    {% Name,  expression,  shift/trend,   description                                                                                                                               
    'VAR1_hp', 'log(VAR1)', {{'hpfilter',1600},dates{ii},{'endgrowth'}}, ''
    'VAR2_hp', 'log(VAR2)', {{'hpfilter',1600},dates{ii},{'endgrowth'}}, ''
    'VAR3_hp', 'log(VAR3)', {{'hpfilter',1600},dates{ii},{'endgrowth'}}, ''
    };
end

%% Assign inverse transformations (shift/trend will be added automatically)
% We also want to forecast the level variables!

reporting = {% Name,  expression,   description
'VAR1',    'exp(VAR1_hp)', ''
'VAR2',    'exp(VAR2_hp)', ''
'VAR3',    'exp(VAR3_hp)', ''
'G_VAR1',  'growth(VAR1)', ''
'G_VAR2',  'growth(VAR2)', ''
'G_VAR3',  'growth(VAR3)', ''
};

modelRec = set(modelRec,'reporting',reporting); 

%% Create the variables and check reporting

[modelRec,plotter] = createVariables(modelRec,expressions,8);

% We only use information up until '2001Q1' here!
nb_graphInfoStructGUI(plotter(1));

% Detrending at last period
nb_graphInfoStructGUI(plotter(end));

%% Estimate
% Recursively!

modelRec = estimate(modelRec);
print(modelRec)

%% Solve model

modelRec = solve(modelRec);

%% Point forecast
% Recursively!

modelRecP = forecast(modelRec,8,...
    'fcstEval',     {'SE'},...
    'varOfInterest',{'G_VAR1','G_VAR2','G_VAR3',...
                     'VAR1_hp','VAR2_hp','VAR3_hp'});

%% Plot forecast

plotter = plotForecast(modelRecP);
nb_graphSubPlotGUI(plotter);
plotterD = plotForecast(modelRecP,'default','2001Q2');
nb_graphSubPlotGUI(plotterD);

% Remember here that the HP-gaps are shown agains final HP-filtered gap!
plotterH = plotForecast(modelRecP,'hairyplot');
nb_graphSubPlotGUI(plotterH);

%% Evaluate density forecast

score = getScore(modelRecP,'RMSE');
score.Model1

%% Density forecast
% Recursively!

modelRecD = forecast(modelRec,8,...
    'draws',            1000,...
    'parameterDraws',   1,...
    'fcstEval',         {'SE','logScore'},...
    'perc',             [0.3,0.5,0.7,0.9]);
plotterH = plotForecast(modelRecD,'hairyplot');
nb_graphSubPlotGUI(plotterH);

%% Evaluate density forecast

score = getScore(modelRecD,'MLS');
score.Model1
