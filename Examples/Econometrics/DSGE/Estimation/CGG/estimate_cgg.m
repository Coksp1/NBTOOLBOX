%% Help on this example

nb_dsge.help
help nb_dsge.estimate

%% Setup for estimation

plotP = false;

% Parse model
m = nb_dsge('nb_file','cgg_rule.nb','silent',false);

% Calibration
param           = struct();
param.alpha     = 0.1;
param.beta      = 1;
param.gamma_eps = 0;
param.gamma_eta = 0;
param.gamma_i   = 0.8;
param.gamma_pie = 1.2;
param.gamma_y   = 0.338;
param.phi       = 0.5;
param.std_e     = 0.01;
param.std_eps   = 0.01;
param.std_eta   = 0.01;
param.theta     = 0.5;
param.varphi    = 0.8;
m               = assignParameters(m,param);

% Simulate som data to estimate the model on
m     = solve(m);
dataM = simulate(m,100,'draws',1,'burn',100);
data  = dataM.Model1;
data  = tonb_ts(data,'2012Q1');
m     = set(m,'data',data);

% Priors
priors           = struct();
priors.gamma_pie = {1.2, 1.2,0.2,'normal'};
priors.gamma_i   = {0.6, 0.5,0.2,'beta'};
priors.gamma_y   = {0.338,0.4,1,'normal'};
priors.std_eps   = {0.01,0.01,1,'invgamma'};
m                = set(m,'prior',priors);

% Filtering options
m = set(m,...
'kf_init_variance', [],...
'kf_presample',     5);

if plotP
    plotter = plotPriors(m);
    nb_graphMultiGUI(plotter);
end

%% Mode estimation

me = estimate(m,'optimizer','fmincon','estim_steady_state_solve',false);
me.print

% Solve the estimated version (This is not done in the estimate method!!)
mes = solve(me);

%% Curvature

plotter = curvature(mes,[],'prior','likelihood','posterior',...
                           'incrFactor',100);
nb_graphMultiGUI(plotter);

% In this case no vertical line is added at the mode for now :(
plotter = curvature(mes,[],'likelihood','posterior','subplot',...
                           'incrFactor',100);
nb_graphSubPlotGUI(plotter);

plotter = curvature(mes,[],'likelihood','posterior','subplot',...
                           'incrFactor',[],'tolerance',eps^(1/2),...
                           'takeLog',[false(3,1);true]);
nb_graphSubPlotGUI(plotter);

%% Posterior draws

tic

% These are the draws made by the sampler!
samplingDraws = 2000; 

% This are the number of draws that is kept for IRFs, 
% posterior plots, density forecast etc... They are randomly selected
% from the sampled draws from chain 1.
usedDraws = 1000; 

opt = nb_mcmc.optimset('log',true,'waitbar',true,'thin',2,...
       'draws',samplingDraws,'qFunction','arw','adaptive','recTarget',...
       'accTarget',0.23,'parallel',false,'chains',2,'storeAt',inf);
mp  = sample(mes,'draws',usedDraws,'sampler_options',opt);

toc

%% Trace plot and autocorrelation
% Using sampled draws

[~,plotter,pAutocorr] = checkPosteriors(mp);
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% Mean plot
% Using sampled draws

[res,plotter] = meanPlot(mp);
nb_graphSubPlotGUI(plotter);

[res,plotter] = meanPlot(mp,100);
nb_graphSubPlotGUI(plotter);

%% Geweke test
% Using sampled draws

res   = geweke(mp)
chain = 1;
res   = geweke(mp,chain)

%% Gelman Rubin test
% Using sampled draws

[res,plotter] = gelmanRubin(mp);
nb_graphSubPlotGUI(plotter);

%% Plot posteriors
% These plots are based only on randomly selected sample from all the 
% posterior draws. (Specified by the 'draws' option of the sample method!
% From now called "used draws")
%
% Using used draws

plotter = plotPosteriors(mp,'prior');
nb_graphMultiGUI(plotter);

%% IRF with probability bands
% Using used draws

mp               = set(mp,'silent',true);
[~,irfB,plotter] = irf(mp,'replic',1000);
nb_graphInfoStructGUI(plotter);

%% Posterior draws
% No U-turn sampler

tic

opt   = nb_mcmc.optimset('sampler','nutSampler','log',true,'waitbar',true,...
         'thin',2,'draws',2000,'accTarget',0.8,'parallel',false,'chains',1);
mpnut = sample(mes,'draws',1000,'sampler_options',opt);

toc

%% Trace plot and autocorrelation
% Using sampled draws

[~,plotter,pAutocorr] = checkPosteriors(mpnut);
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% Plot posteriors
% These plots are based only on the last posterior draws (specified by
% the draws option) 
%
% Using used draws

plotter = plotPosteriors(mpnut,'prior');
nb_graphMultiGUI(plotter);

%% Compare empirical and theoretical moments

type = 'calibrated';
if strcmpi(type,'calibrated')
    model = m;
else
    model = me;
end
model = solve(model);

[~,ct,ct1] = theoreticalMoments(model);
[~,ce,ce1] = empiricalMoments(model);

c  = interwine(ct,ce,' (empirical)');
c1 = interwine(ct1,ce1,' (empirical)');

