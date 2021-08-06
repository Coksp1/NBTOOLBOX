function [C,Ceq] = constraints(pars,constrFuncEq,constrFuncIneq,varargin)
% Syntax:
%
% [C,Ceq] = nb_model_parse.constraints(pars,constrFuncEq,constrFuncIneq,
%                   varargin)
%
% Description:
%
% Function that will be converted into a function handle during estimation
% when parameter constraints are added.
% 
% Input:
%
% - pars           : The current values of the parameters.
%
% - constrFuncEq   : A function handle, which is constructed in 
%                    nb_model_parse.constraints2func, that evaluate the
%                    equality constraints on the parameters.
%
% - constrFuncIneq : A function handle, which is constructed in 
%                    nb_model_parse.constraints2func, that evaluate the
%                    inequality constraints on the parameters.
%
% Output:
%
% - C   : The value of the evaluated inequality constraints. Parameter 
%         values are feasible as long as all(C <= 0).
%
% - Ceq : The value of the evaluated equality constraints. Parameter 
%         values are feasible as long as all( abs(Ceq) < eps), for some 
%         small eps.
%
% See also:
% nb_model_parse.constraints2func
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    C   = constrFuncIneq(pars);
    Ceq = constrFuncEq(pars);
    
end
