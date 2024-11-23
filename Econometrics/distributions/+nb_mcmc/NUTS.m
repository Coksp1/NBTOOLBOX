function [theta, alpha_ave, nfevals, logp, grad] = NUTS(f, epsilon, theta0, maxTreeDepth, lb, ub, logp0, grad0)
% Syntax:
%
% [theta, alpha_ave, nfevals, logp, grad] = nb_mcmc.NUTS(f, epsilon, ...
%                       theta0, maxTreeDepth, lb, ub, logp0, grad0)
%
% Description:
%
% Carries out one iteration of No-U-Turn-Sampler.
% 
% Input:
% 
% - f            : A function_handle that returns the log probability of  
%                  the target and its gradient.
%
% - epsilon      : A scalar double. Step size of leap-frog integrator.
%
% - theta0       : A nVar x 1 double. Current state of a Markov chain and 
%                  the initial state for the trajectory of Hamiltonian 
%                  dynamcis.
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
% - logp0        : A nVar x 1 double. The log probability computed at 
%                  theta0. 
%
% - grad0        : A nVar x 1 double. Gradient of the log probability 
%                  computed at theta0. 
%
% Output:
% 
% - theta     : Next state of the chain, as a nVar x 1 double.
% 
% - alpha_ave : Average acceptance probability of the states proposed at 
%               the last doubling step of NUTS. It measures of the 
%               accuracy of the numerical approximation of Hamiltonian 
%               dynamics and is used to find an optimal step size value 
%               epsilon.
%
% - nfevals   : The number of log likelihood and gradient evaluations one
%               iteration of NUTS required
%
% - logp      : Log probability computed at theta, as a scalar double.
%
% - grad      : A nVar x 1 double. The gradient computed at theta.
%
% See also:
% nb_mcmc.dualAveraging, nb_mcmc.leapFrog, nb_mcmc.nutSampler
%
% Written by Matthew D. Hoffman
% Edited by Kenneth Sæterhagen Paulsen
% - Updated the documentation in line with NB Toolbox.
% - Removed the global variable nfevals.
% - Removed notifications when maximum tree depth where reached.
% - Removed the optional inputs.
% - Added the lower and upper bounds inputs.

