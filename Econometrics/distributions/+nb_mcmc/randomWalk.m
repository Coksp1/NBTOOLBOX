function [betaDraw,output] = randomWalk(output)
% Syntax:
%
% [betaDraw,output] = nb_mcmc.randomWalk(output)
%
% Description:
%
% Draw one candidate during Metropolis-Hastings algorithm using the random
% walk assumption.
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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    betaDraw = output.phi(output);

end