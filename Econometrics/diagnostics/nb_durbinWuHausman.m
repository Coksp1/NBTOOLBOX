function [test,pval] = nb_durbinWuHausman(y,x,z,inst,constant,timeTrend)
% Syntax:
%
% [test,pval] = nb_durbinWuHausman(y,x,z,inst,constant,timeTrend)
%
% Description:
%
% Durbin-Wu-Hausman test for regressors exogeniety.
% 
% Input:
% 
% - y         : A double matrix of size nobs x neq of the dependent 
%               variable of the regression(s).
%
% - x         : A double matrix of size nobs x nxvar of the 
%               exogenous variables of all equations of the 
%               regression.
%
% - z         : A double matrix of size nobs x nzvar of the   
%               endogenous variables of all equations of the 
%               regression.
%
% - inst      : A 1 x nzvar cell of the instruments for each 
%               endogenous variable. Each element must be a double
%               with size nobs x nzivar. nzivar must be greater 
%               than 0.
%
% - constant  : If a constant is wanted in the estimation.
% 
% - timeTrend : If a linear time trend is wanted in the estimation. 
% 
% Output:
% 
% - test : Durbin-Wu-Hausman statistic. A 1 x 1 double.
%
% - pval : P-value of the test statistic. The test statistic is distributed  
%          as F(nzvar,nobs - nzvar - nxvar).
%
% See also:
% nb_tsls
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        timeTrend = 0;
        if nargin < 5
            constant = 0;
        end
    end
    
    [nobs, nvar]   = size(x); 
    [nobs3, nzvar] = size(z); 
    [nobs2, ~]     = size(y);
    if (nobs ~= nobs2) 
        error([mfilename ':: x and y must have same # obs.']); 
    end
    if (nobs ~= nobs3)
        error([mfilename ':: z and y must have same # obs.']); 
    end
    if nobs < 3
        error([mfilename ':: The estimation sample must be longer than 2 periods.']);
    end
    if nobs <= nvar + nzvar + constant + timeTrend
        error([mfilename ':: The number of estimated parameters must be less than the number of observations.'])
    end
    
    % Get the instrumented variables
    zpred = nan(nobs,nzvar);
    for ii = 1:nzvar

        zi             = inst{ii};
        [nobs4,nzivar] = size(zi);
        if (nobs ~= nobs4)
            error([mfilename ':: z and inst{' int2str(ii) '} must have same # obs.']); 
        end
        if nzivar < 1
            error([mfilename ':: inst{' int2str(ii) '} can not be empty.']); 
        end

        [beta,~,~,~,~,zt] = nb_ols(z(:,ii),zi,constant,timeTrend);
        zpred(:,ii)       = zt*beta;

    end

    % Append them to the regression equation as proposed by Wu(1973)
    [beta,~,~,~,residual,X] = nb_ols(y,[x,zpred],constant,timeTrend);
    
    % Do a joint F-test that the parameters of the instrumented variables
    % are zero
    A           = [zeros(nzvar,nvar + constant + timeTrend),eye(nzvar)];
    c           = zeros(nzvar,1);
    [test,pval] = nb_restrictedFTest(A,c,X,beta,residual); 
    
end
