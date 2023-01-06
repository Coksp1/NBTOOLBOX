function options = template(num)
% Syntax:
%
% options = nb_calculate_expr.template()
% options = nb_calculate_expr.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_calculate_expr
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                 = nb_model_generic.templateGeneral(num,'time-series');
    options.dependent       = {};
    options.func            = [];
    options.handleMissing   = false;
    options.outVariables    = {};
    options.renameVariables = {};
    
end
