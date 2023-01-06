function x = ast_kurtosis(a,b,c,d,e)
% Syntax:
%
% x = nb_distribution.ast_kurtosis(a,b,c,d,e)
%
% Description:
%
% Kurtosis of the asymmetric t-distribution of Zhu and Galbraith (2009).
% 
% Caution : Simulation based (seed is set)!
%
% Input:
% 
% - a : The location parameter.
% 
% - b : The scale parameter (>0).
%
% - c : The skewness parameter (1>c>0).
%
% - d : The left parameter (>0). 
%
% - e : The right parameter (>0).
%
% Output:
% 
% - x : The kurtosis of the distribution
%
% See also:
% nb_distribution.ast_median, nb_distribution.ast_mean, 
% nb_distribution.ast_variance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    cstar = nb_ast_cstar(c,d,e);
    if cstar == 1 % Symmetric distribution
        x = nb_distribution.t_kurtosis(d);
        return
    elseif cstar == 0 % Symmetric distribution
        x = nb_distribution.t_kurtosis(d);
        return
    elseif cstar == c % Symmetric distribution
        x = nb_distribution.t_kurtosis(d);
        return
    end

    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);

    % Draw random numbers
    draws = nb_distribution.ast_rand(1000,1,a,b,c,d,e);
    x     = kurtosis(draws,0,1);
    
    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
end
