function options = template(num)
% Syntax:
%
% options = nb_mfvar.template()
% options = nb_mfvar.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_mfvar
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

    options                  = nb_var.template(num);
    options                  = rmfield(options,{'missingMethod','blockLags','modelSelection','seasonalDummy','maxLagLength'});
    options.estim_method     = 'ml';
    options.frequency        = {};
    options.mapping          = {};
    options.measurementError = {};
    options.mixing           = {};
     
end
