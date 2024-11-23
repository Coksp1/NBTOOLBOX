function prob = calculateProbabilities(employed)
% Syntax:
%
% prob = calculateProbabilities(employed)
%
% Description:
%
% Calculate the probability values for the solutions using fitness of the 
% solutions by
%
% p(i) = f(i)/sum_i(f(i))
%
% where f(i) is the value of the fitness of the value of the merit 
% function by employed bee number i.
%
% See "A comprehensive survey: Artificial bee colony (ABC) algorithm
% and applications", Karaboga et. al (2012).
% 
% Input:
% 
% - employed : A vector of employed bees. As a vector of nb_beeSolver
%              objects.
% 
%
% Output:
% 
% - prob     : The probabilities of onlooker bees to join the dance of 
%              employed bees.
%
% See also:
% nb_beeSolver.joinDance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fit  = [employed.fitness];
    prob = cumsum(fit/sum(fit));
    
end
