%% Get help on the nb_ecm class

nb_ecm.help
help nb_ecm.solution
help nb_ecm.forecast

%% Simulate some data

rng(1) % Set seed

% Define covid names and dates
[covidDates,drop] = nb_covidDates(4);
covidDates        = covidDates(1:end-drop);
covidDummyNames   = nb_covidDummyNames(4);
covidDummyNames   = covidDummyNames(1:end-drop);

% Set up covid dummies for simulation
obs   = 110;
covid = nb_ts.zeros('1996Q1',obs,{'ZEROS'});
covid = double(keepVariables(covidDummy(covid,covidDates),covidDummyNames));

B     = -[8, -3, 1, -1, 0, 0]';
z     = nan(obs,1);
scale = 10;
z(1)  = scale*rand;
for ii = 2:obs
    z(ii) = z(ii-1) + covid(ii,:)*B + scale*rand;
end
x1 = z + randn(obs,1);
x2 = z + randn(obs,1);
y  = 0.2 + 0.6*x1 + 0.4*x2 + 2*randn(obs,1);
w1 = randn(obs,1);
w2 = randn(obs,1);

data = nb_ts([y,x1,x2,w1,w2,covid],'','1996Q1',[{'y','x1','x2','w1','w2'},covidDummyNames]);

%nb_graphSubPlotGUI(data);

%% Estimate ECM model

t            = nb_ecm.template;
t.data       = data;
t.dependent  = {'y'};
t.endogenous = {'x1','x2'};
t.exogenous  = {'w1','w2'};
t.constant   = 1;
t.nLags      = [2,1,0];
t.exoLags    = {[0,2],[1,2,3]};

model = nb_ecm(t);
model = estimate(model);
print(model)

%% Estimate ECM model
% Strip away covid dates during estimation

t            = nb_ecm.template;
t.data       = data;
t.dependent  = {'y'};
t.endogenous = {'x1','x2'};
t.exogenous  = {'w1','w2'};
t.constant   = 1;
t.nLags      = [2,1,0];
t.exoLags    = {[0,2],[1,2,3]};
t.covidAdj   = covidDates;

model = nb_ecm(t);
model = estimate(model);
print(model)

%% Estimate ECM model, recursive
% Strip away covid dates during estimation

t                 = nb_ecm.template;
t.data            = data;
t.dependent       = {'y'};
t.endogenous      = {'x1','x2'};
t.exogenous       = {'w1','w2'};
t.constant        = 1;
t.nLags           = [2,1,0];
t.exoLags         = {[0,2],[1,2,3]};
t.covidAdj        = covidDates;
t.recursive_estim = true;

model = nb_ecm(t);
model = estimate(model);
print(model)
