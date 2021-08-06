%% Help on this example

nb_singleEq.help
help nb_ols

%% Generate artificial data

rng(1) % Set seed

EXO1 = randn(100,1);
EXO2 = randn(100,1);
DEP  = 0.2*EXO1 + -0.5*EXO2 + randn(100,1);
data = nb_ts([DEP,EXO1,EXO2],'','1990Q1',{'Dep','Exo1','Exo2'});

%% nb_singleEq (ols)

dep = {'Dep'};
exo = {'Exo1','Exo2'};
seq = nb_singleEq(...
    'data',        data,...
    'dependent',   dep,...
    'exogenous',   exo);

seq = estimate(seq);
print_estimation_results(seq)
seq = solve(seq);

%% nb_singleEq (ols)

dep = {'Dep'};
exo = {'Exo1','Exo2'};
seq = nb_singleEq(...
    'data',            data,...
    'dependent',       dep,...
    'exogenous',       exo,...
    'recursive_estim', true);

seq = estimate(seq);
print(seq)
    
%% Recursive estimation graph

plotter = getRecursiveEstimationGraph(seq);
nb_graphSubPlotGUI(plotter)
              
