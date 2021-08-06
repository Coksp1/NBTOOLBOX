%% Parametrization

param = load('jpt_coeff');

%% Read the non-stationary model

modelNS = nb_dsge('nb_file','jpt_non_stationary.nb');
modelNS = set(modelNS,'name','JPT with investment specific technology');

%% Assign parameters

modelNS = assignParameters(modelNS,param); 

%% Solve for the balanced growth path

modelNS  = solveBalancedGrowthPath(modelNS);

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

%% Solve stationary model

modelNS = solve(modelNS);

%% Parametrization

paramP = load('jpt_coeff_pref');

%% Read the non-stationary model

modelNSPref = nb_dsge('nb_file','jpt_non_stationary_pref.nb');
modelNSPref = set(modelNSPref,'name','JPT with unit root in preferences');

%% Assign parameters

modelNSPref = assignParameters(modelNSPref,paramP); 

%% Solve for the balanced growth path

modelNSPref = solveBalancedGrowthPath(modelNSPref);

%% Stationarize the non-stationary model

modelNSPref = stationarize(modelNSPref);

%% Solve steady-state numerically

ssInit = struct(...
    'GAMMA_W_NW',0,...
    'PSI_NW',paramP.PSI_NW_SS,...
    'S_NW',0,...
    'S_PRIME1_NW',0,...
    'S_PRIME2_NW',0,...
    'GAMMA_U_NW',0,...
    'THETAH_NW',paramP.THETAH_NW_SS);

modelNSPref = checkSteadyState(modelNSPref,...
    'solver',               'fsolve',...
    'steady_state_solve',   true,...
    'steady_state_init',    ssInit,...
    'steady_state_default', @ones);

%% Solve stationary model

modelNSPref = solve(modelNSPref);

%% Compare balanced growth paths

ssGrowth    = getBalancedGrowthPath([modelNS,modelNSPref],...
    {'C_NW','I_NW','K_NW','L_NW','NAT_Y_NW','REAL_W_NW','REAL_PI_NW'},...
     'headers')

% ssGrowthOut = nb_cell(ssGrowth);
% ssGrowthOut.writeTex('bgp_table','colors',0,'precision','%.4f')
 
%% Compare steady state results

ss = getSteadyState([modelNS,modelNSPref],...
    {'C_NW','DPQ_P_NW','DPQ_W_NW','I_NW','K_NW',...
     'L_NW','NAT_Y_NW','RN3M_NW'},...
     'headers')

% ssOut = nb_cell(ss);
% ssOut.writeTex('ss_table','colors',0,'precision','%.4f')

%% Theoretical moments

vars = {'C_NW','DPQ_P_NW','DPQ_W_NW','I_NW','K_NW',...
        'L_NW','NAT_Y_NW','RN3M_NW'};

[~,CNS] = theoreticalMoments(modelNS,'vars',vars,'type','covariance');
VNS     = diag(CNS)';
VNS     = rename(VNS,'variable','diag',getName(modelNS));

[~,CNSPref] = theoreticalMoments(modelNSPref,'vars',vars,...
                'type','covariance');
VNSPref     = diag(CNSPref)';
VNSPref     = rename(VNSPref,'variable',...
    'diag',getName(modelNSPref));

% V = [VNS,VNSPref]
% V.writeTex('var_table','colors',0,'precision','%.4f')
