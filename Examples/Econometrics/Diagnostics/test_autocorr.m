%% Generate artificial data

rng(1); % Set seed

draws = randn(100,1);
sim1  = filter(1,[1,-0.5],draws);
sim2  = filter([1,0.5],1,draws);
sim   = [sim1,sim2];

data = nb_ts(sim,'','2012Q1',{'AR','MA'});

%% Autocorr and partial autocorr

acf     = autocorr(data,5,'asymptotic');
plotter = acf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);
 
acf     = autocorr(data,5,'bootstrap');
plotter = acf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);

acf     = autocorr(data,5,'rBlockBootstrap');
plotter = acf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);

acf     = autocorr(data,5,'copulaBootstrap');
plotter = acf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);

pacf    = parcorr(data,5,'asymptotic');
plotter = pacf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);

pacf    = parcorr(data,5,'bootstrap');
plotter = pacf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);

pacf    = parcorr(data,5,'blockbootstrap');
plotter = pacf.plot('graphSubPlots');
nb_graphSubPlotGUI(plotter);
