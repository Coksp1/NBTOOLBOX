%% Help on this example

nb_dsge.help('stochasticTrend')
help nb_dsge.irf

%% Parse model

rbcObs = nb_dsge('nb_file','rbc_obs.nb',...
                 'name','RBC OBS',...
                 'steady_state_file','rbc_steadystate',...
                 'stochasticTrend',true);
param  = rbc_param(2);
rbcObs = assignParameters(rbcObs,param);   

%% Solve model
% With observation model

rbcObs = solve(rbcObs);

%% Set the starting point of observation block

ss         = getSteadyState(rbcObs,'','struct');
c_share    = ss.c/ss.y;
i_share    = ss.i/ss.y;
init       = struct();
init.y_det = 1;
init.y_obs = init.y_det;
init.c_det = log(c_share) + init.y_det;
init.c_obs = init.c_det;
init.i_det = log(i_share) + init.y_det;
init.i_obs = init.i_det;
rbcObs     = set(rbcObs,'stochasticTrendInit',init);

%% Not-persistent shock processes

param.rho_i = 0;
param.rho_y = 0;
rbcObsNP    = assignParameters(rbcObs,param); 
rbcObsNP    = solve(rbcObsNP);
rbcObsNP    = set(rbcObsNP,'name','RBC OBS_NOT_PERSISTENT');

%% IRF

variables = {
'c'     
'c_hat' 
'dA'    
'k'     
'i'     
'i_hat' 
'r'     
'y'     
'y_hat' 
'z_c'   
'z_i'   
'z_y'   

% 'c_det'     
% 'c_noise'   
% 'c_obs'     
% 'c_star'    
% 'd_c_det'   
% 'd_c_star'  

% 'i_det'      
% 'i_noise'  
% 'i_obs'    
'i_star'    
% 'd_i_det'    
'd_i_star'  

% 'l_obs'  

% 'y_det'     
% 'y_noise'   
'y_obs'     
% 'y_star'   
% 'd_y_det'   
% 'd_y_star'

'c_share'
'i_share'
'c_obs_det'
'i_obs_det'
'y_obs_det'
};

[~,~,p] = irf([rbcObs,rbcObsNP],'shocks',{'e_i_star'},'variables',variables,...
                     'settings',{'subPlotSize',[4,3]});
nb_graphInfoStructGUI(p)
