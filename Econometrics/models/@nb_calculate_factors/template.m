function options = template(num)
% Syntax:
%
% options = nb_calculate_factors.template()
% options = nb_calculate_factors.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_calculate_factors
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

    options                  = nb_model_generic.templateGeneral(num,'time-series');
    options.estim_method     = 'pca';
    options.factorsCriterion = 7;
    options.missing          = '';
    options.nFactors         = [];
    options.nFactorsMax      = [];
    options.observables      = {};
    options.unbalanced       = false;

end
