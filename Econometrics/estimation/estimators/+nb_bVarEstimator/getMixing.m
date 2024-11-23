function mixing = getMixing(options)
% Syntax:
%
% mixing = nb_bVarEstimator.getMixing(options)
%
% Description:
%
% Get mixing options.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    mixing.indObservedOnly = options.indObservedOnly;
    vars                   = [options.dependent,options.block_exogenous];
    varsMixing             = vars(~mixing.indObservedOnly);
    [~,mixing.loc]         = ismember(options.mixing(options.indObservedOnly),vars);
    [~,mixing.locLow]      = ismember(vars(options.indObservedOnly),vars);
    [~,mixing.locIn]       = ismember(options.mixing(options.indObservedOnly),varsMixing);
    mixing.frequency       = [options.frequency{options.indObservedOnly}];
        
end
