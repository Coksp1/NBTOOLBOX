function [ST,pValue] = nb_smirnovTest(x,y,m,n)
% Syntax:
%
% [ST,pValue] = nb_smirnovTest(x,y,m,n)
%
% Description:
%
% Implements the Smirnov test for equal distributions of two random
% samples coming from two different distributions. The H0 is that the
% distributions are equal. So a p-value < alpha means that you can reject
% that the distributions are equal.
%
% Caution: It is assumed that the provided CDF are given at the same
%          domain!
% 
% Input:
% 
% - x      : A n x 1 double with the CDF of the first distribution. n > 6.
%
% - y      : A m x 1 double with the CDF of the second distribution. m > 6.
%
% - m      : Number of observations the estimation of the CDF of the first 
%            distribution is based on.
%
% - n      : Number of observations the estimation of the CDF of the second 
%            distribution is based on.
%
% Output:
% 
% - CT     : The Smirnov test statistics.
%
% - pValue : The p-value of the test.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = x(:);
    y = y(:);
    if size(x,1) < 6
        error('x must have at least 6 elements.')
    end
    if size(y,1) < 6
        error('y must have at least 6 elements.')
    end

    % Calculate test statistics
    ST     = max(abs(x - y));
    
    % Get p-value
    scale  = 2*m/(1 + m/n);
    pValue = exp(-scale*ST^2);
    
end
