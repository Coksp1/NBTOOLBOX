function [fTest,fProb] = nb_varFTest(y,nlag,x,beta)    
% Syntax:
%
% [fTest,fProb] = nb_varFTest(y,nlag,x,beta,constant)
%
% Description:
%
% Joint F-test
%
% Inspired by the vare function of LeSage.
%
% Input:
% 
% - y         : A double vector with the dependent variable of the 
%               regression. A double vector nobs x 1.
%
% - nlag      : The number of lags of the VAR. Default is 1.
%
%               !!! Should be made specific to each enogenous var.  
%
% - x         : Dependent of number of inputs:
%
%               - 2 : Taken as the residual of the regression.
%                     A double vector nobs - nlag x 1.
%
%               - 3 : Taken as the right hand side matrix of the
%                     estimation. A double vector nobs x nxvar.
%
% - beta      : The estimated parameters of the model. As a double
%               vector of size nxvar x 1.
% 
% Output: 
% 
% - boxQTest : A scalar with the result of the Box-Pierce Q-test.
% 
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        residual = x;
    else
        residual = y(nlag+1:end,:) - x(nlag+1:end,:)*beta;
    end

    % Size variables
    nx          = size(x,2);
    [nobs,neqs] = size(y);
    nobse       = nobs - nlag;
    nvar        = size(y,2)*nlag + nx + constant;

    % Need to calculate the residual variance
    sigu = residual'*residual;

    % Form x matrices for joint F-tests
    %--------------------------------------------------
    % Exclude each variable from the model sequentially
    fTest = nan(neqs,1);
    for r = 1:neqs

        xtmp = [];
        for s = 1:neqs

            if s ~= r
                xlag = nb_mlag(y(:,s),nlag);
                xtmp = [xtmp, nb_trimr(xlag,nlag,0)]; %#ok<AGROW>
            end

        end

        % We have an xtmp matrix that excludes 1 
        % variable add deterministic variables (if any) 
        % and constant term (if any)
        if constant

            if nx > 0
                xtmp = [xtmp x(nlag+1:nobs,:)]; %#ok<AGROW>
            end

        else

            if nx > 0
                xtmp = [xtmp x(nlag+1:nobs,:) ones(nobse,1)]; %#ok<AGROW>
            else
                xtmp = [xtmp ones(nobse,1)]; %#ok<AGROW>
            end

        end

        % Get ols residual vector
        b    = xtmp\yvec;      % using Cholesky solution
        etmp = yvec - xtmp*b;
        sigr = etmp'*etmp;

        % Joint F-test for variables r
        fTest(r,1) = ((sigr - sigu)/nlag)/(sigu/(nobse-nvar)); 

    end
   
    fProb = nb_fStatPValue(fTest, nlag, nobse - nvar);
    
end
