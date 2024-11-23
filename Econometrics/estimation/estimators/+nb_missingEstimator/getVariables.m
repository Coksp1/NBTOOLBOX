function [endo,exo] = getVariables(options)
% Syntax:
%
% [endo,exo] = nb_missingEstimator.getVariables(options)
%
% Description:
%
% Get the variables of the model.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    endo = options.dependent;
    if isfield(options,'block_exogenous')
        endo = [endo,options.block_exogenous];
    end
    
    exo = {};
    if isfield(options,'exogenous')
        exo = [exo,options.exogenous];
    end
    if isfield(options,'observables')
        exo = [exo,cellstr(options.observables)];
    end
    
end
