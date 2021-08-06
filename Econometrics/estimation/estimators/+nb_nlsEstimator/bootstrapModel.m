function [betaDraws,sigmaDraws,estOpt] = bootstrapModel(model,options,results,method,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,estOpt] = nb_nlsEstimator.bootstrapModel(model,...
%                                   options,results,method,draws,iter)
%
% Description:
%
% Bootstrap model.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        iter = 'end';
    end

    error([mfilename ':: Not yet finished!'])
    
end
