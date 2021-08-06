function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_mlEstimator.bootstrapModel(...
%                                  model,options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    error([mfilename ':: Bootstrap models estimated with maximum likelihood is not possible.'])

end
