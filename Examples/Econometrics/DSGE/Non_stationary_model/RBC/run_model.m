%% Parametrization

param        = struct( );
param.g      = 1.03;
param.gamma  = 0.60;
param.delta  = 0.10;
param.beta   = 0.97;
param.lambda = 0;
param.std_u  = 0.01;

%% Read the stationary model

modelS = nb_dsge('nb_file','stationary.nb');
modelS = set(modelS,'name','Stationarize manually');

%% Assign parameters

modelS  = assignParameters(modelS,param); 

%% Solve steady state numerically

modelS = checkSteadyState(modelS,...
    'solver',               'fsolve',...
    'steady_state_solve',   true,...
    'steady_state_default', @ones);
ss = getSteadyState(modelS)

%% Solve steady state analytically

modelTemp = checkSteadyState(modelS,...
    'steady_state_file',    'rbc_steadystate',...
    'steady_state_solve',   false);
ss = getSteadyState(modelTemp)

%% Solve stationary model

modelS = solve(modelS);

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

%% Test re-solving after parameter change

modelNSC = assignParameters(modelNS,param); 
modelNSC = solve(modelNSC);

%% IRFs

[irfs,~,plotter] = irf([modelNS,modelS],...
    'variables',[modelNS.dependent.name(1:7),modelNS.reporting(1:5,1)'],...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[4,3],...
                'figureTitle',false,'legends',{'AUTOMATIC STATIONARY',...
                'MANUAL  STATIONARY'}});
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
    'variables',[modelNS.dependent.name(1:7),modelNS.reporting(1:5,1)'],...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[4,3],...
                'figureTitle',false});
nb_graphInfoStructGUI(plotter)

%% Delete files

delete('stationarized.nb')
delete('stationarized_param.mat')
delete('stationarized_ss.mat')
