function x = nb_mci(func,a,b,draws,dist)
% Syntax:
%
% x = nb_mci(func,a,b,draws,dist)
%
% Description:
%
% Integrate a univariate function from a to b using a monte carlo method. 
% 
% Input:
% 
% - func  : A function handle.
%
% - a     : Lower limit, as a scalar double. Can be -inf.
%
% - b     : Upper limit, as a scalar double. Can be inf.
% 
% - draws : Number of draws. As a number grater than or equal to 1000. 
%           Default is 10000.
%
% - dist  : The distribution to use to do the montecarlo integration. As
%           a nb_distribution object. Default is to use the uniform(a,b)
%           distribution. This distribution will be truncated in the
%           interval [a,b], so this means that the domain of the given 
%           distribution must contain the interval [a,b].
%
%           Caution : If a == -inf and/or b == inf. The truncated normal  
%                     distribution is used as the default distribution.
%
% Output:
% 
% - x    : The value of the integral.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        dist = [];
        if nargin < 4
            draws = [];
        end
    end
    
    if isempty(draws)
        draws = 10000;
    end
    
    if a >= b
        error([mfilename ':: a must be lower than b'])
    end
    
    if isempty(dist)
        if ~isfinite(a) && ~isfinite(b)
            dist = nb_distribution('type','normal','parameters',{0,10});
        elseif ~isfinite(a)
            dist = nb_distribution('type','normal','parameters',{0,10});
            set(dist,'upperBound',b);
        elseif ~isfinite(b)
            dist = nb_distribution('type','normal','parameters',{0,10});
            set(dist,'lowerBound',a);
        else
            dist = nb_distribution('type','uniform','parameters',{a,b});
        end
    else
        if isfinite(a)
            set(dist,'lowerBound',a);
        end
        if isfinite(b)
            set(dist,'upperBound',b);
        end
    end
    
    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Do the MCI
    try
        X = random(dist,1,draws);
        f = func(X);
        p = pdf(dist,X);
        x = mean(f./p);
    catch Err
        defaultStream.State = savedState;
        RandStream.setGlobalStream(defaultStream);
        rethrow(Err)
    end
    
    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);

end
