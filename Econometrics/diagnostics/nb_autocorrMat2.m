function acf = nb_autocorrMat2(y,lags,demean,shrink)
% Syntax:
%
% acf = nb_autocorrMat2(y,lags)
% acf = nb_autocorrMat2(y,lags,demean,shrink)
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
% - shrink : Set to true to use the automatic shrinkage parameter of
%            Kwan (2011). false is default
% 
%            Can also be set to a number bewteen 0 and 1. For more see
%            the lambda input of the nb_covShrinkDiag functin.
%   
% Output:
% 
% - acf  : A nvar x nvar x lags + 1 x nPage double. The first page being 
%          the correlation matrix of the variables.
%
% See also:
% nb_autocov, nb_autocorr, nb_autocovMat2, nb_covShrinkDiag
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        shrink = false;
        if nargin < 3
            demean = true;
        end
    end

    acf = nb_autocovMat2(y,lags,demean,shrink);
    for pp = 1:size(acf,3)
        stds        = sqrt(diag(acf(:,:,pp)));
        stds        = stds*stds';
        acf(:,:,pp) = acf(:,:,pp)./stds;
    end
    
end
