function x = kernel_kurtosis(domain,density)
% Syntax:
%
% x = nb_distribution.kernel_kurtosis(domain,density)
%
% Description:
%
% Kurtosis of the estimated kernel density. This will use the 
% nb_distribution.kernel_rand make 1000 draws from the distribution, and
% then calculate the kurtois based on these draws.
%
% It will adjust the kurtosis for bias. See the kurtosis method by MATLAB
% for more on this
% 
% Input:
% 
% - domain  : The domain of the distribution
% 
% - density : The density of the distribution
%
% Output:
% 
% - x : The kurtosis of the estimated kernel density
%
% See also:
% nb_distribution.normal_median, nb_distribution.normal_mean, 
% nb_distribution.normal_variance, nb_distribution.kernel_rand
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Make draws to calculate the kurtosis
    draws = nb_distribution.kernel_rand(1000,1,domain,density);
    x     = kurtosis(draws,0,1);

    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
end