% Copyright (c) 2011, Matthew D. Hoffman
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nfevals = 0;

    % Resample momenta.
    r0 = randn(size(theta0));
    
    % Joint log-probability of theta and momenta r.
    joint = logp0 - 0.5 * (r0' * r0);
    
    % Resample u ~ uniform([0, exp(joint)]).
    % Equivalent to (log(u) - joint) ~ exponential(1).
    logu = joint - exprnd(1);
    
    % Initialize tree.
    thetaminus = theta0;
    thetaplus  = theta0;
    rminus     = r0;
    rplus      = r0;
    gradminus  = grad0;
    gradplus   = grad0;
    
    % Initial height dir = 0.
    depth = 0;
    
    % If all else fails, the next sample is the previous sample.
    theta = theta0;
    grad  = grad0;
    logp  = logp0;
    
    % Initially the only valid point is the initial point.
    n = 1;

    % Main loop---keep going until the stop criterion is met.
    stop = false;
    while ~stop

        % Choose a direction. -1=backwards, 1=forwards.
        dir = 2 * (rand() < 0.5) - 1;

        % Double the size of the tree.
        if (dir == -1)
            [thetaminus, rminus, gradminus, ~, ~, ~, thetaprime, gradprime, logpprime, nprime, stopprime, alpha, nalpha, nfevals] = ...
                build_tree(thetaminus, rminus, gradminus, logu, dir, depth, epsilon, f, joint, nfevals,ub,lb);
        else
            [~, ~, ~, thetaplus, rplus, gradplus, thetaprime, gradprime, logpprime, nprime, stopprime, alpha, nalpha, nfevals] = ...
                build_tree(thetaplus, rplus, gradplus, logu, dir, depth, epsilon, f, joint, nfevals,ub,lb);
        end

        % Use Metropolis-Hastings to decide whether or not to move to a
        % point from the half-tree we just generated.
        if (~ stopprime && (rand() < nprime/n))
            theta = thetaprime;
            logp  = logpprime;
            grad  = gradprime;
        end

        % Update number of valid points we've seen.
        n = n + nprime;

        % Decide if it's time to stop.
        stop = stopprime || stop_criterion(thetaminus, thetaplus, rminus, rplus);

        % Increment depth.
        depth = depth + 1;
        if depth > maxTreeDepth
            %disp('Max three depth reached...')
            break
        end

    end
    alpha_ave = alpha / nalpha;

end

%==========================================================================
function criterion = stop_criterion(thetaminus, thetaplus, rminus, rplus)

    thetavec  = thetaplus - thetaminus;
    criterion = (thetavec' * rminus < 0) || (thetavec' * rplus < 0);

end

%==========================================================================
% The main recursion.
%==========================================================================
function [thetaminus, rminus, gradminus, thetaplus, rplus, gradplus, thetaprime, gradprime, logpprime, nprime, stopprime, alphaprime, nalphaprime, nfevals] = ...
                build_tree(theta, r, grad, logu, dir, depth, epsilon, f, joint0, nfevals, ub, lb)
            
    if (depth == 0)
        
        % Base case: Take a single leapfrog step in the direction 'dir'.
        [thetaprime, rprime, gradprime, logpprime] = nb_mcmc.leapfrog(theta, r, grad, dir*epsilon, f, ub, lb);
        nfevals = nfevals + 1;
        joint   = logpprime - 0.5 * (rprime' * rprime);
        
        % Is the new point in the slice?
        nprime = logu < joint;
        
        % Is the simulation wildly inaccurate?
        stopprime = logu - 100 >= joint;
        
        % Set the return values---minus=plus for all things here, since the
        % "tree" is of depth 0.
        thetaminus = thetaprime;
        thetaplus  = thetaprime;
        rminus     = rprime;
        rplus      = rprime;
        gradminus  = gradprime;
        gradplus   = gradprime;
        
        % Compute the acceptance probability.
        alphaprime = exp(logpprime - 0.5 * (rprime' * rprime) - joint0);
        if isnan(alphaprime)
            alphaprime = 0;
        else
            alphaprime = min(1, alphaprime);
        end
        nalphaprime = 1;
        
    else
        
        % Recursion: Implicitly build the height depth-1 left and right subtrees.
        [thetaminus, rminus, gradminus, thetaplus, rplus, gradplus, thetaprime, gradprime, logpprime, nprime, stopprime, alphaprime, nalphaprime, nfevals] = ...
                    build_tree(theta, r, grad, logu, dir, depth-1, epsilon, f, joint0, nfevals, ub, lb);
                
        % No need to keep going if the stopping criteria were met in the first
        % subtree.
        if ~stopprime
            
            if (dir == -1)
                [thetaminus, rminus, gradminus, ~, ~, ~, thetaprime2, gradprime2, logpprime2, nprime2, stopprime2, alphaprime2, nalphaprime2, nfevals] = ...
                    build_tree(thetaminus, rminus, gradminus, logu, dir, depth-1, epsilon, f, joint0, nfevals, ub, lb);
            else
                [~, ~, ~, thetaplus, rplus, gradplus, thetaprime2, gradprime2, logpprime2, nprime2, stopprime2, alphaprime2, nalphaprime2, nfevals] = ...
                    build_tree(thetaplus, rplus, gradplus, logu, dir, depth-1, epsilon, f, joint0, nfevals, ub, lb);
            end
            
            % Choose which subtree to propagate a sample up from.
            if (rand() < nprime2 / (nprime + nprime2))
                thetaprime = thetaprime2;
                gradprime  = gradprime2;
                logpprime  = logpprime2;
            end
            
            % Update the number of valid points.
            nprime = nprime + nprime2;
            
            % Update the stopping criterion.
            stopprime = stopprime || stopprime2 || stop_criterion(thetaminus, thetaplus, rminus, rplus);
            
            % Update the acceptance probability statistics.
            alphaprime  = alphaprime + alphaprime2;
            nalphaprime = nalphaprime + nalphaprime2;
            
        end
        
    end

end
