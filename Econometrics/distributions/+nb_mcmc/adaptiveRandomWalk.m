function [betaDraw,output] = adaptiveRandomWalk(output)
% Syntax:
%
% [betaDraw,output] = nb_mcmc.adaptiveRandomWalk(output)
%
% Description:
%
% Draw one candidate during Metropolis-Hastings algorithm using the random
% walk assumption.
% 
% In this case the covariance matrix is updated based on the kept draws
% from the draws of the parameters. See Haario et al. (2001).
%
% Input:
% 
% - output : See the output of the nb_mcmc.mhSampler function.
% 
% Output:
% 
% - betaDraw : A nVar x 1 double.
%
% See also:
% nb_mcmc.mhSampler
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if output.index > output.minIter
        sigmaLast = (1-output.weight)*(5.6644/output.numVar)*cov(output.betaBurn(1:output.index-1,:)) + output.weight*output.sigma;
    else
        sigmaLast = output.sigma;
    end
    output.sigmaCholLast = nb_chol(sigmaLast,output.covrepair);
    betaDraw             = output.phi(output);

end
