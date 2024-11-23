function betaDraw = mvnRandChol(output)
% Syntax:
%
% betaDraw = nb_mcmc.mvnRandChol(output)
%
% Description:
%
% Default function assign to the 'phi' input to the nb_mcmc.mhSampler.
% 
% Input:
% 
% - output   : See documentation of the output from the nb_mcmc.mhSampler
%              function.
% 
% Output:
% 
% - betaDraw : A nVar x 1 double.
%
% See also:
% nb_mcmc.mhSampler
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    eps      = nb_mvnrandChol(1,1,0,output.sigmaCholLast);
    betaDraw = output.betaLast + eps;
    if ~isempty(output.lb)
        test           = betaDraw < output.lb;
        betaDraw(test) = output.lb(test);
    end
    if ~isempty(output.ub)
        test           = betaDraw > output.ub;
        betaDraw(test) = output.ub(test);
    end
    
end
