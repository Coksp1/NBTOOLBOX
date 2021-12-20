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
% nb_dsge.assignSteadyState, nb_model_generic.getParameters
%
% Written by Kenneth Sæterhagen Paulsen

    param = struct();

    % Solve steady-state (This is the only part that needs to be changed)
    ss.a = 0;
    ss.k = (1/(pp.beta*pp.alpha) - (1 - pp.delta)/pp.alpha)^(1/(pp.alpha - 1));
    ss.y = ss.k^pp.alpha;
    ss.i = pp.delta*ss.k;
    ss.c = ss.y - ss.i;
    
end
