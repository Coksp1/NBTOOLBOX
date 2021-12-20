function x = empirical_std(domain,CDF)
% Syntax:
%
% x = nb_distribution.empirical_std(domain,density)
%
% Description:
%
% Standard deviation of the estimated empirical density. This will use the 
% nb_distribution.empirical_rand to make 1000 draws from the distribution,
% and then calculate the standard deviation based on those draws.
%
% It will adjust the standard deviation by T-1.
% 
% Input:
% 
% - domain  : The domain of the distribution.
% 
% - CDF     : The empirical CDF.
%
% Output:
% 
% - x : The standard deviation of the estimated empirical density.
%
% See also:
% nb_distribution.empirical_median, nb_distribution.empirical_mean, 
% nb_distribution.empirical_variance, nb_distribution.empirical_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);

    % Make draws to calculate the std
    draws = nb_distribution.empirical_rand(1000,1,domain,CDF);
    x     = std(draws,0,1);

    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
end
