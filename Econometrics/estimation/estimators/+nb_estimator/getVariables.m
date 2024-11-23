function [vars,indV] = getVariables(options)
% Syntax:
%
% [vars,indV] = nb_estimator.getVariables(options) 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    vars = options.dependent;
    if isfield(options,'block_exogenous')
        vars = [vars, options.block_exogenous];
    end
    if isfield(options,'exogenous')
        vars = [vars, options.exogenous];
    end
    indV = ismember(options.dataVariables,vars); 

end
