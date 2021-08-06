function [vars,indV] = getVariables(options)
% Syntax:
%
% [vars,indV] = nb_estimator.getVariables(options) 
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    vars = options.dependent;
    if isfield(options,'block_exogenous')
        vars = [vars, options.block_exogenous];
    end
    if isfield(options,'exogenous')
        vars = [vars, options.exogenous];
    end
    indV = ismember(options.dataVariables,vars); 

end
