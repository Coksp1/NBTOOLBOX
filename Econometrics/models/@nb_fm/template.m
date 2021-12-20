function options = template(num)
% Syntax:
%
% options = nb_fm.template()
% options = nb_fm.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_fm
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                             = nb_model_generic.templateGeneral(num,'time-series');
    options.constant                    = 1;
    options.criterion                   = '';
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_method                = 'fm';
    options.exogenous                   = {};
    options.factorsCriterion            = 7;
    options.maxLagLength                = 10;
    options.missingMethod               = '';
    options.modelSelection              = '';
    options.nFactors                    = [];
    options.nFactorsMax                 = [];
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.observables                 = {};
%     options.prior                       = [];
    options.seasonalDummy               = '';
    options.stdReplic                   = 1000;
    options.stdType                     = 'h';
    options.time_trend                  = 0; 
    options.unbalanced                  = false;

end
