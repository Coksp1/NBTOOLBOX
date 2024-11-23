function options = template(num)
% Syntax:
%
% options = nb_favar.template()
% options = nb_favar.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_favar
% class constructor.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Input:
%
% - num : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                             = nb_model_generic.templateGeneral(num,'time-series');
    options.constant                    = 1;
    options.criterion                   = '';
    options.dependent                   = {};
%     options.draws                       = 1000;
    options.estim_method                = 'fm';
    options.exogenous                   = {};
    options.factorsCriterion            = 7;
    options.doTests                     = 1;
    options.maxLagLength                = 10;
    options.missingMethod               = '';
    options.modelSelection              = '';
    options.nFactors                    = [];
    options.nFactorsMax                 = [];
    options.nLags                       = 1;
    options.nLagsTests                  = 5;
    options.observables                 = {};
    options.observablesFast             = {};
%     options.prior                       = [];
    options.seasonalDummy               = '';
    options.stdReplic                   = 1000;
    options.stdType                     = 'h';
    options.time_trend                  = 0;

end
