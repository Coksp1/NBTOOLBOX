function [ss,param,retcode] = model_JPR_nonLinear_steadystate(model,input1)
% Syntax:
%
% [ss,param,retcode] = model_JPR_nonLinear_steadystate(model,input1)
%
% Description:
%
% This is an example of a steady-state file for solving the non-linear 
% version of Justiniano & Preston (2010) with Rotemberg and local currency 
% export price setting that can be used by both dynare and NB Toolbox.
% 
% Input:
% 
% > NB Toolbox:
%
% - model  : A struct containing information on the DSGE model. Relevant
%            fields:
%            > endogenous  : A cellstr storing the names of the endogenous 
%                            variables.
%            > isAuxiliary : A logical vector returning the auxiliary
%                            endogenous variables in endogenous.
%
% - input1 : A struct storing the parameters of the model. The fieldnames 
%            are the parameter names, while the field stores the values.
%
% > Dynare:
%
% - model  : A nEndo x 1 double with zeros, i.e. the ss values to be filled
%            in for.
%
% - input1 : A nExo x 1 double with zeros, i.e. the ss values of the
%            exogenous variables.
%
% Output:
% 
% > NB Toolbox:
%
% - ss    : A struct with the endogenous variable names as fieldnames and
%           the steady-state value as its fields.
%
% - param : A struct storing the solution of parameters solved for in
%           steady-state. The names of the parameters as fieldnames and
%           the found values as as the fields. E.g. param = struct('p',2).
%
% > Dynare:
%
% - ss      : A nEndo x 1 double with the steady-state values of the model.
%
% - param   : Allways 0 if success.
%
% - retcode : 1 if somethings does not work.
%
% Written by Kenneth Sæterhagen Paulsen

if nargin == 0
    model = nan; % Just to trigger dynare
end

retcode = false;
if isnumeric(model) % Then we are dealing with dynare

    % We need to declare some dynare variables as global
    %------------------------------------------------------------------
    global M_ options_ %#ok<TLEV> %oo_

    % We need to get the parameters of the model to be able to solve 
    % the steady state
    %_-----------------------------------------------------------------
    for j = 1:M_.param_nbr
        pname = deblank(M_.param_names(j,:));
        eval([pname,'=M_.params(j);'])
    end
    toolbox = 0;
    
else % NB Toolbox
    
    % We need to get the parameters of the model to be able to solve
    % the steady state
    %------------------------------------------------------------------
    pnames = fieldnames(input1);
    parnr  = length(pnames);
    for j = 1:parnr
       pname = deblank(pnames{j});
       eval([pname,' = input1.(pname);'])
    end
    toolbox = 2;
    alpha   = input1.alpha; % To prevent MATLAB from calling the alpha function!
    
end

%##

%==================================================================
% Enter model equations here
%==================================================================

%%%%%%%%%%%%%%%%%%%%% Gaps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0; %log((1+R)/(1+steady_state(R)));
i = 0; %log((1+I)/(1+steady_state(I)));
pi = 0; %log(PI/steady_state(PI));
pih = 0; %log(PIH/steady_state(PIH));
pih_index = 0; %log(PIH_INDEX/steady_state(PIH_INDEX));
pif = 0; %log(PIF/steady_state(PIF));
pif_index = 0; %log(PIF_INDEX/steady_state(PIF_INDEX));
piw = 0; %log(PIW/steady_state(PIW));
piw_index = 0; %log(PIW_INDEX/steady_state(PIW_INDEX));
pf = 0; %log(PF/steady_state(PF));
ph = 0; %log(PH/steady_state(PH));
mc = 0; %log(MC/steady_state(MC));
a = 0; %log(A /steady_state(A));
w = 0; %log(W/steady_state(W));
n = 0; %log(N/steady_state(N));
y = 0; %log(Y /steady_state(Y));
yf = 0; %log(YF/steady_state(YF));
gammahw = 0; %log(GAMMAHW/steady_state(GAMMAHW));
gammaf = 0; %log(GAMMAF/steady_state(GAMMAF));
lambda = 0; %log(LAMBDA/steady_state(LAMBDA));
c = 0; %log(C/steady_state(C));
d = 0; %log(D/steady_state(D));
psi = 0; %log(PSI/steady_state(PSI));
ch = 0; %log(CH/steady_state(CH));
cf = 0; %log(CF/steady_state(CF));
ch_star = 0; %log(CH_STAR/steady_state(CH_STAR));
q = 0; %log(Q/steady_state(Q));
bf = 0; %log(BF/steady_state(BF));
bf_bar = 0; %log(BF_BAR/steady_state(BF_BAR));
rp = 0; %log(RP/steady_state(RP));
rp_shock = 0; %log(RP_SHOCK/steady_state(RP_SHOCK));
z = 0; %log(Z/steady_state(Z));
muh = 0;
muf = 0;
muw = 0;

% Foreign variables
r_star = 0; %log(R_STAR/steady_state(R_STAR));
i_star = 0; %log(I_STAR/steady_state(I_STAR));
pi_star = 0; %log(PI_STAR/steady_state(PI_STAR));
lambda_star = 0; %log(LAMBDA_STAR/steady_state(LAMBDA_STAR));
c_star = 0; %log(C_STAR/steady_state(C_STAR));
n_star = 0; %log(N_STAR/steady_state(N_STAR));
w_star = 0; %log(W_STAR/steady_state(W_STAR));
mc_star = 0; %log(MC_STAR/steady_state(MC_STAR));
y_star = 0; %log(Y_STAR/steady_state(Y_STAR));
gamma_star = 0; %log(GAMMA_STAR/steady_state(GAMMA_STAR));
a_star = 0; %log(A_STAR/steady_state(A_STAR));
z_star = 0; %log(Z_STAR/steady_state(Z_STAR));
d_star = 0;

