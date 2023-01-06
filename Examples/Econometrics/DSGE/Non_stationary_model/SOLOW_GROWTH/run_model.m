%% Parametrization

param        = struct( );
param.a      = 0.03;
param.alpha  = 0.6;
param.delta  = 0.1;
param.s      = 0.1;

%% Read the non-stationary model

modelNS = nb_dsge('nb_file','non_stationary.nb');
modelNS = set(modelNS,'name','Stationarize automatically');

%% Assign parameters

modelNS = assignParameters(modelNS,param); 

%% Solve for the balanced growth path

modelNS = solveBalancedGrowthPath(modelNS);

%% Stationarize the non-stationary model

modelNS = stationarize(modelNS);

%% Solve steady state numerically

modelNS = checkSteadyState(modelNS,...
    'solver','fsolve',...
    'steady_state_solve',true,...
    'steady_state_default', @ones);
ss = getSteadyState(modelNS)

%% Solve stationary model

modelNS = solve(modelNS);

%% IRFs

[irfs,~,plotter] = irf(modelNS,...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[4,3],...
                'figureTitle',false,'legends',{'AUTOMATIC STATIONARY'}});
nb_graphInfoStructGUI(plotter)
% nb_saveas(gcf,'irfs_nb','pdf','-noflip')

%% Write stationarized model to file

writeModel2File(modelNS,'stationarized.nb')

%% Read in the model again

modelW = nb_dsge('nb_file','stationarized.nb');
nb_loadWithName('stationarized_param.mat','paramS')
modelW = assignParameters(modelW,paramS);
modelW = set(modelW,...
    'name','Written model',...
    'solver','fsolve',...
    'steady_state_solve',true,...
    'steady_state_default', @ones);

%% Solve the written model

modelW = solve(modelW);

%% Compare IRFs

[~,~,plotter] = irf([modelNS,modelW],...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[4,3],...
                'figureTitle',false});
nb_graphInfoStructGUI(plotter)

%% Delete files

delete('stationarized.nb')
delete('stationarized_param.mat')
delete('stationarized_ss.mat')
