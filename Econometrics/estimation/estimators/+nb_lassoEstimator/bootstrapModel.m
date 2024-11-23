function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_lassoEstimator.bootstrapModel(model,...
%                                   options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    error('Cannot bootstrap a model estimated with LASSO')
    
end
