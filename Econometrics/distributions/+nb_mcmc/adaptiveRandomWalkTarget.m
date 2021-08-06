function [betaDraw,output] = adaptiveRandomWalkTarget(output)
% Syntax:
%
% [betaDraw,output] = nb_mcmc.adaptiveRandomWalkTarget(output)
%
% Description:
%
% Draw one candidate during Metropolis-Hastings algorithm using the random
% walk assumption.
% 
% In this case the scaling of the covariance matrix is updated for every X 
% simulation. I.e. each time we check the covariance matrix, it is scaled  
% so to make the acceptance ratio equal to the target.
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

    if output.triesOneIter == 100
        meanAcceptance = output.acceptedOneIter/output.triesOneIter;
        if meanAcceptance < output.accTarget
            output.a = output.a - 1;
        else
            output.a = output.a + 1;
        end
        output.sigmaCholLast   = exp(output.accScale*output.a)*output.sigmaChol;
        output.acceptedOneIter = 0;
        output.triesOneIter    = 0;
    end
    betaDraw = output.phi(output);

end
