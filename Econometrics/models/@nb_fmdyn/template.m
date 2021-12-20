function options = template(num)
% Syntax:
%
% options = nb_fmdyn.template()
% options = nb_fmdyn.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_fmdyn
% class constructor.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Input:
%
% - num     : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                             = nb_model_generic.templateGeneral(num,'time-series');
    options.blocks                      = [];
    options.constant                    = 1;
    options.dependent                   = {};
    options.observables                 = {}; % Need to come before frequency and mapping
    options.doTests                     = 1;
    options.estim_method                = 'dfmeml';
    options.exogenous                   = {};
    options.factorRestrictions          = true;
    options.fix_point_maxiter           = 500;
    options.fix_point_TolFun            = 1e-04;
    options.fix_point_verbose           = false;
    options.frequency                   = {};
    options.initDiff                    = true;
    options.kf_presample                = 0;
    options.kf_kalmanTol                = eps;
    options.mapping                     = {};
    options.nFactors                    = 1;
    options.nLags                       = 1;
    options.nLagsIdiosyncratic          = 1;
    options.nLagsTests                  = 5;
    options.nonStationary               = false;
    options.prior                       = [];
    options.seasonalDummy               = '';
    options.time_trend                  = 0;
    options.transformation              = 'none';

end
