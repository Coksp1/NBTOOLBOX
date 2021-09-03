function [ss,param] = rbc_steadystate(~,pp)
% Syntax:
%
% [ss,param] = rbc_steadystate(model,pp)
%
% Description:
%
% This is an example of a steady-state file.
% 
% Input:
% 
% - model : A struct containing information on the DSGE model. Relevant
%           fields:
%           > endogenous  : A cellstr storing the names of the endogenous 
%                           variables.
%           > isAuxiliary : A logical vector returning the auxiliary
%                           endogenous variables in endogenous.
%
% - pp    : A struct storing the parameters of the model. The fieldnames 
%           are the parameter names, while the field stores the values.
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
% nb_dsge.assignSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

    % If any parameters are solved for in the steady state they can be
    % returned by the param struct. struct('paramName',paramValue,...)
    param = struct();

    % Solve steady-state (This is the only part that needs to be changed)
    ss.r  = pp.g/pp.beta - 1;
    ss.k  = ((ss.r + pp.delta)/(1 - pp.gamma))^(-(1/pp.gamma))*pp.g;
    ss.y  = (ss.k/pp.g)^(1 - pp.gamma);
    ss.i  = (1 - (1 - pp.delta)/pp.g)*ss.k;
    ss.c  = ss.y - ss.i;
    
    ss.l  = 1;
    ss.dA = pp.g;
    
end