function F = nb_whiten(X,r,varargin)
% Syntax:
%
% F = nb_whiten(X,r)
% F = nb_whiten(X,r,varargin)
%
% Description:
%
% Calculate of factors from X that have variance one and covariances 0.
% 
% Input:
% 
% - X : The data as a nobs x nvar double.
%
% - r : The number of principal component. If empty nvar factors are
%       returned.
%
% Optional input:
%
% - 'missing' : Either '' (don't handle missing observations), 'zeros' 
%               or 'interpolate'.
%
% Output:
% 
% - F : The principal component, as a nobs x r double.
%
% Examples:
%
% load hald;
% F = nb_whiten(ingredients)
%
% See also:
% nb_pca, nb_ts.whiten
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        r = [];
    end

    [T,N] = size(X);
    if isempty(X)
        error([mfilename ':: X can not be empty'])
    end
    if N < 2
        error([mfilename ':: X must have at least two columns.'])
    end
    if T < 10
        error([mfilename ':: At least 10 periods of data is needed'])
    end
    
    missing = nb_parseOneOptional('missing','',varargin{:});   
    if ~isempty(missing)
        switch lower(missing)
            case 'zeros'
                isNaN    = isnan(X); 
                X(isNaN) = 0;
            case 'interpolate'
                X = nb_interpolate(X,'linear');
            otherwise
                error(['Cannot set the ''missing'' input to ' missing '.'])
        end
    else 
        isNaN = isnan(X); 
        if any(isNaN(:))
            error('This method does not handle missing observations (nan)');
        end
    end

    Sigma = cov(X);
    [U,S] = svd(Sigma);
    F     = (diag((1./sqrt(diag(S))))*U'*(X - mean(X))')';
    
    if ~isempty(r)
        if ~nb_isScalarInteger(r)
            error('The r input must be a scalar integer.')
        end
        F = F(:,1:r);
    end

end
