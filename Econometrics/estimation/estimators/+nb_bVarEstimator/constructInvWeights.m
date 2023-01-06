function invWeights = constructInvWeights(prior,T)
% Syntax:
%
% invWeights = nb_bVarEstimator.constructInvWeights(prior,T)
%
% Description:
%
% Construct inverse weights used when stochastic-volatility-dummy prior
% is selected.
% 
% See also:
% nb_bVarEstimator.applyDummyPrior, nb_bVarEstimator.glp, 
% nb_bVarEstimator.nwishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    TC         = prior.obsSVD;
    invWeights = ones(T,1); % vector of s_t
    for ii = 1:prior.periodsMax - 1
        if T >= TC + ii - 1
            invWeights(TC + ii - 1) = prior.eta(ii);
        end
    end
    if T >= TC + prior.periodsMax - 1
        TCrho               = TC + prior.periodsMax - 1;
        invWeights(TCrho:T) = 1 + (prior.eta(prior.periodsMax) - 1)*prior.rho.^(0:T - TCrho);
    end
    
end
