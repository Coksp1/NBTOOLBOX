%% Help on this example

nb_singleEq.help
help nb_lasso

%% Generate artificial data

rng(1) % Set seed

EXO1 = randn(100,1);
EXO2 = randn(100,1);
DEP  = 0.2*EXO1 + -0.5*EXO2 + randn(100,1);
data = nb_ts([DEP,EXO1,EXO2],'','1990Q1',{'Dep','Exo1','Exo2'});

%% nb_singleEq (lasso)

dep = {'Dep'};
exo = {'Exo1','Exo2'};
seq = nb_singleEq(...
    'data',             data,...
    'dependent',        dep,...
    'estim_method',     'lasso',...
    'exogenous',        exo,...
    'regularization',   1/0.5);

seq = estimate(seq);
print(seq)
seq = solve(seq);

%% nb_singleEq (lasso)

opt         = nb_lasso.optimset();
opt.display = 'off';

dep = {'Dep'};
exo = {'Exo1','Exo2'};
seq = nb_singleEq(...
    'data',            data,...
    'dependent',       dep,...
    'estim_method',    'lasso',...
    'exogenous',       exo,...
    'optimset',        opt,...
    'recursive_estim', true,...
    'regularization',  1/0.5);

seq = estimate(seq);
print(seq)
    
%% Recursive estimation graph

plotter = getRecursiveEstimationGraph(seq);
nb_graphSubPlotGUI(plotter)
              
