function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_ridgeEstimator.bootstrapModel(model,...
%                                   options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    error('Cannot bootstrap a model estimated with RIDGE')
    
end
