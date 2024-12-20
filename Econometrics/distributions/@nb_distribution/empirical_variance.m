function x = empirical_variance(domain,CDF)
% Syntax:
%
% x = nb_distribution.empirical_variance(domain,CDF)
%
% Description:
%
% Variance of the empirical density. This will use the 
% nb_distribution.empirical_rand to make 1000 draws from the distribution,
% and then calculate the variance based on those draws.
%
% It will adjust the variance by T-1.
% 
% Input:
% 
% - domain  : The domain of the distribution.
% 
% - density : The empirical CDF.
%
% Output:
% 
% - x : The variance of the estimated empirical density.
%
% See also:
% nb_distribution.empirical_median, nb_distribution.empirical_mean, 
% nb_distribution.empirical_std, nb_distribution.empirical_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);

    % Make draws to calculate the std
    draws = nb_distribution.empirical_rand(1000,1,domain,CDF);
    x     = var(draws,0,1);

    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
end
