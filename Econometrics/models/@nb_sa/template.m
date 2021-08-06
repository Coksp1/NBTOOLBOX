function options = template(num)
% Syntax:
%
% options = nb_sa.template()
% options = nb_sa.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_sa class 
% constructor.
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
    options.constant                    = 1;
    options.criterion                   = '';
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_method                = 'ols';
    options.exogenous                   = {};
    options.maxLagLength                = 10;
    options.modelSelection              = '';
    options.modelSelectionAlpha         = 0.05;
    options.modelSelectionFixed         = [];
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.nStep                       = 4;
    options.quantile                    = 0.5;
    options.removeZeroRegressors        = false;
    options.seasonalDummy               = '';
    options.stdType                     = 'h';
    options.time_trend                  = 0;
    options.unbalanced                  = false;

end
