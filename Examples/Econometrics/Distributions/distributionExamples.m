%% Help on this example

help nb_distribution

%% Get the properties of this class

properties(nb_distribution)

%% Get the methods of this class

methods(nb_distribution)

%% Initialize many distribution

obj = nb_distribution.initialize('type',{'normal','gamma'},...
      'parameters',{{6,2},{2,2}});
plot(obj,0:0.1:16,'pdf');

%% Normal distribution (static methods)

x   = nb_distribution.normal_rand(100,1,2,2);
f   = nb_distribution.normal_pdf(x,2,2);
F   = nb_distribution.normal_cdf(x,2,2);
iF  = nb_distribution.normal_icdf(F,2,2);
m   = nb_distribution.normal_mean(2,2);
med = nb_distribution.normal_median(2,2);
mod = nb_distribution.normal_mode(2,2);
v   = nb_distribution.normal_variance(2,2);
s   = nb_distribution.normal_skewness(2,2);
k   = nb_distribution.normal_kurtosis(2,2);

%% Normal distribution (object)

distr = nb_distribution('type','normal','parameters',{2,2});
plot(distr,-5:0.1:8);
plot(distr,-5:0.1:8,'cdf');

mDistr(2) = nb_distribution('type','normal','parameters',{2,2});

plot(mDistr,-8:0.1:8);
plot(mDistr,-8:0.1:8,'cdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'normal');
obj = nb_distribution.mle(x,'normal');
obj = nb_distribution.mme(x,'normal');

%% Exponential distribution (static methods)

x   = nb_distribution.exp_rand(100,1,2);
f   = nb_distribution.exp_pdf(x,2);
F   = nb_distribution.exp_cdf(x,2);
iF  = nb_distribution.exp_icdf(F,2);
m   = nb_distribution.exp_mean(2);
med = nb_distribution.exp_median(2);
mod = nb_distribution.exp_mode(2);
v   = nb_distribution.exp_variance(2);
s   = nb_distribution.exp_skewness(2);
k   = nb_distribution.exp_kurtosis(2);

%% Exponential distribution (object)
close all

distr = nb_distribution('type','exp','parameters',{2});
plot(distr,0:0.05:5);
plot(distr,0:0.05:5,'cdf');

obj = nb_distribution.initialize('type',{'exp','exp'},...
      'parameters',{{2},{4}});
plot(obj,0:0.05:5,'pdf');
plot(obj,0:0.05:5,'cdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'exp');
obj = nb_distribution.mle(x,'exp');
obj = nb_distribution.mme(x,'exp');


%% GAMMA distribution (static methods)

x   = nb_distribution.gamma_rand(100,1,2,2);
f   = nb_distribution.gamma_pdf(x,2,2);
F   = nb_distribution.gamma_cdf(x,2,2);
iF  = nb_distribution.gamma_icdf(F,2,2);
m   = nb_distribution.gamma_mean(2,2);
med = nb_distribution.gamma_median(2,2);
mod = nb_distribution.gamma_mode(2,2);
v   = nb_distribution.gamma_variance(2,2);
s   = nb_distribution.gamma_skewness(2,2);
k   = nb_distribution.gamma_kurtosis(2,2);

%% GAMMA distribution (object)

close all

distr = nb_distribution('type','gamma','parameters',{2,2});
plot(distr,0:0.1:20);
plot(distr,0:0.1:20,'cdf');


obj = nb_distribution.initialize('type',{'gamma','gamma'},...
      'parameters',{{1,2},{2,2}});
plot(obj,0:0.1:20,'pdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'gamma');
obj = nb_distribution.mle(x,'gamma');
obj = nb_distribution.mme(x,'gamma');

%% INVGAMMA distribution (static methods)

x   = nb_distribution.invgamma_rand(100,1,4,2);
f   = nb_distribution.invgamma_pdf(x,4,2);
F   = nb_distribution.invgamma_cdf(x,4,2);
iF  = nb_distribution.invgamma_icdf(F,4,2);
m   = nb_distribution.invgamma_mean(4,2);
med = nb_distribution.invgamma_median(4,2);
mod = nb_distribution.invgamma_mode(4,2);
v   = nb_distribution.invgamma_variance(4,2);
s   = nb_distribution.invgamma_skewness(4,2);
k   = nb_distribution.invgamma_kurtosis(4,2);

%% INVGAMMA distribution (object)

close all

distr = nb_distribution('type','invgamma','parameters',{4,2});
plot(distr,0:0.1:5);
plot(distr,0:0.01:5,'cdf');

obj = nb_distribution.initialize('type',{'invgamma','invgamma'},...
      'parameters',{{4,2},{2,1}});
plot(obj,0:0.01:5,'pdf');
plot(obj,0:0.01:5,'cdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'invgamma');
obj = nb_distribution.mle(x,'invgamma');
obj = nb_distribution.mme(x,'invgamma');

%% CHI squared distribution (static methods)

x   = nb_distribution.chis_rand(100,1,2);
f   = nb_distribution.chis_pdf(x,2);
F   = nb_distribution.chis_cdf(x,2);
iF  = nb_distribution.chis_icdf(F,2);
m   = nb_distribution.chis_mean(2);
med = nb_distribution.chis_median(2);
mod = nb_distribution.chis_mode(2);
v   = nb_distribution.chis_variance(2);
s   = nb_distribution.chis_skewness(2);
k   = nb_distribution.chis_kurtosis(2);

%% CHI squared distribution (object)

close all

distr = nb_distribution('type','chis','parameters',{2});
plot(distr,0:0.1:20);
plot(distr,0:0.1:20,'cdf');


obj = nb_distribution.initialize('type',{'chis','chis'},...
      'parameters',{{1},{2}});
plot(obj,0:0.1:20,'pdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'chis');
obj = nb_distribution.mme(x,'chis');

%% BETA distribution (static methods)

x   = nb_distribution.beta_rand(100,1,2,2);
f   = nb_distribution.beta_pdf(x,2,2);
F   = nb_distribution.beta_cdf(x,2,2);
iF  = nb_distribution.beta_icdf(F,2,2);
m   = nb_distribution.beta_mean(2,2);
med = nb_distribution.beta_median(2,2);
mod = nb_distribution.beta_mode(2,2);
v   = nb_distribution.beta_variance(2,2);
s   = nb_distribution.beta_skewness(2,2);
k   = nb_distribution.beta_kurtosis(2,2);

%% BETA distribution (object)

close all

distr = nb_distribution('type','beta','parameters',{2,2});
plot(distr,0:0.01:1);
plot(distr,0:0.01:1,'cdf');


obj = nb_distribution.initialize('type',{'beta','beta'},...
      'parameters',{{1.1,2},{2,2}});
plot(obj,0:0.01:1,'pdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'beta');
obj = nb_distribution.mle(x,'beta');
obj = nb_distribution.mme(x,'beta');

%% Logistic distribution (static methods) 

x   = nb_distribution.logistic_rand(100,1,2,2);
f   = nb_distribution.logistic_pdf(x,2,2);
F   = nb_distribution.logistic_cdf(x,2,2);
iF  = nb_distribution.logistic_icdf(F,2,2);
m   = nb_distribution.logistic_mean(2,2);
med = nb_distribution.logistic_median(2,2);
mod = nb_distribution.logistic_mode(2,2);
v   = nb_distribution.logistic_variance(2,2);
s   = nb_distribution.logistic_skewness(2,2);
k   = nb_distribution.logistic_kurtosis(2,2);

%% Logistic distribution (object)

close all

distr = nb_distribution('type','logistic','parameters',{5,2});
plot(distr);
plot(distr,[],'cdf');

obj = nb_distribution.initialize('type',{'logistic','logistic'},...
      'parameters',{{9,3},{9,4}});
plot(obj);
plot(obj,[],'cdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'logistic');
obj = nb_distribution.mle(x,'logistic');
obj = nb_distribution.mme(x,'logistic');

%% Log normal distribution (static methods)

x   = nb_distribution.lognormal_rand(100,1,1,1);
f   = nb_distribution.lognormal_pdf(x,1,1);
F   = nb_distribution.lognormal_cdf(x,1,1);
iF  = nb_distribution.lognormal_icdf(F,1,1);
m   = nb_distribution.lognormal_mean(1,1);
med = nb_distribution.lognormal_median(1,1);
mod = nb_distribution.lognormal_mode(1,1);
v   = nb_distribution.lognormal_variance(1,1);
s   = nb_distribution.lognormal_skewness(1,1);
k   = nb_distribution.lognormal_kurtosis(1,1);

%% Log normal distribution (object)

close all

distr = nb_distribution('type','lognormal','parameters',{1,1});
plot(distr);
plot(distr,[],'cdf');

obj = nb_distribution.initialize('type',{'lognormal','lognormal'},...
      'parameters',{{0.1,0.5},{1,1}});
plot(obj);
plot(obj,[],'cdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'lognormal');
obj = nb_distribution.mle(x,'lognormal');
obj = nb_distribution.mme(x,'lognormal');

%% F distribution (static methods)

x   = nb_distribution.f_rand(100,1,10,10);
f   = nb_distribution.f_pdf(x,10,10);
F   = nb_distribution.f_cdf(x,10,10);
iF  = nb_distribution.f_icdf(F,10,10);
m   = nb_distribution.f_mean(10,10);
med = nb_distribution.f_median(10,10);
mod = nb_distribution.f_mode(10,10);
v   = nb_distribution.f_variance(10,10);
s   = nb_distribution.f_skewness(10,10);
k   = nb_distribution.f_kurtosis(10,10);

%% F distribution (object)

close all

distr = nb_distribution('type','f','parameters',{10,10});
plot(distr,0:0.1:10);
plot(distr,0:0.1:10,'cdf');


obj = nb_distribution.initialize('type',{'f','f'},...
      'parameters',{{10,10},{100,100}});
plot(obj,0:0.1:10,'pdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'f');
obj = nb_distribution.mme(x,'f');

%% Student-t distribution (static methods)

x   = nb_distribution.t_rand(100,1,5);
f   = nb_distribution.t_pdf(x,5);
F   = nb_distribution.t_cdf(x,5);
iF  = nb_distribution.t_icdf(F,5);
m   = nb_distribution.t_mean(5);
med = nb_distribution.t_median(5);
mod = nb_distribution.t_mode(5);
v   = nb_distribution.t_variance(5);
s   = nb_distribution.t_skewness(5);
k   = nb_distribution.t_kurtosis(5);

%% Student-t distribution (object)

close all

distr = nb_distribution('type','t','parameters',{5});
plot(distr,-7:0.1:7);
plot(distr,-7:0.1:7,'cdf');


obj = nb_distribution.initialize('type',{'t','t'},...
      'parameters',{{5},{100}});
plot(obj,-7:0.1:7,'pdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'t');
obj = nb_distribution.mme(x,'t');

%% Non-standardized Student-t distribution (object)

close all

distr = nb_distribution('type','t','parameters',{5,0,2});
plot(distr,-7:0.1:7);
plot(distr,-7:0.1:7,'cdf');


obj = nb_distribution.initialize('type',{'t','t'},...
      'parameters',{{5,0,1},{5,0,2}});
plot(obj,-7:0.1:7,'pdf');

% Estimation/parametrization
x   = nb_distribution.t_rand(100,1,5,0,2);
obj = nb_distribution.mme(x,'t');
obj = nb_distribution.mle(x,'t');

%% Asymmetric generalized Student-t distribution (static methods)

p1  = 0; % Location
p2  = 1; % Scale
p3  = 0.5; % Skewness
p4  = 1000; % Left tail behavioral
p5  = 5; % Right tail behavioral

x   = nb_distribution.ast_rand(100,1,p1,p2,p3,p4,p5); 
f   = nb_distribution.ast_pdf(x,p1,p2,p3,p4,p5);
F   = nb_distribution.ast_cdf(x,p1,p2,p3,p4,p5);
iF  = nb_distribution.ast_icdf(F,p1,p2,p3,p4,p5);
m   = nb_distribution.ast_mean(p1,p2,p3,p4,p5);
med = nb_distribution.ast_median(p1,p2,p3,p4,p5);
mod = nb_distribution.ast_mode(p1,p2,p3,p4,p5);
v   = nb_distribution.ast_variance(p1,p2,p3,p4,p5);
s   = nb_distribution.ast_skewness(p1,p2,p3,p4,p5);
k   = nb_distribution.ast_kurtosis(p1,p2,p3,p4,p5);

%% Asymmetric generalized student-t distribution (object)

close all

distr  = nb_distribution('type','ast','parameters',{p1,p2,p3,p4,p5});
distr2 = nb_distribution('type','t','parameters',{5});
distr  = [distr,distr2];
plot(distr,-7:0.1:7);
plot(distr,-7:0.1:7,'cdf');


obj = nb_distribution.initialize('type',{'ast','ast'},...
      'parameters',{{p1,p2,p3,p4,p5},{p1,p2,p3,p4,1000}});
plot(obj,-7:0.1:7,'pdf');

% Estimation
distr   = nb_distribution('type','ast','parameters',{p1,p2,p3,1000,5});
x       = random(distr,1000,1);
eDistr  = nb_distribution.mle(x,'ast'); % This is not so good!
keDistr = nb_distribution.estimate(x);
plot([distr,eDistr,keDistr],-7:0.1:7);


%% Uniform distribution (static methods)

x   = nb_distribution.uniform_rand(100,1,1,10);
f   = nb_distribution.uniform_pdf(x,1,10);
F   = nb_distribution.uniform_cdf(x,1,10);
iF  = nb_distribution.uniform_icdf(F,1,10);
m   = nb_distribution.uniform_mean(1,10);
med = nb_distribution.uniform_median(1,10);
mod = nb_distribution.uniform_mode(1,10);
v   = nb_distribution.uniform_variance(1,10);
s   = nb_distribution.uniform_skewness(1,10);
k   = nb_distribution.uniform_kurtosis(1,10);

%% Uniform distribution (object)

close all

distr = nb_distribution('type','uniform','parameters',{1,10});
plot(distr,0:0.1:11);
plot(distr,0:0.1:11,'cdf');


obj = nb_distribution.initialize('type',{'uniform','uniform'},...
      'parameters',{{1,10},{2,9}});
plot(obj,0:0.1:11,'pdf');

% Estimation/parametrization
obj = nb_distribution.parameterization(m,v,'uniform');
obj = nb_distribution.mle(x,'uniform');
obj = nb_distribution.mme(x,'uniform');

%% Wald distribution (static methods) 

x   = nb_distribution.wald_rand(100,1,2,2);
f   = nb_distribution.wald_pdf(x,2,2);
F   = nb_distribution.wald_cdf(x,2,2);
iF  = nb_distribution.wald_icdf(F,2,2);
m   = nb_distribution.wald_mean(2,2);
med = nb_distribution.wald_median(2,2);
mod = nb_distribution.wald_mode(2,2);
v   = nb_distribution.wald_variance(2,2);
s   = nb_distribution.wald_skewness(2,2);
k   = nb_distribution.wald_kurtosis(2,2);

%% Wald distribution (object)

close all

distr = nb_distribution('type','wald','parameters',{2,2});
plot(distr,0:0.01:3);
plot(distr,0:0.01:3,'cdf');

obj = nb_distribution.initialize('type',{'wald','wald'},...
      'parameters',{{1,1},{1,3}});
plot(obj,0:0.01:3,'pdf');
plot(obj,0:0.01:3,'cdf');

% Estimation/parametrization
obj = nb_distribution.parametrization(m,v,'wald');
obj = nb_distribution.mle(x,'wald');
obj = nb_distribution.mme(x,'wald');

%% Using the meanShift property

distr1 = nb_distribution('type','normal','parameters',{0,2},'meanShift',1);
distr2 = nb_distribution('type','normal','parameters',{1,2});
distr  = [distr1,distr2];
plot(distr);
plot(distr,[],'cdf');

x   = random(distr,100);
x   = permute(x,[1,4,2,3]);
mr  = mean(x,1)
m   = mean(distr)
mo  = mode(distr)
me  = median(distr)
v   = variance(distr)
std = std(distr)
s   = skewness(distr)
k   = kurtosis(distr)
p   = percentile(distr,[10,30,50,70,90])

%% Truncated normal distribution 

close all
clear all
clc

obj = nb_distribution.initialize(...
      'type',       {'normal','normal','normal'},...
      'parameters', {{0,5},{0,5},{0,5}},...
      'lowerBound', {[],-2,-2},...
      'upperBound', {[],[],2});
plot(obj,-11:0.1:11,'pdf');
plot(obj,-11:0.1:11,'cdf');

xlb = icdf(obj,0);
xub = icdf(obj,1);

draws = random(obj,100,1);

% Moments of the distributions. Are only approximation, as random
% draws from the trucated distribution is used to calculate the moments!
avg  = mean(obj)
med  = median(obj)
mod  = mode(obj)
var  = variance(obj)
sdev = std(obj)
skew = skewness(obj)
kurt = kurtosis(obj)

%% Estimating using an estimated kernel density

close all

X      = nb_distribution.normal_rand(1000,1,2,2);
fitted = nb_distribution.estimate(X);
actual = nb_distribution('type','normal','parameters',{2,2});

plot([actual,fitted],[-8:0.1:12]);
plot([actual,fitted],[-8:0.1:12],'cdf');

%% Estimating using a estimated kernel density (GAMMA)

X      = nb_distribution.gamma_rand(1000,1,2,2);
fitted = nb_distribution.estimate(X,[]);
actual = nb_distribution('type','gamma','parameters',{2,2});

plot([actual,fitted]);
plot([actual,fitted],[],'cdf');

%% From percentiles to distribution

actual = nb_distribution('type','normal','parameters',{0,2});
perc   = [5,10,30,50,70,90,95];
values = percentile(actual,perc);
fitted = nb_distribution.perc2Dist(perc,values,1000,3);%,'support','positive'

plot([actual,fitted],[-8:0.1:8]);
plot([actual,fitted],[-8:0.1:8],'cdf');

%% From percentiles to distribution GAMMA

close all

actual = nb_distribution('type','gamma','parameters',{2,2});
perc   = [10,30,50,70,90];%[10,30,50,70,90];
values = percentile(actual,perc);
fitted = nb_distribution.perc2Dist(perc,values,10000,1000,3);

plot([actual,fitted],[-8:0.1:20]);
plot([actual,fitted],[-8:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

fitted = nb_distribution.perc2DistCDF(perc,values,0,15);

plot([actual,fitted],[-8:0.1:20]);
plot([actual,fitted],[-8:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

fitted = nb_distribution.perc2DistCDF(perc,values,0.01,15,1000,10000);

plot([actual,fitted],[-8:0.1:20]);
plot([actual,fitted],[-8:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

%% From percentiles to distribution: unknown

close all

perc   = [10,30,50,70,90];%[10,30,50,70,90];
values = [1,4,6,7,10];
fitted = nb_distribution.perc2Dist(perc,values,10000,1000,3);%

plot(fitted,[-5:0.1:20]);
plot(fitted,[-5:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

fitted = nb_distribution.perc2DistCDF(perc,values,-3,15);%

plot(fitted,[-5:0.1:20]);
plot(fitted,[-5:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

fitted = nb_distribution.perc2DistCDF(perc,values,-3,15,1000);

plot(fitted,[-5:0.1:20]);
plot(fitted,[-5:0.1:20],'cdf');

valuesF = percentile(fitted,perc)

%% Correlated draws from different marginals using a copula
 
distr = nb_distribution.initialize('type',{'normal','gamma'},...
                                  'parameters',{{6,2},{2,2}});
obj   = nb_copula(distr,'type','none','sigma',[1,0.5;0.5,1]);
DN    = random(obj,100);
corrN = corr(DN);

fitted = nb_distribution.estimate(DN(:,1));
actual = nb_distribution('type','normal','parameters',{6,2});

plot([actual,fitted],[-8:0.1:12]);
plot([actual,fitted],[-8:0.1:12],'cdf');

fitted2 = nb_distribution.estimate(DN(:,2),0:0.01:20);
actual2 = nb_distribution('type','gamma','parameters',{2,2});

plot([actual2,fitted2],[0:0.1:12]);
plot([actual2,fitted2],[0:0.1:12],'cdf');

%% 

close all
clear all
clc

%% Increment distribution

d = nb_distribution('type','normal');
convert(d);
d2 = copy(d);
increment(d2,'pdf',900,10,'kernel');
d3 = copy(d2);
increment(d3,'pdf',800,5,'kernel');
plot([d,d2,d3]);

d = nb_distribution('type','normal');
convert(d);
d2 = copy(d);
increment(d2,'pdf',800,0.11,50);
% d3 = copy(d2);
% increment(d3,'pdf',800,5,'kernel');
plot([d,d2]);

%% Plot estimated distribution with histogram

x   = nb_distribution.normal_rand(10000,1,0,2);
dist = nb_distribution.mle(x,'normal');
hist = nb_distribution('type','hist','parameters',{x});

plot([hist,dist]);
plot([hist,dist],-8:0.5:8,'pdf');
plot([hist,dist],-8:0.5:8,'cdf');


