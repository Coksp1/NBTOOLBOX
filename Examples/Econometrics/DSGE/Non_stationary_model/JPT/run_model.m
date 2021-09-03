%% Parametrization

param = load('jpt_coeff');
% param = load('nb_jpt_coeff');

%% Read the stationary model

modelS = nb_dsge('nb_file','jpt.nb');
modelS = set(modelS,'name','Stationarize JPT manually');

%% Assign parameters

modelS  = assignParameters(modelS,param); 

%% Solve steady-state numerically

ssInit = struct(...
    'GAMMA_W_NW',0,...
    'PSI_NW',param.PSI_NW_SS,...
    'S_NW',0,...
    'S_PRIME1_NW',0,...
    'S_PRIME2_NW',0,...
    'GAMMA_U_NW',0,...
    'THETAH_NW',param.THETAH_NW_SS);

modelS = checkSteadyState(modelS,...
    'solver',               'fsolve',...
    'steady_state_default', @ones,...
    'steady_state_init',    ssInit,...
    'steady_state_solve',   true);
ss = getSteadyState(modelS)

%% Solve stationary model

modelS = solve(modelS);

%% Read the non-stationary model

modelNS = nb_dsge('nb_file','jpt_non_stationary.nb');
modelNS = set(modelNS,'name','Stationarize JPT automatically');

%% Assign parameters

modelNS = assignParameters(modelNS,param); 

%% Solve for the balanced growth path

modelNS  = solveBalancedGrowthPath(modelNS);
ssGrowth = getBalancedGrowthPath(modelNS)

%% Stationarize the non-stationary model

modelNS = stationarize(modelNS);

%% Solve steady-state numerically

ssInit = struct(...
    'GAMMA_W_NW',0,...
    'PSI_NW',param.PSI_NW_SS,...
    'S_NW',0,...
    'S_PRIME1_NW',0,...
    'S_PRIME2_NW',0,...
    'GAMMA_U_NW',0,...
    'THETAH_NW',param.THETAH_NW_SS);

modelNS = checkSteadyState(modelNS,...
    'solver',               'fsolve',...
    'steady_state_solve',   true,...
    'steady_state_init',    ssInit,...
    'steady_state_default', @ones);
ss = getSteadyState(modelNS)

%% Solve stationary model

modelNS = solve(modelNS);

%% IRFs

[~,~,plotter] = irf([modelNS,modelS],...
    'periods',  100,...
    'plotSS',   true,...
    'shocks',   {'E_DUT_NW'},...
    'variables',{'C_NW','DPQ_P_NW','DPQ_W_NW','I_NW','K_NW',...
                 'L_NW','NAT_Y_NW','RN3M_NW','C_NW_LEVEL','I_NW_LEVEL',...
                 'K_NW_LEVEL','Y_NW_LEVEL'},...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[4,3],...
                'figureTitle',false,'lookUpMatrix','lookUpMatrixJPT',...
                'spacing',20,...
                'legends',{'AUTOMATIC STATIONARY',...
                           'MANUAL  STATIONARY',...
                           '',...
                           'Steady-state'}});
nb_graphInfoStructGUI(plotter)
% nb_saveas(gcf,'jpt_irfs_nb','pdf','-noflip');

%% Write stationarized model to file

writeModel2File(modelNS,'stationarized.nb')

%% Read in the model again

modelW = nb_dsge('nb_file','stationarized.nb');
nb_loadWithName('stationarized_param.mat','paramS')
modelW = assignParameters(modelW,paramS);
nb_loadWithName('stationarized_ss.mat','ssInit')
modelW = set(modelW,...
    'name',                 'Written model',...
    'steady_state_init',    ssInit,...
    'steady_state_solve',   true,...
    'steady_state_default', @ones);

%% Solve the written model

modelW = solve(modelW);

%% Compare IRFs

[~,~,plotter] = irf([modelNS,modelW],...
    'periods',  60,...
    'plotSS',   true,...
    'shocks',   {'E_DUT_NW'},...
    'variables',{'C_NW','DPQ_P_NW','DPQ_W_NW','I_NW','K_NW',...
                 'L_NW','NAT_Y_NW','RN3M_NW'},...
    'settings',{'legBox','off','legFontSize',18,'subPlotSize',[3,3],...
                'figureTitle',false,'lookUpMatrix','lookUpMatrixJPT',...
                'legends',{'Stationarize JPT automatically',...
                           'Written JPT model',...
                           '',...
                           'Steady-state'}});
nb_graphInfoStructGUI(plotter)

%% Delete files

delete('stationarized.nb')
delete('stationarized_param.mat')
delete('stationarized_ss.mat')