%%%%%%%%%%%%%%%%%%%%% Domestic economy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epsilon_h = epsilon_h_ss;
epsilon_f = epsilon_f_ss;
epsilon_w = epsilon_w_ss;
MUH       = epsilon_h/(epsilon_h - 1);
MUF       = epsilon_f/(epsilon_f - 1);
MUW       = epsilon_w/(epsilon_w - 1);

N = 1;
A = 1;
PI = 1;
Z = 1;
D = 1;
PH = 1;
PIF = PI;
PIH = PI;
PIW = PI;
PIF_INDEX = PI;
PIH_INDEX = PI;
PIW_INDEX = PI;

GAMMAHW = 1/(1 - (rch/2)*(PIH - 1)^2 - (rcw/2)*(PIW - 1)^2);
GAMMAF = 1/(1 - (rcf/2)*(PIF - 1)^2);
Y = A*N;
MC = (epsilon_h-1)/epsilon_h + (1-betta)*(rch/epsilon_h)*(PIH/PIH_INDEX-1)*(PIH/PIH_INDEX);
W = MC*PH*A;

if eta==1
    PF = PH^(alpha/(1-alpha));
else
    PF = ((1-alpha*PH^(1-eta))/(1-alpha))^(1/(1-eta));
end

Q = (epsilon_f-1)/epsilon_f*PF + (1-betta)*PF*(rcf/epsilon_f)*(PIF/PIF_INDEX-1)*(PIF/PIF_INDEX);

C = Y/(GAMMAHW*(alpha*PH^(-eta)+(Q/PH)*GAMMAF*(1-alpha)*PF^(-eta)));
CH = alpha*PH^(-eta)*C;
CF = (1-alpha)*PF^(-eta)*C;
CH_STAR = (Q/PH)*GAMMAF*CF;
YF = GAMMAF*CF;
LAMBDA = ((1 - h)*C)^(-sigma)*D;
PSI = ((epsilon_w - 1)/epsilon_w)*(LAMBDA*W)/(D*N^(phi));

R = 1/betta - 1;
I = PI*(1+R) - 1;

%%%%%%%%%%%%%%%%%%%%% Foreign economy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_STAR = 1;
N_STAR = 1000;
Z_STAR = 1;
D_STAR = 1;
PI_STAR = 1;
R_STAR = 1/betta_star - 1;
I_STAR = PI_STAR*(1 + R_STAR) - 1;
GAMMA_STAR = 1/(1 - (rc_star/2)*(PI_STAR - 1)^2);
Y_STAR = A_STAR*N_STAR;
C_STAR = Y_STAR/GAMMA_STAR;
LAMBDA_STAR = C_STAR^(-sigma_star);
MC_STAR = (epsilon_star - 1)/epsilon_star + (1-betta_star)*(rc_star/epsilon_star)*(PI_STAR - 1)*PI_STAR;
W_STAR = A_STAR*MC_STAR;
psi_star = LAMBDA_STAR*(W_STAR/N_STAR^phi_star);
alpha_star = 1 - CH_STAR/((PH/Q)^(-eta_star)*C_STAR);

%%%%%%%%%%%%%%%%%%%%% Risk premium and net foreign assets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RP = 1/(betta*(1 + R_STAR));
BF = 0;
BF_BAR = Q*BF/CF;
RP_SHOCK = -(log(RP)/chi) - BF_BAR;

%==================================================================
% Assign the steady state variables
%==================================================================

%##

if toolbox == 0 % Dynare

    if isfield(M_,'orig_model')
        my_endo_nbr = M_.orig_model.orig_endo_nbr;
        mylist      = M_.orig_model.endo_names;
    else
        my_endo_nbr = M_.orig_endo_nbr;
        mylist      = M_.endo_names;
    end

    param = 0; % This is what needs to be returned by when dealing with Dynare
    if isfield(options_,'ReestimateTheSteadyState') && options_.ReestimateTheSteadyState == 0
        ss = options_.ys;
        return
    end

    ss   = nan(my_endo_nbr,1);
    list = [];
    for j=1:my_endo_nbr
        try
            ss(j) = eval(mylist(j,:)); % <--- ys(j)=eval(M_.endo_names(j,:));
        catch
            list = [list,j]; %#ok<AGROW>
        end
    end

    if ~isempty(list)
        disp(mylist(list,:))
        error('The list above are not assign a steady-state')
    end 
    
else % If NB Toolbox
    
    mylist      = model.endogenous(~model.isAuxiliary);
    my_endo_nbr = length(mylist);
    for j = 1:my_endo_nbr
        try
            ss.(mylist{j}) = eval(mylist{j});
        catch
            warning('NB:steadyStateWaning',['The variable ' mylist{j} 'is not assign a',...
                    'value by the steady-state file. Assume a value of 0.'])
        end
    end
    
    % Parameters solved for in the steady-state file
    param = struct('psi_star',psi_star,'alpha_star',alpha_star);  
    
end
