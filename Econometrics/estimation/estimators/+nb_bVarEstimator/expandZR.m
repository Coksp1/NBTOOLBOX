function beta = expandZR(betaIn,indZR)
% Syntax:
%
% beta = nb_bVarEstimator.expandZR(beta,indZR)
%
% Description:
%
% Expand coefficient matrix given zero regressors.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    beta            = zeros(size(indZR,2),size(betaIn,2),size(betaIn,3));
    beta(indZR,:,:) = betaIn;
    
end
