function options = template(num)
% Syntax:
%
% options = nb_calculate_seasonal.template()
% options = nb_calculate_seasonal.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_calculate_seasonal
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

    options                      = nb_model_generic.templateGeneral(num,'time-series');
    options.dependent            = {};
    options.estim_method         = 'seasonal';
    options.exogenous            = {};
    options.maxIter              = 2500;
    options.missing              = false;
    options.removeZeroRegressors = false;
    options.renameVariables      = {};
    options.tolerance            = 1e-5;


end
