function out = nb_exponentialDecay(in,lambda)
% Syntax:
%
% out = nb_exponentialDecay(in,lambda)
%
% Description:
%
% Exponential decay past observation of a series.
% 
% Input:
% 
% - in     : A nobs x nvar double.
% 
% - lambda : A 1 x 1 double between 0 and 1.
%
% Output:
% 
% - out    : A nobs x nvar double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~nb_isScalarNumber(lambda)
        error([mfilename ':: The lambda input must be a scalar double.'])
    end
    if lambda < 0 || lambda > 1
        error([mfilename ':: The lambda input must be a number between 0 and 1.'])
    end
    [T,N,P] = size(in);
    lambda  = lambda.^(T-1:-1:0);
    lambda  = lambda';
    lambda  = lambda(:,ones(1,N),ones(1,P));
    out     = lambda.*in;
    
end
