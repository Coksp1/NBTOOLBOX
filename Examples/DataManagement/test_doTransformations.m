%% Help on the nb_arima class

help nb_ts.doTransformations

%% Simulate some ARIMA processes

rng(1) % Set seed

draws = randn(100,2);
sim1  = filter(1,[1,-0.9],draws(:,1)) + 2;  % AR(1)
sim2  = filter(1,[1,-0.95],draws(:,2)) + 2; % AR(1)

% Transform to nb_ts object
data = nb_ts([sim1,sim2],'','2000Q1',{'Sim1','Sim2'});
            
% Construct variable that are I(1) and merge with rest            
dataUR = undiff(data('Sim1'),100,1);
dataUR = rename(dataUR,'variables','Sim1','Sim3');
data   = merge(data,dataUR);

% Construct a gap measure
dataGap = hpfilter(log(data('Sim3')),1600);
dataGap = rename(dataGap,'variables','Sim3','Sim4');
data    = merge(data,dataGap);

% plot(data,'graphSubPlots');

%% De-trending the data

clc

expressions = {
    'Y1', 'Sim1',        {{'avg'},data.endDate,{'end'}},                                                '';
    'Y2', 'Sim2',        {{'hpfilter',1600,'randomwalk'},data.endDate,{'end'}},                         '';
    'Y3', 'Sim2',        {{'hpfilter',1600,'ar'},data.endDate,{'end'}},                                 '';
    'Y4', 'Sim2',        {{'linear','ar'},data.endDate,{'end'}},                                        '';
    'Y5', 'log(Sim3)',   {{'hpfilter',1600},data.endDate,{'endgrowth'}},                                '';
    'Y6', 'log(Sim3)',   {{'hpfilter',1600},data.endDate,{'M2T','ar','avg',0.7}},                       '';
    'Y7', 'log(Sim3)',   {{'hpfilter',1600},data.endDate,{'M2T','int','avg'}},                          '';
    'Y8', 'log(Sim3)',   {{'hpfilter',1600,'randomwalkgrowth'},data.endDate,{'endgrowth'}},             '';
    'Y9', 'log(Sim3)',   {{'hpfilter',1600,'randomwalkgrowth'},data.endDate,{'endgrowth'}},             '';
    'Y10','log(Sim3)',   {{'bkfilter',4,32,'randomwalkgrowth'},data.endDate,{'endgrowth'}},             '';
    'Y11','log(Sim3)',   {{'hpfilter',1600,'argrowth'},data.endDate,{'endgrowth'}},                     '';
    'Y12','Sim1',        {{'constant',2},data.endDate,{'end'}},                                         '';
    'Y13','Sim1',        {{'constant',2},'2011Q2',{'int',2,3},'2012Q2',{'end'}},                        '';
    'Y14','Sim4',        {{'FGTS','log(Sim3)'},data.endDate,{'M2T','ar','avg',0.7}},                    '';
    'Y15','log(Sim3)',   {{'mavg',20,0},data.endDate,{'endgrowth'}},                                    '';
    'Y16','log(Sim3)',   {{'mavg',10,10,'argrowth'},data.endDate,{'endgrowth'}},                        '';
    'Y17','log(Sim3)-mavg(log(Sim3),20,0)', {{'avg'},data.endDate,{'end'}},                             '';
    'Y18','Sim2',        {{'hpfilter',1600,@(x)nb_mavg(x,2,0)},data.endDate,{'end'}},                   '';
};

[out,shift,plotter] = doTransformations(data,expressions,6);
nb_graphInfoStructGUI(plotter)
