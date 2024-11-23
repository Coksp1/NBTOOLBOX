function options = template(num)
% Syntax:
%
% options = nb_exprModel.template()
% options = nb_exprModel.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_exprModel
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                         = nb_model_generic.templateGeneral(num,'time-series');
    options.constant                = 1;
    options.covidAdj                = {};
    options.dependent               = {};
    options.doTests                 = 1;
    options.estim_method            = 'expr';
    options.exogenous               = {};
    options.missingMethod           = '';
    options.nLagsTests              = 5;
    options.removeZeroRegressors    = false;
    options.stdType                 = 'h';
    options.time_trend              = 0; 

end
