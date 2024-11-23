function [test,pval] = nb_mincerZarnowitz(actual,predicted)
% Syntax:
%
% [test,pval] = nb_mincerZarnowitz(actual,predicted)
%
% Description:
%
% Do the Mincer-Zarnowitz test for bias in the forecast from a model.
% 
% actual = beta_0 + beta_1*predicted + e
%
% Caution: Handles nan values in the predicted and the actual inputs!
%
% Input:
% 
% - actual    : A nobs x nvar double with the actual data to compare 
%               against.
%
% - predicted : A nobs x nvar x nhor double with the predictions at horizon
%               1:nhor for observation 1:nobs.
% 
% Output:
% 
% - test : The F-test statistic of beta_0 = 0 and beta_1 = 0. Will be of
%          size nhor x nvar.
%
% - pval : The p-value of the test statistic. Found from the F(2,nobs-2)
%          distribution. Will be of size nhor x nvar.
%
% See also:
% nb_uncondForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [~,nvar,nhor] = size(predicted);
    test          = nan(nhor,nvar);
    pval          = test;
    A             = [1,0;0,1];
    c             = [0;1];
    for ii = 1:nvar
        
        for jj = 1:nhor
    
            % Remove missing predictions
            act  = actual(:,ii);
            pred = predicted(:,ii,jj);
            ind  = isnan(pred) | isnan(act);
            act  = act(~ind,1);
            pred = pred(~ind,1);
            
            % Do the regression
            [beta,~,~,~,residual,X] = nb_ols(act,pred,1);
    
            % Do the F-test
            [test(jj,ii),pval(jj,ii)] = nb_restrictedFTest(A,c,X,beta,residual);

        end
        
    end
end
