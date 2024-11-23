function x = empirical_mean(domain,CDF)
% Syntax:
%
% x = nb_distribution.empirical_mean(domain,density)
%
% Description:
%
% Mean of the estimated empirical density. This will use the 
% nb_distribution.empirical_rand to make 1000 draws from the distribution,
% and then calculate the mean based on these draws.
%
% Input:
% 
% - domain  : The domain of the distribution
% 
% - CDF     : The empirical CDF
%
% Output:
% 
% - x : The mean of the estimated empirical density
%
% See also:
% nb_distribution.empirical_median, nb_distribution.empirical_mean, 
% nb_distribution.empirical_variance, nb_distribution.empirical_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Make draws to calculate the mean
    draws = nb_distribution.empirical_rand(1000,1,domain,CDF);
    x     = mean(draws,1);
    
    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);

end
