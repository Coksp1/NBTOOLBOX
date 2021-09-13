%% Help on this example

nb_dsge.help
help nb_dsge.perfectForesight

%% Parse linear model

ml = nb_dsge('nb_file','model_JPR_linear.nb',...
             'macroProcessor',true,'name','linear');

%% Assign parameters

param      = load('parametersJPR_NB.mat');
param.ssQ  = (param.epsilon_f - 1)/(param.epsilon_f);
param.ssCF = 1/(param.alpha/(1 - param.alpha) + (param.epsilon_f - 1)/param.epsilon_f);
ml         = assignParameters(ml,param);

%% Solve steady-state

ml = checkSteadyState(ml);
ss = ml.getSteadyState()

%% Solve the model

ml = solve(ml);

%% Parse linear model
% Gabaix discounting (phillips curves)

mlg = nb_dsge('nb_file','model_JPR_linear_gabaix.nb',...
             'macroProcessor',true,'name','linear (Gabaix)');

%% Assign parameters

param        = load('parametersJPR_NB.mat');
param.ssQ    = (param.epsilon_f - 1)/(param.epsilon_f);
param.ssCF   = 1/(param.alpha/(1 - param.alpha) + (param.epsilon_f - 1)/param.epsilon_f);
param.gabaix = 0.8;
mlg          = assignParameters(mlg,param);

%% Solve steady-state

mlg = checkSteadyState(mlg);
ss  = mlg.getSteadyState()

%% Solve the model

mlg = solve(mlg);

%% Parse non-linear model

mnl = nb_dsge('nb_file','model_JPR_nonLinear.nb',...
              'macroProcessor',true,'name','linearized',...
              'steady_state_file','model_JPR_nonLinear_steadystate');

%% Assign parameters

param              = load('parametersJPR_NB.mat');
param.epsilon_h_ss = param.epsilon_h;
param.epsilon_f_ss = param.epsilon_f;
param.epsilon_w_ss = param.epsilon_w;
param              = rmfield(param,{'epsilon_h','epsilon_f','epsilon_w'});
mnl                = assignParameters(mnl,param);

%% Solve steady-state

mnl = checkSteadyState(mnl,'steady_state_debug',true);
ss  = mnl.getSteadyState()

%% Solve the model

mnl = solve(mnl);

%% Parse non-linear model
% Gabaix discounting (phillips curves)

mnlg = nb_dsge('nb_file','model_JPR_nonLinear_gabaix.nb',...
               'macroProcessor',true,'name','linearized (Gabaix)',...
               'steady_state_file','model_JPR_nonLinear_steadystate');

%% Assign parameters

param              = load('parametersJPR_NB.mat');
param.epsilon_h_ss = param.epsilon_h;
param.epsilon_f_ss = param.epsilon_f;
param.epsilon_w_ss = param.epsilon_w;
param              = rmfield(param,{'epsilon_h','epsilon_f','epsilon_w'});
param.gabaix       = 0.8;
mnlg               = assignParameters(mnlg,param);

%% Solve steady-state

mnlg = checkSteadyState(mnlg,'steady_state_debug',true);
ss   = mnlg.getSteadyState()

%% Solve the model

mnlg = solve(mnlg);

%% Parse non-linear model
% Gabaix discounting (all)

mnlga = nb_dsge('nb_file','model_JPR_nonLinear.nb',...
                'macroProcessor',true,'name','linearized (Gabaix all)',...
                'steady_state_file','model_JPR_nonLinear_steadystate',...
                'discount',struct('eq','all','value',0.8,'name',''));

%% Assign parameters

param              = load('parametersJPR_NB.mat');
param.epsilon_h_ss = param.epsilon_h;
param.epsilon_f_ss = param.epsilon_f;
param.epsilon_w_ss = param.epsilon_w;
param              = rmfield(param,{'epsilon_h','epsilon_f','epsilon_w'});
mnlga              = assignParameters(mnlga,param);

%% Solve steady-state

mnlga = checkSteadyState(mnlga,'steady_state_debug',true);
ss    = mnlga.getSteadyState()

%% Solve the model

mnlga = solve(mnlga);

%% IRF

[~,~,p] = irf([ml,mlg,mnl,mnlg,mnlga],'shocks',{'e_z'},'variables',{'i','r','pi','y'});
nb_graphInfoStructGUI(p);

