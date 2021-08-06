function acf = nb_autocovMat2(y,lags,demean,shrink)
% Syntax:
%
% acf = nb_autocovMat2(y,lags)
% acf = nb_autocovMat2(y,lags,demean,shrink)
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
% - shrink : Set to true to use the automatic shrinkage parameter of
%            Kwan (2011). false is default
% 
%            Can also be set to a number bewteen 0 and 1. For more see
%            the lambda input of the nb_covShrinkDiag functin.
%         
% Output:
% 
% - acf  : A nvar x nvar * (lags + 1) x nPage double. Variables are looped
%          fast, lags slow. 
%
% See also:
% nb_autocorrMat2, nb_autocovMat
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        shrink = false;
        if nargin < 3
            demean = true;
        end
    end

    if ~isnumeric(y)
        error([mfilename ':: y must be a double'])
    end
    
    if ~isscalar(lags) || ~nb_iswholenumber(lags)
        error([mfilename ':: lags must be an integer'])
    end
    
    T = size(y,1);
    if T < lags + 3
        error([mfilename ':: The series y needs at least nobs=' int2str(lags+3) ', but only has ' int2str(size(y,1))])
    end
    
    nVar = size(y,2);
    acf  = nan(nVar*(lags+1),nVar*(lags+1),size(y,3));
    for pp = 1:size(y,3)
        
        Y           = nan(size(y,1) - lags,nVar*(lags+1));
        Y(:,1:nVar) = y(lags+1:end,:);
        for ii = 1:lags
            ind      = ii*nVar + 1:(ii + 1)*nVar;
            ylag     = lag(y(:,:,pp),ii);
            Y(:,ind) = ylag(lags + 1:end,:);
        end
        
        if demean
            Y = bsxfun(@minus,Y,sum(Y,1)./T);
        end
            
        if shrink < 1 || isnumeric(shrink)
            if isnumeric(shrink)
                acf(:,:,pp) = nb_covShrinkDiag(Y,shrink);
            else
                acf(:,:,pp) = nb_covShrinkDiag(Y);
            end
        else
            if T > 1
                denom = T - 1;
            else
                denom = T;
            end
            acf(:,:,pp) = (Y'*Y)./denom;
        end
        
    end
      
end
