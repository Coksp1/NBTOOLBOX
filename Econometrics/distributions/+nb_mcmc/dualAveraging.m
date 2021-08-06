function [theta, epsilonbar, epsilon_seq, epsilonbar_seq, logp, grad] = dualAveraging(f, theta0, delta, n_warmup, maxTreeDepth, lb, ub, n_updates, waitbar)
% Syntax:
%
% [theta, epsilonbar, epsilon_seq, epsilonbar_seq, logp, grad] = ...
%           nb_mcmc.dualAveraging(f, theta0, delta, n_warmup, ...
%                       maxTreeDepth, lb, ub, n_updates, waitbar)
%
% Description:
%
% Adjusts the step-size of NUTS by the dual-averaging (stochastic 
% optimization) algorithm of Hoffman and Gelman (2014).
% 
% Input:
% 
% - f            : A function-handle that returns the log probability of the 
%                  target and its gradient.
%
% - theta0       : A nVar x 1 double. Initial state for the trajectory 
%                  of Hamiltonian dynamcis.
%
% - delta        : A scalar double in the range [0, 1]: the target 
%                  "acceptance rate" of NUTS.
%
% - n_warmup     : A scalar integer with the number of NUTS iterations for 
%                  the dual-averaging algorithm. 
%
% - maxTreeDepth : An integer with the maximum depth of tree.
%
% - lb           : A nVar x 1 double with the lower bounds on the 
%                  parameters. Give -inf for elements that is not bounded.
%                  Give [] if no parameters are bounded.
%
% - ub           : A nVar x 1 double with the upper bounds on the 
%                  parameters. Give inf for elements that is not bounded.
%                  Give [] if no parameters are bounded.
%
% - n_updates    : A scalar integer with the number of periods between 
%                  updates.
% 
% - waitbar      : Either a scalar logical or a nb_waitbar object. Default 
%                  is false.
%
% Output:
% 
% - theta          : Last state of the chain after the step-size  
%                    adjustment, which can be used as the initial 
%                    state for the sampling stage (no need for
%                    additional 'burn-in' samples)
%
% - epsilonbar     : A scalar double with the step-size corresponding to 
%                    the target "acceptance rate".
% 
% - epsilon_seq    : A n_warmup x 1 double with the value of epsilon at
%                    each step of the dual averaging algorithm. 
%
% - epsilonbar_seq : A n_warmup x 1 double with the value of epsilonbar at
%                    each step of the dual averaging algorithm.
%
% - logp           : Log probability computed at theta(end), as a 
%                    scalar double.
%
% - grad           : A nVar x 1 double. The gradient computed at 
%                    theta(end). 
%
% See also:
% nb_mcmc.NUTS, nb_mcmc.leapFrog, nb_mcmc.nutSampler
%
% Written by Matthew D. Hoffman
% Edited by Kenneth Sæterhagen Paulsen
% - Added the waitbar option. 
% - Change the interpretation of the n_updates input.
% - Removed some of the optional inputs.
% - Added the maxTreeDepth.
% - Added the lower and upper bounds inputs.

% Copyright (c) 2011, Matthew D. Hoffman

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Default argment values.
    if nargin < 6
        waitbar = false;
        if nargin < 5
            n_updates = 5;
        end
    end
    
    waitbarCreated = false;
    update         = 0;
    if islogical(waitbar)
        if waitbar
            h = nb_waitbar([],'Dual averaging (NUTS)',n_warmup,false,true);
            waitbarCreated = true;
            update         = 1;
        end
    elseif isa(waitbar,'nb_waitbar')
        h      = waitbar;
        update = 1;
    elseif isa(waitbar,'parallel.pool.DataQueue')
        h      = waitbar;
        update = 2;
    else
        error([mfilename ':: Wrong input given to waitbar.'])
    end
    
    % Calculate the number of iterations per update.
    [logp, grad] = f(theta0);

    % Choose a reasonable first epsilon by a simple heuristic.
    [epsilon, nfevals_total] = find_reasonable_epsilon(theta0, grad, logp, f, ub, lb);

    % Parameters for the dual averaging algorithm.
    gamma = .05;
    t0    = 10;
    kappa = 0.75;
    mu    = log(10 * epsilon);

    % Initialize dual averaging algorithm.
    epsilonbar     = 1;
    epsilon_seq    = zeros(n_warmup, 1);
    epsilonbar_seq = zeros(n_warmup, 1);
    epsilon_seq(1) = epsilon;
    Hbar           = 0;
    theta          = theta0(:,ones(1,n_warmup+1));
    for i = 1:n_warmup

        % Run one step of NUTS
        [theta(:,i+1), ave_alpha, nfevals, logp, grad] = nb_mcmc.NUTS(f, epsilon, theta(:,i), maxTreeDepth, lb, ub, logp, grad);
        
        % Update epsilon
        nfevals_total     = nfevals_total + nfevals;
        eta               = 1 / (i + t0);
        Hbar              = (1 - eta) * Hbar + eta * (delta - ave_alpha);
        epsilon           = exp(mu - sqrt(i) / gamma * Hbar);
        epsilon_seq(i)    = epsilon;
        eta               = i^-kappa;
        epsilonbar        = exp((1 - eta) * log(epsilonbar) + eta * log(epsilon));
        epsilonbar_seq(i) = epsilonbar;

        % Update on the progress of simulation.
        if update == 1
            % Standard waitbar
            if mod(i, n_updates) == 0
                h.status = h.status + n_updates;
            end
        elseif update == 2
            % Waitbar during parfor
            if mod(i, n_updates) == 0
                send(h,n_updates);
            end
        end

    end

    theta(:,1) = []; % Remove initial point
    if waitbarCreated
        delete(h)
    end

end

%==========================================================================
function [epsilon, nfevals] = find_reasonable_epsilon(theta0, grad0, logp0, f, ub, lb)

    epsilon = 1; 
    r0      = randn(length(theta0), 1);
    
    % Figure out what direction we should be moving epsilon.
    [~,rprime,~,logpprime] = nb_mcmc.leapfrog(theta0, r0, grad0, epsilon, f, ub, lb);
    nfevals                = 1;
    acceptprob             = exp(logpprime - logp0 - 0.5 * (rprime' * rprime - r0' * r0));
    a                      = 2 * (acceptprob > 0.5) - 1;
    
    % Keep moving epsilon in that direction until acceptprob crosses 0.5.
    while (acceptprob^a > 2^(-a))
        epsilon                = epsilon * 2^a;
        [~,rprime,~,logpprime] = nb_mcmc.leapfrog(theta0, r0, grad0, epsilon, f, ub, lb);
        nfevals                = nfevals + 1;
        acceptprob             = exp(logpprime - logp0 - 0.5 * (rprime' * rprime - r0' * r0));
    end

end
