function prob = calculateProbabilities(employed,hasConstraints)
% Syntax:
%
% prob = calculateProbabilities(employed,hasConstraints)
%
% Description:
%
% Without constraints:
%
% Calculate the probability values for the solutions using fitness of the 
% solutions by
%
% p(i) = f(i)/sum_i(f(i))
%
% See "A comprehensive survey: Artificial bee colony (ABC) algorithm
% and applications", Karaboga et. al (2012).
%
% Whit constraints:
%
% Calculate the probability values for the solutions using fitness of the 
% solutions and the constraint violations (CV) by
%
% p(i) = 0.5 + f(i)/sum_i(f(i))*0.5, if solution is feasible.
% p(i) = (1 - CV(i)/sum_i(CV(i)))*0.5, if solution is infeasible.
%
% See "Modified artificial bee colony algorithm for constrained problems 
% optimization", Stanarevic et. al (2015)
% 
% Input:
% 
% - employed       : A vector of employed nb_bee objects.
% 
% - hasConstraints : True if we are doing constrained maximization, or
%                    false otherwise.
%
% Output:
% 
% - prob     : The probabilities of onlooker bees to join the dance of 
%              employed bees.
%
% See also:
% nb_bee.joinDance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if hasConstraints
        nBees        = size(employed,1);
        fit          = [employed.fitness];
        feasible     = [employed.currentFeasible];
        violation    = sum([employed.currentViolation],1);
        v            = nan(1,nBees);
        v(feasible)  = 0.5 + fit(feasible)/sum(fit(feasible));
        v(~feasible) = (1 - violation(~feasible)/sum(violation(~feasible)))*0.5;
        prob         = cumsum(v)/sum(v); % Secure that the probabilities sum to 1 
    else
        fit  = [employed.fitness];
        prob = cumsum(fit/sum(fit));
    end
    
end
