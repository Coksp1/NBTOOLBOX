function p = nb_mvncdf(x,mu,sigma)
% Syntax:
%
% p = nb_mvncdf(x,mu,sigma)
%
% Description:
%
% Evaluate multivariate normal cdf
%
% This code uses the qsimvn made by;
%
% Alan Genz, WSU Math, PO Box 643113, Pullman, WA 99164-3113
% 
% Input:
% 
% - x     : A nPoints x nVar double with the points to evaluate. 
% 
% - mu    : A 1 x nVar double with the mean of the different variables of the
%           distribution.
%
% - sigma : A nVar x nVar double with the correlation matrix.
%
% Output:
% 
% p       : A nPoints x 1 double with the evaluated probabilities.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [nPoints,nVars] = size(x);
    [smu1,smu2]     = size(mu);
    [ssig1,ssig2]   = size(sigma);
    if nVars ~= smu2
        error([mfilename ':: The dimension of x and mu is not consistent.'])
    end
    if nVars ~= ssig2
        error([mfilename ':: The dimension of x and sigma is not consistent.'])
    end
    if ssig1 ~= ssig2
        error([mfilename ':: The sigma input must be square matrix.'])
    end
    if smu1 ~= 1
        error([mfilename ':: The mu input must be a row vector.'])
    end
    
    % Use the same seed when returning the "random" numbers
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);

    % Normalize to mean zero
    x = bsxfun(@minus,x,mu);
    x = x';
    a = -inf(size(x,1),1);
    
    % Evaluate the probabilities
    p  = zeros(nPoints,1);
    ps = nb_poolSize;
    if ps > 1
        parfor ii = 1:nPoints
            p(ii) = qsimvn(5000,sigma,a,x(:,ii));
        end
    else
        for ii = 1:nPoints
            p(ii) = qsimvn(5000,sigma,a,x(:,ii));
        end
    end
    
    % Reset the seed
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
end
