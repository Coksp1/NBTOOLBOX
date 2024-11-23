function options = template(num)
% Syntax:
%
% options = nb_midas.template()
% options = nb_midas.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_midas class 
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                             = nb_model_generic.templateGeneral(num,'time-series');
    options.AR                          = false;
    options.algorithm                   = 'unrestricted';
    options.constant                    = 1;
    options.covidAdj                    = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.draws                       = 1;
    options.estim_method                = 'midas';
    options.exogenous                   = {};
    options.frequency                   = 4;
    options.nLags                       = 1;
    options.nLagsTests                  = 5;
    options.nStep                       = 1;
    options.optimset                    = [];
    options.polyLags                    = [];
    options.regularization              = [];
    options.regularizationMode          = 'normal';
    options.regularizationPerc          = [];
    options.restrictConstant            = true;
    options.stdType                     = 'h';
    options.unbalanced                  = false;

end
