function c = nb_cov2corr(c)
% Syntax:
%
% c = nb_cov2corr(c)
%
% Description:
%
% Go from covariance to correlation matrix. 
% 
% Input:
% 
% - c : Page one is the contemporenous correlation matrix. Page 2:end
%       is the autocorrelation of degree >= 1.
% 
% Output:
% 
% - c  : Correlation matrix.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nLags = size(c,3);
    stds  = sqrt(diag(c(:,:,1)));
    stds  = stds*stds';
    for ii = 1:nLags
       c(:,:,ii) = c(:,:,ii)./stds;
    end

end
