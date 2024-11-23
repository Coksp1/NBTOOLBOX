function options = template(num)
% Syntax:
%
% options = nb_manualCalculator.template()
% options = nb_manualCalculator.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_manualCalculator
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
% Written by Kenneth Sæterhagen Paulsen and Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                 = nb_model_generic.templateGeneral(num,'time-series');
    options.dependent       = {};
    options.calcfunc        = [];
    options.handleMissing   = false;
    options.outVariables    = {};
    options.renameVariables = {};
    options.path            = '';
    
end
