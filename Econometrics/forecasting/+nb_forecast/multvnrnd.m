function E = multvnrnd(sigma,nSteps,nSim)
% Syntax:
% 
% E = nb_forecast.multvnrnd(sigma,nSteps,nSim)
%
% Description:
%
% Draw from the multivariate normal distribution
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        nSim = 1;
    end

    T = chol(sigma);
    E = randn(nSteps,size(T,1),nSim);
    for ii = 1:nSim
        E(:,:,ii) = E(:,:,ii)*T;
    end
    E = permute(E,[2,1,3]);

end
