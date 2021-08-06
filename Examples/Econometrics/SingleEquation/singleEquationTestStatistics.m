%% Get help on this example

nb_singleEq.help
help nb_ols

help nb_restrictedFTest
help nb_fTestStatistic
help nb_chowTestStatistic
help nb_archTestStatistic

%% Generate artificial data

EXO1 = randn(100,1);
EXO2 = randn(100,1);
DEP  = 0.2*EXO1 + -0.5*EXO2 + randn(100,1);
data = nb_ts([DEP,EXO1,EXO2],'','1990Q1',{'Dep','Exo1','Exo2'});

%% Robust STD

options           = nb_singleEq.template();
options.dependent = {'Dep'};
options.exogenous = {'Exo1','Exo2'};
options.stdType   = 'nw'; % 'h','nw','w'
options.data      = data;
model             = nb_singleEq(options);

% Estimate model
model = estimate(model);
print(model)

%% Standard

options           = nb_singleEq.template();
options.dependent = {'Dep'};
options.exogenous = {'Exo1','Exo2'};
options.data      = data;
options.constant  = 0;
model             = nb_singleEq(options);

% Estimate model
model = estimate(model);
print(model)

%% F-Test (function)

beta          = model.results.beta;
residual      = model.results.residual;
X             = model.results.regressors;
A             = [1,0;0,1];
c             = [0.3;-0.2];
[fTest,fProb] = nb_restrictedFTest(A,c,X,beta,residual) 

%% F-Test (class)

% Test restrictions
A    = [1,0;0,1];
c    = [0.3;-0.2];
test = nb_fTestStatistic(model,'A',A,'c',c); 
print(test)


%% Chow-Test (class)

test = nb_chowTestStatistic(model,'breakpoint','2000Q1'); 
print(test)

%% Recursive chow test

test    = nb_chowTestStatistic(model,'recursive',true);
test    = doTest(test);
plotter = plot(test);
nb_graphPagesGUI(plotter);

%% ARCH-Test (class)

test = nb_archTestStatistic(model,'nLags',4); 
print(test)

%% Autocorrelation-Test (class)

test = nb_autocorrTestStatistic(model,'nLags',4); 
print(test)
