%% Get help on this example

help nb_mode

%% Test mode estimators GAMMA
%% Generate artificial sample

r = nb_distribution.gamma_rand(1000,1000,9,0.5);

% true mode 
trueMode   = nb_distribution.gamma_mode(9,0.5);
trueMean   = nb_distribution.gamma_mean(9,0.5);
trueMedian = nb_distribution.gamma_median(9,0.5);
appMode    = 1.5*trueMedian - 0.5*trueMean;

%% Kernel est
tic
kernelMode = nb_mode(r,1,'kernel');
toc
kernelModeMean = mean(kernelMode)
kernelModeSTD  = std(kernelMode)

tic
kernelMode = nb_mode(r,1,'kernel','bandWidth',1);
toc
kernelModeMean = mean(kernelMode)
kernelModeSTD  = std(kernelMode)

%% Approx formula 
tic
approxMode = nb_mode(r,1,'approx');
toc
approxModeMean = mean(approxMode)
approxModeSTD  = std(approxMode)

%% Half-range mode 
tic
hrmMode = nb_mode(r,1,'hrm');
toc
hrmModeMean = mean(hrmMode)
hrmModeSTD  = std(hrmMode)

%% Half-sample mode 
tic
hsmMode = nb_mode(r,1,'hsm');
toc
hsmModeMean = mean(hsmMode)
hsmModeSTD  = std(hsmMode)

%% Grenander
tic
grenanderMode = nb_mode(r,1,'grenander');
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)

tic
grenanderMode = nb_mode(r,1,'grenander',3,2);
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)


tic
grenanderMode = nb_mode(r,1,'grenander',10,5);
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)


%% Test mode estimators NORMAL
%% Generate artificial sample
r = nb_distribution.normal_rand(1000,1000,0,1);

% true mode 
trueMode   = nb_distribution.normal_mode(0,1);
trueMean   = nb_distribution.normal_mean(0,1);
trueMedian = nb_distribution.normal_median(0,1);
appMode    = 1.5*trueMedian - 0.5*trueMean;

%% Kernel est
tic
kernelMode = nb_mode(r,1,'kernel');
toc
kernelModeMean = mean(kernelMode)
kernelModeSTD  = std(kernelMode)


%% Approx formula 
tic
approxMode = nb_mode(r,1,'approx');
toc
approxModeMean = mean(approxMode)
approxModeSTD  = std(approxMode)

%% Half-range mode 
tic
hrmMode = nb_mode(r,1,'hrm');
toc
hrmModeMean = mean(hrmMode)
hrmModeSTD  = std(hrmMode)

%% Half-sample mode 
tic
hsmMode = nb_mode(r,1,'hsm');
toc
hsmModeMean = mean(hsmMode)
hsmModeSTD  = std(hsmMode)

%% Grenander
tic
grenanderMode = nb_mode(r,1,'grenander');
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)

tic
grenanderMode = nb_mode(r,1,'grenander',3,2);
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)


tic
grenanderMode = nb_mode(r,1,'grenander',10,5);
toc
grenanderModeMean = mean(grenanderMode)
grenanderModeSTD  = std(grenanderMode)

