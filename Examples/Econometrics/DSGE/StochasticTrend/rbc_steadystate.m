function [ss,param] = rbc_steadystate(~,pp,obs)
% Syntax:
%
% [ss,param] = rbc_steadystate(parser,pp,obs)
%
% Description:
%
% This is an example of a steady-state file.
% 
% Input:
% 
% - parser : A struct containing information on the DSGE model. Relevant
%            fields:
%            > endogenous  : A cellstr storing the names of the endogenous 
%                            variables.
%            > isAuxiliary : A logical vector returning the auxiliary
%                            endogenous variables in endogenous.
%
% - pp     : A struct storing the parameters of the model. The fieldnames 
%            are the parameter names, while the field stores the values.
%
% - obs    : A struct with the lagged values of the endogenous variables 
%            of the model. The fieldnames are the parameter names, while 
%            the field stores the values.
%
% Output:
% 
% - ss    : See the s input to the nb_dsge.assignSteadyState method.
%
% - param : A struct storing the solution of parameters solved for in
%           steady-state. The names of the parameters as fieldnames and
%           the found values as as the fields. E.g. param = struct('p',2).
%
% See also:
% nb_dsge.assignSteadyState, nb_model_generic.getParameters
%
% Written by Kenneth Sæterhagen Paulsen

    param = struct();

    if nargin == 2
        
        % This part is used for solving the initial steady-state of the
        % model
        %------------------------------------------------------------------
    
        % Solve steady-state
        ss.r   = pp.y_growth/pp.beta - 1;
        ss.k   = ((ss.r + pp.delta)/(1 - pp.alpha))^(-(1/pp.alpha))*pp.y_growth;
        ss.y   = (ss.k/pp.y_growth)^(1 - pp.alpha);
        ss.i   = (1 - (1 - pp.delta)/pp.y_growth)*ss.k;
        ss.z_y = 0.2;
        ss.c   = ss.y - ss.i - ss.z_y;
        ss.dA  = pp.y_growth; 

    else
        
        % This part is used for solving the steady-state of the model
        % along the stochastic trend
        %------------------------------------------------------------------
        
        % Shares used for re-calculation of steady-state
        i_share = exp(obs.i_star + obs.i_det - obs.y_star - obs.y_det);
        c_share = exp(obs.c_star + obs.c_det - obs.y_star - obs.y_det);

        % Solve steady-state
        ss.dA  = pp.y_growth; 
        ss.r   = pp.y_growth/pp.beta - 1;
        ss.k   = ((ss.r + pp.delta)/(1 - pp.alpha))^(-(1/pp.alpha))*pp.y_growth;
        ss.y   = (ss.k/pp.y_growth)^(1 - pp.alpha);
        ss.z_i = log((1 - (1 - pp.delta)/ss.dA)*(ss.k/ss.y)*(1/i_share)); % Permanent investment technology shock
        ss.z_y = ss.y*(1 - c_share - i_share);     % Permanent inventory shock
        ss.i   = i_share*ss.y;
        ss.c   = c_share*ss.y;
        
    end
    
end
