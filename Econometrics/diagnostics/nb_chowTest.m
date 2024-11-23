function [chowTest,chowProb] = nb_chowTest(y,X,constant,timeTrend,breakpoint)
% Syntax:
%
% results = nb_chowTest(y,X,constant,timeTrend,breakPoint)
%
% Description:
%
% Test for breaks in the estimated coefficients. Null is no breaks.
%
% Input:
% 
% - y          : A double matrix of size nobs x 1 of the dependent 
%                variable of the regression.
%
% - x          : A double matrix of size nobs x nxvar of the right  
%                hand side variables of the equation of the 
%                regression.
%
% - constant   : If a constant is wanted in the estimation. Will be
%                added first in the right hand side variables.
% 
% - timeTrend  : If a linear time trend is wanted in the estimation. 
%                Will be added first/second in the right hand side 
%                variables. (First if constant is not given, else 
%                second)
%
% - breakpoint : Index of breakpoint. As a numeric scalar.
%
% Output: 
% 
% - results   : A struct with the fields:
%
%               > chowTest : Chow test statistic for structural 
%                            break.
%
%               > chowProb : P-value of test statistic. F(k,T-2k)
%                            distributed.
% 
% See also
% nb_ols
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    T = size(y,1);
    if breakpoint < 5
        error([mfilename ':: The tested breakpoint must be greater than 4.'])
    end
    if breakpoint > T - 5
        error([mfilename ':: The tested breakpoint must be less than (T - 4).'])
    end
    k = size(X,2) + constant + timeTrend;

    if timeTrend
        trend = [1:T]'; %#ok<NBRAK>
        X     = [trend,X];
    end
    
    % Get sub-samples
    y1 = y(1:breakpoint);
    X1 = X(1:breakpoint,:);
    y2 = y(breakpoint + 1:end);
    X2 = X(breakpoint + 1:end,:);
       
    % Estimate residuals
    [~,~,~,~,residual]  = nb_ols( y, X,constant,0);
    [~,~,~,~,residual1] = nb_ols(y1,X1,constant,0);
    [~,~,~,~,residual2] = nb_ols(y2,X2,constant,0);
    
    % Get sum of squared residuals
    SSR  = residual'*residual;
    SSR1 = residual1'*residual1;
    SSR2 = residual2'*residual2;
    
    % Get statistics
    d1       = (SSR - SSR1 - SSR2)/k;
    d2       = (SSR1 + SSR2)/(T - k);
    chowTest = d1/d2;
    chowProb = nb_fStatPValue(chowTest, k, T - 2*k);
    
end
