function beta = expandZR(betaIn,indZR)
% Syntax:
%
% beta = nb_bVarEstimator.expandZR(beta,indZR)
%
% Description:
%
% Expand coefficient matrix given zero regressors.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    beta            = zeros(size(indZR,2),size(betaIn,2),size(betaIn,3));
    beta(indZR,:,:) = betaIn;
    
end
