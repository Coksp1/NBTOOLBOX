function options = template(num)
% Syntax:
%
% options = nb_ecm.template()
% options = nb_ecm.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_ecm
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
    options.endogenous                  = {};
    options.estim_method                = 'ols';
    options.exogenous                   = {};
    options.exoLags                     = 0;
    options.maxLagLength                = 10;
    options.method                      = 'oneStep';
    options.missingMethod               = '';                    
    options.modelSelection              = '';
    options.modelSelectionAlpha         = 0.05;
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.seasonalDummy               = '';
    options.stdType                     = 'h';
    options.time_trend                  = 0; 

end
