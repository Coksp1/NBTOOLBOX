function boxQTest = nb_boxPierceQTest(residual,nlag)
% Syntax:
%
% boxQTest = nb_boxPierceQTest(residual,nlag)
%
% Description:
%
% Box-Pierce Q-test 
%
% Inspired by the vare function of LeSage.
%
% Input:
% 
% - residual  : A double vector of residuals from an ols 
%               estimation. 
%
% - nlag      : The number of lags. Default is 1. As a scalar.
% 
% Output: 
% 
% - boxQTest : A scalar with the result of the Box-Pierce Q-test.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initilizing
    nobs = size(residual,1);
    elag = nb_mlag(residual,nlag);

    % Feed the lags
    etrunc        = elag(nlag+1:end,:);
    rtrunc        = residual(nlag+1:end,1);
    beta          = nb_ols(rtrunc,etrunc);
    rSquaredQTest = nb_rSquared(rtrunc,etrunc,beta);
    if nlag ~= 1
        boxQTest = (rSquaredQTest/(nlag-1))/((1-rSquaredQTest)/(nobs-nlag));
    else
        boxQTest = (rSquaredQTest/(nlag))/((1-rSquaredQTest)/(nobs-nlag));
    end;
    
end
