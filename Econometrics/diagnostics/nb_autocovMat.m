function acf = nb_autocovMat(y,lags,demean)
% Syntax:
%
% acf = nb_autocovMat(y,lags)
% acf = nb_autocovMat(y,lags,demean)
%
% Description:
%
% Calculate the autocovariance matrix of a set of series.
% 
% Input:
% 
% - y      : A nobs x nvar x nPage double.
%
% - lags   : A non-negative integer.
% 
% - demean : true (demean data during estimation of the 
%            autocovariance matrix), false (do not). Defualt is true.
%         
% Output:
% 
% - acf  : A nvar x nvar x lags + 1 x nPage double. The first page being 
%          the covariance matrix of the variables.
%
% See also:
% nb_autocov, nb_autocorr, nb_autocorrMat
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        demean = true;
    end

    if ~isnumeric(y)
        error([mfilename ':: y must be a double'])
    end
    
    if ~isscalar(lags) || ~nb_iswholenumber(lags)
        error([mfilename ':: lags must be an integer'])
    end
    
    if size(y,1) < lags + 3
        error([mfilename ':: The series y needs at least nobs=' int2str(lags+3) ', but only has ' int2str(size(y,1))])
    end
    
    if demean
        func = @(x,y)normalCov(x,y);
    else
        func = @(x,y)notDemeanCov(x,y);
    end
    nVar = size(y,2);
    acf  = nan(nVar,nVar,lags+1,size(y,3));
    for pp = 1:size(y,3)
        for ii = 1:lags+1
            ylag = lag(y(:,:,pp),ii-1);
            ylag = ylag(ii:end,:);
            yt   = y(ii:end,:,pp);
            for jj = 1:nVar
                for kk = 1:nVar
                    acfTemp          = func(yt(:,jj),ylag(:,kk));
                    acf(jj,kk,ii,pp) = acfTemp(2,1);
                end
            end
        end
    end
    
end

function c = normalCov(x,y)
    n = size(x,1);
    if n > 1
        denom = n - 1;
    else
        denom = n;
    end
    x  = [x y];
    xc = bsxfun(@minus,x,sum(x,1)./n);
    c  = (xc'*xc)./denom;
end

function c = notDemeanCov(x,y)
    n = size(x,1);
    if n > 1
        denom = n - 1;
    else
        denom = n;
    end
    x  = [x y];
    c  = (x'*x)./denom;
end
