%% Help on this example

help nb_distribution
help nb_copula

%% Initialization of the copula

dist(1,4) = nb_distribution(); % Normal marginals
sigma     = [4 3 2 1;3 5 -1 1;2 -1 4 2;1 1 2 5];
stds      = sqrt(diag(sigma));
stds      = stds*stds';
sigma     = sigma./stds; % Correlation matrix
cop       = nb_copula(dist,'sigma',sigma);

%% CDF

p  = cdf(cop,[0,1,2,3])
pm = mvncdf([0,1,2,3],zeros(1,4),sigma)

%% PDF

p  = pdf(cop,[0,0,0,0])
pm = mvnpdf([0,0,0,0],zeros(1,4),sigma)

%% Random generator

D  = random(cop,100,1)
DM = mvnrnd(zeros(1,4),sigma,100)

Dcorr  = corr(D)
DMcorr = corr(DM)

%% Initialization conditional distribution

distC(1,4) = nb_distribution(); % Normal marginals
set(distC(2),'conditionalValue',0);
set(distC(3),'conditionalValue',0);

sigma     = [4 3 2 1;3 5 -1 1;2 -1 4 2;1 1 2 5];
stds      = sqrt(diag(sigma));
stds      = stds*stds';
sigma     = sigma./stds; % Correlation matrix
copCond   = nb_copula(distC,'sigma',sigma);

%% Conditional CDF

p = cdf(copCond,[0,0],'conditional')

%% Conditional PDF

p = pdf(copCond,[0,0],'conditional')

%% Random conditional generator

D = random(copCond,100,10)
