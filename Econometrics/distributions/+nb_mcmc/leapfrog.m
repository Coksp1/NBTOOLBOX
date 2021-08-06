function [thetaprime, rprime, gradprime, logpprime] = leapfrog(theta, r, grad, epsilon, f, ub, lb)
% Syntax:
%
% [thetaprime, rprime, gradprime, logpprime] = ...
%                   nb_mcmc.leapfrog(theta, r, grad, epsilon, f)
%
% Description:
%
% Carries out the lepfrog step of the NUTS algorithm.
% 
% Input:
% 
% - theta   : A nVar x 1 double. Current state of a Markov chain and the
%             initial state for the trajectory of Hamiltonian dynamcis.
%
% - r       : The current state of the momentum. As a nVar x 1 double. 
%
% - grad    : A nVar x 1 double. Gradient of the log probability 
%             computed at theta. 
%
% - epsilon : A scalar double. Step size of leap-frog integrator.
%
% - f       : A function_handle that returns the log probability of the 
%             target and its gradient.
%
% Output:
% 
% - thetaprime : Next state of the chain, as a nVar x 1 double.
% 
% - rprime     : Next state of the momentum, as a nVar x 1 double.
%
% - gradprime  : A nVar x 1 double. Gradient of the log probability 
%                computed at thetaprime. 
%
% - logpprime  : The log probability at thetaprime, as a scalar double.
%
% See also:
% nb_mcmc.NUTS, nb_mcmc.dualAveraging
%
% Written by Matthew D. Hoffman
% Edited by Kenneth Sæterhagen Paulsen
% - Separated out as an own function.
% - Added documentation.
% - Added the lower and upper bound on the parameters.

% Copyright (c) 2011, Matthew D. Hoffman

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    rprime     = r + 0.5 * epsilon * grad;
    thetaprime = theta + epsilon * rprime;
    if ~isempty(lb)
        test             = thetaprime < lb;
        thetaprime(test) = lb(test);
    end
    if ~isempty(ub)
        test             = thetaprime > ub;
        thetaprime(test) = ub(test);
    end
    [logpprime, gradprime] = f(thetaprime);
    rprime                 = rprime + 0.5 * epsilon * gradprime;

end
