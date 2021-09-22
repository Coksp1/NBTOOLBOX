%% Parametrization

param            = struct( );
param.beta       = 0.97;
param.delta      = 0.10;
param.delta_a    = 0.10;
param.g          = -0.5;
param.gamma      = 0.60;
param.lambda_srd = 0.5;
param.srd_ss     = 0.05;
param.std_e      = 0.1;
param.std_u      = 0.001;
param.theta      = 0.1;
param.zeta       = 1.1;

%% Read the stationary model

modelS = nb_dsge('nb_file','stationary.nb');
modelS = set(modelS,'name','Stationarize manually');

%% Assign parameters

modelS  = assignParameters(modelS,param); 

%% Solve steady-state numerically using a provided guess

modelS = checkSteadyState(modelS,...
    'steady_state_file',    'rbc_steadystate',...
    'steady_state_change',  {'g','dA'},...
    'steady_state_solve',   true);
ss      = getSteadyState(modelS)
paramSS = getParameters(modelS)

%% Solve stationary model

modelS = solve(modelS);

%% Read the non-stationary model

modelNS = nb_dsge('nb_file','non_stationary.nb');
modelNS = set(modelNS,'name','Stationarize automatically');

%% Assign parameters

modelNS = assignParameters(modelNS,param); 

%% Solve for the balanced growth path

modelNS  = solveBalancedGrowthPath(modelNS);

%% Stationarize the non-stationary model

modelNS = stationarize(modelNS);

%% Solve steady-state numerically

init    = struct('dA',1.03);
modelNS = checkSteadyState(modelNS,...
    'solver','fsolve',...
    'steady_state_change',  {'g','dA'},...
    'steady_state_init',  init,...
    'steady_state_solve',true,...
    'steady_state_default', @ones);
ss  = getSteadyState(modelNS)
bgp = getBalancedGrowthPath(modelNS)

%% Solve stationary model

modelNS = solve(modelNS);

%% IRFs

vars             = {'c','dA','i','k','r','s','srd','y'};   
[irfs,~,plotter] = irf([modelNS,modelS],...
    'variables',[vars,modelNS.reporting(1:6,1)'],...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[5,3],...
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
