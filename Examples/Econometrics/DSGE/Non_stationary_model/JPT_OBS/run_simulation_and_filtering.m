%% Parametrization

param = load('jpt_coeff');
% param = load('nb_jpt_coeff');

%% Read the non-stationary model

modelNS = nb_dsge('nb_file','jpt_non_stationary_obs.nb');
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

%% Write stationarized model to file

writeModel2File(modelNS,'stationarized_obs.nb')

%% Delete files

delete('stationarized_obs.nb')
delete('stationarized_obs_param.mat')
delete('stationarized_obs_ss.mat')
