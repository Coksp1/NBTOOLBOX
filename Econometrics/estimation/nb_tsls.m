function [beta,stdBeta,tStatBeta,pValBeta,residual,x] = nb_tsls(y,x,z,inst,constant,timeTrend)
% Syntax:
%
% beta = nb_tsls(y,x,z,inst)
% [beta,stdBeta,tStatBeta,pValBeta,residual,x] = ...
%                           nb_tsls(y,x,z,inst,constant,timeTrend)
%
% Description:
%
% Estimate multiple (unrelated) equations using tsls.
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
% - constant  : If a constant is wanted in the estimation. Will be
%               added first in the right hand side variables.
% 
% - timeTrend : If a linear time trend is wanted in the estimation. 
%               Will be added first/second in the right hand side 
%               variables. (First if constant is not given, else 
%               second)
%
% Output: 
% 
% - beta       : A (extra + nxvar + nzvar) x neq matrix with the  
%                estimated parameters. Where extra is 0, 1 or 2 
%                dependent on the constant and/or time trend is 
%                included.
%
% - stdBeta    : A (extra + nxvar + nzvar) x neq matrix with the    
%                standard deviation of the estimated paramteres.  
%                Where extra is 0, 1 or 2 dependent on the constant  
%                and/or time trend is included.
%
% - tStatBeta  : A (extra + nxvar + nzvar) x neq matrix with   
%                t-statistics of the estimated paramteres. Where  
%                extra is 0, 1 or 2 dependent on the constant 
%                and/or time trend is included.
%
% - pValBeta   : A (extra + nxvar + nzvar) x neq matrix with the   
%                p-values of the estimated paramteres. Where extra  
%                is 0, 1 or 2 dependent on the constant and/or time  
%                trend is included.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix.
%
% - x          : Regressors of final regression including constant, 
%                time-trend and instrumented endogenous variables.
%
% See also
% nb_tslsEstimator, nb_singleEq 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        error([mfilename ':: x and y must have same number of observations.']); 
    end
    if (nobs ~= nobs3)
        error([mfilename ':: z and y must have same number of observations.']); 
    end
    if nobs < 3
        error([mfilename ':: The estimation sample must be longer than 2 periods.']);
    end
    if nobs <= nvar + nzvar + constant + timeTrend
        error([mfilename ':: The number of estimated parameters must be less than the number of observations.'])
    end
    
    % Estimate first stage
    zpred = nan(nobs,nzvar);
    for ii = 1:nzvar

        zi             = inst{ii};
        [nobs4,nzivar] = size(zi);
        if (nobs ~= nobs4)
            error([mfilename ':: z and inst{' int2str(ii) '} must have same number of observations.']); 
        end
        if nzivar < 1
            error([mfilename ':: inst{' int2str(ii) '} can not be empty.']); 
        end

        [beta,~,~,~,~,zt] = nb_ols(z(:,ii),zi,constant,timeTrend);
        zpred(:,ii)       = zt*beta;

    end

    % Estimate second stage
    [beta,stdBeta,tStatBeta,pValBeta,residual,x] = nb_ols(y,[x,zpred],constant,timeTrend);
    
end
