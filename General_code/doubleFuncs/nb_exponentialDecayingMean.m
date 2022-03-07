function out = nb_exponentialDecayingMean(in,lambda,dim)
% Syntax:
%
% out = nb_exponentialDecayingMean(in,lambda,dim)
%
% Description:
%
% Calculate mean using exponential decaying of past observation of a 
% series.
% 
% Input:
% 
% - in     : A nobs x nvar x npage double.
% 
% - lambda : A 1 x 1 double between 0 and 1.
%
% - dim    : Which dimension to take the mean over. 1, 2 or 3. Default is
%            1.
%
% Output:
% 
% - out    : A nobs x nvar x npage double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dim = 1;
    end

    if dim == 2
        in = permute(in,[2,1,3]);
    elseif dim == 3
        in = permute(in,[3,2,1]);
    end
    
    if ~nb_isScalarNumber(lambda)
        error([mfilename ':: The lambda input must be a scalar double.'])
    end
    if lambda < 0 || lambda > 1
        error([mfilename ':: The lambda input must be a number between 0 and 1.'])
    end
    [T,N,P]   = size(in);
    lambda    = lambda.^(T-1:-1:0);
    lambda    = lambda';
    lambda    = lambda(:,ones(1,N),ones(1,P));
    i         = isnan(in);
    lambda(i) = 0;
    lambda    = bsxfun(@rdivide,lambda,sum(lambda));
    out       = nansum(lambda.*in,1);
    
    if dim == 2
        out = permute(out,[2,1,3]);
    elseif dim == 3
        out = permute(out,[3,2,1]);
    end
    
end
