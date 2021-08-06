%% Help on this example

nb_singleEq.help
help nb_tsls

%% Generate artificial data

rng(1) % Set seed

sigma = [0.4, 0.1; 
         0.1, 0.6];
S     = nb_mvnrand(100,1,[0,0],sigma);
EXO   = randn(100,1); % Uncorrelated with RES, but correlated with ENDO
ENDO  = S(:,1) + EXO; 
RES   = S(:,1); 
DEP   = 0.5*ENDO + RES + randn(100,1)*0.5;

data = nb_ts([DEP,ENDO,EXO],'','1980Q1',{'Dep','Endo','Exo'});

%% nb_singleEq (ols)

dep  = {'Dep'};
exo  = {'Endo'};
seq  = nb_singleEq(...
    'estim_method',     'ols',...
    'data',             data,...
    'dependent',        dep,...
    'exogenous',        exo);

seq = estimate(seq);
print(seq)

%% nb_singleEq (tsls)

dep   = {'Dep'};
endo  = {'Endo'};
instr = {'Endo',{'Exo'}};
seq  = nb_singleEq(...
    'estim_method',     'tsls',...
    'data',             data,...
    'dependent',        dep,...
    'endogenous',       endo,...
    'instruments',      instr);

seq = estimate(seq);
print(seq)

%% F-Test (class)

% Test restrictions
A    = [1,0;0,1];
c    = [1;0];
test = nb_fTestStatistic(model,'A',A,'c',c); 
print(test)

%% Chow-Test (class)

test = nb_chowTestStatistic(model,'breakpoint','2000Q1'); 
print(test)

%% ARCH-Test (class)

test = nb_archTestStatistic(model,'nLags',4); 
print(test)

%% Autocorrelation-Test  (class) TSLS

test = nb_autocorrTestStatistic(model,'nLags',4); 
print(test)
