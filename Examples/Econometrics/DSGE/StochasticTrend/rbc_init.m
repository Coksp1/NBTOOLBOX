function init = rbc_init(pp)
% Syntax:
%
% init = rbc_steadystate(pp)
%
% Description:
%
% This is an example file to set the inital condition as a function of
% some parameters. Remember that only endogenous variables declared in
% observation model can be returned here (parser.obs_endogenous)
% 
% This function must be assign to the option stochasticTrendInit:
% obj = set(obj,'stochasticTrendInit','rbc_init');
%
% Input:
% 
% - pp    : A struct storing the parameters of the model. The fieldnames 
%           are the parameter names, while the field stores the values.
%
% Output:
% 
% - init : A struct storing the inital conditions. The names of the 
%          endogenous as fieldnames and the values as as the fields. 
%          E.g. init = struct('var_obs',pp.param1).
%
% See also:
% nb_dsge.assignSteadyState, nb_model_generic.getParameters
%
% Written by Kenneth Sæterhagen Paulsen

    init       = struct();
    init.c_det = pp.c_det_init;
    init.c_obs = pp.c_det_init;
    init.i_det = pp.i_det_init;
    init.i_obs = pp.i_det_init;
    init.y_det = pp.y_det_init;
    init.y_obs = pp.y_det_init;
    
end
