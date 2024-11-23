function [stat,pval] = nb_ljungBoxTest(residual,p,h,type)
% Syntax:
%
% [stat,pval] = nb_ljungBoxTest(residual,p,h,type)
%
% Description:
%
% Test for autocorrelation of residuals from a regression using the 
% Ljung-Box test. Only for a VAR model.
%
% See https://en.wikipedia.org/wiki/Ljung%E2%80%93Box_test for univaiate
% test.
% 
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - p        : Number of lags of the VAR, as an integer.
%
% - h        : Number of lags of the autocorrelations to sum. Default is
%              ceil(T/4), where T is the sample size.
%
% - type     : 'multivariate' (default) or 'univariate'
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = 'multivariate';
        if nargin < 3
            h = [];
        end
    end

    % Perform the regression:
    [T,nEq] = size(residual);
    if isempty(h) || all(isnan(h))
        h = ceil(T/4);
    end
    if ~nb_isScalarInteger(h,0)
        error('The h input must be a scalar integer.')
    end
    if h <= p
        error(['The number of lags of the test (h=' int2str(h) ') must ',...
            'be greater than the number of lags of the VAR (p= ' int2str(p),...
            ') must be '])
    end
    
    if strcmpi(type,'univariate')

        stat = zeros(nEq,1);
        for jj = 1:nEq
            res    = residual(:,jj);
            resLag = nb_mlag(residual(:,jj),h,'varFast');
            for ii = 1:h
                rho      = corr(res(ii+1:end,:),resLag(ii+1:end,ii));
                stat(jj) = stat(jj) + rho^2/(T-ii); 
            end
            stat(jj) = T*(T + 2)*stat(jj);
        end

    else

        % Compute the test statistics:
        resLag  = nb_mlag(residual,h,'varFast');
        stat    = 0;
        SIGMA   = (residual'*residual)/T;
        SIGMAINV = eye(nEq)/SIGMA;
        for ii = 1:h
            
            ind     = 1+(ii-1)*nEq:ii*nEq;
            SIGMAh  = (residual(ii+1:end,:)'*resLag(ii+1:end,ind))/T;
            SIGMAht = SIGMAh';
            stat    = stat + trace(SIGMAht*SIGMAINV*SIGMAht*SIGMAINV)/(T-ii);

        end
        stat = T*(T + 2)*stat;

    end

    % Compute p-values:
    if strcmpi(type,'univariate')
        dof = h - p;
    else
        dof = nEq*(h - p + 1) - nEq^2;
    end
    pval = 1 - nb_distribution.chis_cdf(stat,dof);

end
