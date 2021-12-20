function res = doTest(res,options,residual)
% Syntax:
%
% res = nb_nlsEstimator.doTest(res,options,residual)
%
% Description:
%
% Do different test based on the residuals.
% 
% See also:
% nb_nlsEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    T                 = size(residual,1);
    numCoeff          = length(options.parameters);
    logLikelihood     = nb_olsLikelihood(residual);
    res.logLikelihood = logLikelihood;
    res.aic           = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
    res.sic           = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
    res.hqc           = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
    res.dwtest        = nb_durbinWatson(residual);
    res.archTest      = nb_archTest(residual,round(options.nLagsTests));
    res.autocorrTest  = nb_autocorrTest(residual,round(options.nLagsTests));
    res.normalityTest = nb_normalityTest(residual,numCoeff);

    % Full system 
    res.fullLogLikelihood = nb_olsLikelihood(residual,'full');
    res.aicFull           = nb_infoCriterion('aic',res.fullLogLikelihood,T,numCoeff);
    res.sicFull           = nb_infoCriterion('sic',res.fullLogLikelihood,T,numCoeff);
    res.hqcFull           = nb_infoCriterion('hqc',res.fullLogLikelihood,T,numCoeff);
    
end
