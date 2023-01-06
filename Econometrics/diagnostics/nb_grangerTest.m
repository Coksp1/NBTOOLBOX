function [F,FPValue] = nb_grangerTest(x,y,max_lag,criterion)
% Syntax:
%
% [F,FPValue] = nb_grangerTest(x,y,alpha,max_lag)
%
% Description:
%
% Granger Causality test. Does Y Granger Cause X?
% 
% References:
% [1] Granger, C.W.J., 1969. "Investigating causal relations by 
%     econometric models and cross-spectral methods". Econometrica 
%     37 (3), 424438.
%
% Input:
% 
% - x         : A nobs x 1 double.
%
% - y         : A nobs x 1 double.
%
% - alpha     : The significance level of the test.
%
% - max_lag   : The maximum number of lags to be considered.
% 
% - criterion : Lag length selction criterion. See the 
%               nb_lagLengthSelection function for more on this
%               input. Default is 'aic'.
%
% Output:
% 
% - F       : The value of the F-statistic
%
% - FPValue : The p-value of the F-statistic.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        criterion = 'aic';
    end

    %Make sure x & y are the same length
    if (length(x) ~= length(y))
        error('x and y must be the same length');
    end

    %Make sure x and y is column vectors
    x = x(:);
    y = y(:);

    %Make sure max_lag is >= 1
    if max_lag < 1
        error('max_lag must be greater than or equal to one');
    end
    max_lag = round(max_lag);
    
    % First find the proper model specifications
    %--------------------------------------------------------------
    xls = x(2:end);
    xrs = lag(x,1);
    xrs = xrs(2:end);
    
    [xlag,xls,xrs] = nb_lagLengthSelection(1,0,max_lag,criterion,'ols',xls,xrs);
    xlag = xlag + 1;
    
    yls = y(2:end);
    yrs = lag(y,1);
    yrs = yrs(2:end);
    fix = [true(1,xlag),false];
    [ylag,yls,yrs] = nb_lagLengthSelection(1,0,max_lag,criterion,'ols',yls,[xrs,yrs],fix);
    ylag = ylag + 1;
    
    % Get the statistics
    %--------------------------------------------------------------
    
    % Get the residuals
    [~,~,~,~,xres] = nb_ols(xls,xrs,1);
    [~,~,~,~,yres] = nb_ols(yls,[xrs,yrs],1);
    
    % Calculate the F-statistic
    [F,FPValue] = nb_fTest(xres,yres,xlag + 1,xlag + ylag + 1);

end
