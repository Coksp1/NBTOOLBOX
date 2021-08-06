%% Help on this example

nb_dsge.help
help nb_dsge.estimate

%% Setup for estimation

plot = true;

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

% Simulate som data to estiamte the model on
m     = solve(m);
dataM = simulate(m,100,'draws',1,'burn',100);
data  = dataM.Model1;
data  = tonb_ts(data,'2012Q1');
m     = set(m,'data',data);

% Priors
clearvars priors
priors(3,1) = nb_distribution();
priors(1,1) = nb_distribution('type','normal','parameters',{1.2,0.2},...
                              'name','gamma_pie','userData',1.2);
                          
priors(2,1) = nb_distribution.parametrization(0.5,0.2^2,'beta');
set(priors(2,1),'name','gamma_i','userData',0.6);

priors(3,1) = nb_distribution('type','normal','parameters',{0.4,1},...
                              'name','gamma_y','userData',0.338);
m = set(m,'prior',priors);

% Filtering options
m = set(m,...
'kf_init_variance', [],...
'kf_presample',     5);

if plot
    plotter = plotPriors(m);
    nb_graphMultiGUI(plotter);
end

%% Mode estimatation

me = estimate(m);
me.print

% Solve the estimated version (This is not done in the estimate method!!)
mes = solve(me);

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
       'accTarget',0.23,'parallel',false,'chains',2);
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

res = geweke(mp)

%% Gelman Rubin test
% Using sampled draws

[res,plotter] = gelmanRubin(mp);
nb_graphSubPlotGUI(plotter);

%% Plot posteriors
% These plots are based only on the last posterior draws (specified by
% the draws option)
%
% Using used draws

plotter = plotPosteriors(mp,'prior');
nb_graphMultiGUI(plotter);

%% IRF with probability bands
% Using used draws

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
