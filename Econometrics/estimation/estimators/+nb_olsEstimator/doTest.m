function res = doTest(res,options,beta,y,X,residual)
% Syntax:
%
% res = nb_olsEstimator.doTest(res,options,beta,y,X,residual)
%
% Description:
%
% Do different test based on OLS residuals.
% 
% See also:
% nb_olsEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    T                      = size(residual,1);
    [numCoeff,numEq]       = size(beta);
    [rSquared,adjRSquared] = nb_rSquared(y,residual,numCoeff);
    logLikelihood          = nb_olsLikelihood(residual);

    if (numCoeff == 1 && options.constant) || ~options.constant
        res.fTest = nan(1,numEq);
        res.fProb = nan(1,numEq);   
    else
        res.fTest = (rSquared/(numCoeff - 1))./((1 - rSquared)/(T - numCoeff));
        res.fProb = 1 - nb_fStatPValue(res.fTest', numCoeff - 1, T - numCoeff);
    end

    res.rSquared      = rSquared;
    res.adjRSquared   = adjRSquared;
    res.logLikelihood = logLikelihood;
    res.logLikelihood = logLikelihood;
    res.aic           = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
    res.sic           = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
    res.hqc           = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
    res.dwtest        = nb_durbinWatson(residual);
    res.archTest      = nb_archTest(residual,round(options.nLagsTests));
    res.autocorrTest  = nb_autocorrTest(residual,round(options.nLagsTests));
    res.normalityTest = nb_normalityTest(residual,numCoeff);
    [res.SERegression,res.sumOfSqRes]  = nb_SERegression(residual,numCoeff);

    % White test on each equation (also the block exogenous)
    if ~isempty(X)
        nEq   = size(y,2);
        wTest = nan(1,nEq);
        wProb = nan(1,nEq);

        if options.time_trend
            tt = 1:T;
            X  = [tt',X];
        end

        if factorial(size(X,2)) < T - options.requiredDegreeOfFreedom
            for ii = 1:nEq
                try
                    [wTest(1,ii),wProb(1,ii)] = nb_whiteTest(residual(:,ii),X);
                catch %#ok<CTCH>
                    break
                end
            end
        end
        res.whiteTest = wTest;
        res.whiteProb = wProb;
    else
        nEq           = size(y,2);
        res.whiteTest = nan(1,nEq);
        res.whiteProb = nan(1,nEq);
    end
    
    % Full system 
    if size(residual,2) > 1
        res.fullLogLikelihood = nb_olsLikelihood(residual,'full');
        res.aicFull           = nb_infoCriterion('aic',res.fullLogLikelihood,T,numCoeff);
        res.sicFull           = nb_infoCriterion('sic',res.fullLogLikelihood,T,numCoeff);
        res.hqcFull           = nb_infoCriterion('hqc',res.fullLogLikelihood,T,numCoeff);
    end
    
end
