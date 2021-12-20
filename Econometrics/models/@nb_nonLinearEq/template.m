function options = template(num)
% Syntax:
%
% options = nb_nonLinearEq.template()
% options = nb_nonLinearEq.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_nonLinearEq
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

    options                 = nb_model_generic.templateGeneral(num,'both');
    options.constraints     = [];
    options.covrepair       = false;
    options.dependent       = {};
    options.doTests         = 1;
    options.equations       = {};
    options.estim_method    = 'nls';
    options.exogenous       = {};
    options.init            = struct();
    options.lb              = struct();
    options.macroWriteFile  = '';
    options.macroProcessor  = false;
    options.macroVars       = nb_macro.empty();
    options.nLagsTests      = 5;
    options.optimizer       = 'fmincon';
    options.optimset        = struct;
    options.parameters      = {};
    options.silent          = false;
    options.ub              = struct();

end
