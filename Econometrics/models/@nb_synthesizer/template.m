function options = template(num)
% Syntax:
%
% options = nb_synthesizer.template()
% options = nb_synthesizer.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_synthesizer
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
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    if num == 1
        options = struct();
    else
        options = nb_struct(num,{'method'}); % Make it possible to initalize many objects
    end
    
    options.combinatorModel  = [];
    options.cores            = [];
    options.estim_method     = 'synthesizer';
    options.foldWeights      = [];
    options.folds            = {};
    options.method           = 1;
    options.models           = [];
    options.modelWeights     = [];
    options.nModels          = 1;
    options.parallel         = false;
    options.removePeriods    = {};
    options.renameVariables  = {};
    options.varOfInterest    = '';
    options.scoreCrit        = 'RMSE';
    options.waitbar          = 1;

end
