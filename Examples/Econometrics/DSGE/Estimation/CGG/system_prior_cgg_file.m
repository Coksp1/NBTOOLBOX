%% Help on this example

nb_dsge.help
help nb_dsge.estimate
help nb_dsge.setSystemPrior

%% NB Toolbox; Setup for estimation

doPlotting   = false;
simulateData = false;

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

% Simulate some data to estimate the model on
if simulateData
    m     = solve(m);
    dataM = simulate(m,100,'draws',1,'burn',100);
    data  = dataM.Model1;
    data  = tonb_ts(data,'2012Q1');
else
    data = nb_ts('cggData');
end
m = set(m,'data',data);

% Priors
priors         = struct();
priors.theta   = {0.5, 0.5,0.2,'beta'};
priors.varphi  = {0.8, 0.8,0.1,'normal'};
priors.phi     = {0.5, 0.5,0.2,'beta'};
priors.alpha   = {0.1,0,2}; % Uniform on 0 - 2!
priors.std_e   = {0.01,0.001,0.5};
priors.std_eps = {0.01,0.001,0.5};
priors.std_eta = {0.01,0.001,0.5};
m              = set(m,'prior',priors);

% Filtering options
m = set(m,...
'kf_init_variance', 10,...
'kf_presample',     5);

if doPlotting
    % This only plots the non-updated priors!
    plotter = plotPriors(m,'subplot');
    nb_graphSubPlotGUI(plotter);
end

% System priors specified in a m. file
%--------------------------------------
% ms = set(ms,'systemPrior',@momentPrior);
ms = set(ms,'systemPrior',@FEVDPrior);

%% Sample from the updated priors, 
% i.e. updated priors on the parameters given the system priors
%
% Caution: This is strictly not needed for estimation, but it gives you an
%          impression on the priors you actually are using. It also makes
%          it easy to compare posteriors to updated prior distributions!

tic

opt = nb_mcmc.optimset('log',true,'waitbar',true,'thin',2,...
       'draws',2000,'qFunction','arw','adaptive','recTarget',...
       'accTarget',0.23,'parallel',false,'chains',2);
msp = sampleSystemPrior(ms,'sampler_options',opt);

toc

%% Trace plot and autocorrelation
% Using sampled draws

[~,plotter,pAutocorr] = checkUpdatedPriors(msp);
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% Plot updated priors

plotter = plotUpdatedPriors(msp,'prior');
nb_graphMultiGUI(plotter);

%% Mean plot
% Using sampled draws

[res,plotter] = meanPlot(msp,[],'updated');
nb_graphSubPlotGUI(plotter);

[res,plotter] = meanPlot(msp,100,'updated');
nb_graphSubPlotGUI(plotter);

%% Geweke test
% Using sampled draws

res = geweke(msp,[],'updated')

%% Gelman Rubin test
% Using sampled draws

[res,plotter] = gelmanRubin(msp,'updated');
nb_graphSubPlotGUI(plotter);

%% NB Toolbox; Mode estimatation
% Standard

me = estimate(m);
me.print

% Solve the estimated version (This is not done in the estimate method!!)
mes = solve(me);

%% NB Toolbox; Mode estimation
% With system prior

mspe = estimate(ms);
mspe.print

% Solve the estimated version (This is not done in the estimate method!!)
mspes = solve(mspe);

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
       'accTarget',0.23,'parallel',false,'chains',1);
mp  = sample(mspes,'draws',usedDraws,'sampler_options',opt);

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

plotter = plotPosteriors(mp,'updated','prior');
nb_graphMultiGUI(plotter);

%% or

plotter = plotPosteriors(mp,'updated','prior','subplot');
nb_graphSubPlotGUI(plotter);


%% IRF with probability bands
% Using used draws

[~,irfB,plotter] = irf(mp,'replic',1000);
nb_graphInfoStructGUI(plotter);

