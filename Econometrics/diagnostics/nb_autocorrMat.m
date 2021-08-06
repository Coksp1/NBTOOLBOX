function acf = nb_autocorrMat(y,lags,demean)
% Syntax:
%
% acf = nb_autocorrMat(y,lags)
% acf = nb_autocorrMat(y,lags,demean)
%
% Description:
%
% Calculate the autocorrelation matrix of a set of series.
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
%          the correlation matrix of the variables.
%
% See also:
% nb_autocov, nb_autocorr, nb_autocovMat
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        demean = true;
    end

    acf = nb_autocovMat(y,lags,demean);
    for pp = 1:size(acf,4)
        stds = sqrt(diag(acf(:,:,1,pp)));
        stds = stds*stds';
        for ii = 1:lags+1
           acf(:,:,ii,pp) = acf(:,:,ii,pp)./stds;
        end
    end
    
end
