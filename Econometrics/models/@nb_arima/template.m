function options = template(num)
% Syntax:
%
% options = nb_arima.template()
%
% Description:
%
% Construct a struct which can be provided to the nb_arima
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
    options.algorithm                   = 'hr';
    options.alpha                       = 0.05;
    options.AR                          = nan;
    options.constant                    = 1;
    options.covrepair                   = false;
    options.criterion                   = '';
    options.dependent                   = {};
    options.doTests                     = 1;
    options.exogenous                   = {};
    options.integration                 = nan;
    options.MA                          = nan;
    options.maxAR                       = 3;
    options.maxMA                       = 3;
    options.nLagsTests                  = 5;
    options.optimizer                   = 'fmincon';
    options.removeZeroRegressors        = false;
    options.SAR                         = 0;
    options.SMA                         = 0;
    options.stabilityTest               = true;
    options.transition                  = [];
    options.waitbar                     = true;
%     options.stdType                     = 'h';

end
