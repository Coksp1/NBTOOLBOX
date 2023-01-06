function [results,options] = normalEstimation(options,y,X,nExo)
% Syntax:
%
% [results,options] = nb_midasEstimator.normalEstimation(options,y,X,nExo)
%
% Description:
%
% Estimate MIDAS model over the full sample.
%
% See also:
% nb_midasEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check the degrees of freedom
    if strcmpi(options.algorithm,'unrestricted')
        numCoeff = size(X,2) + options.constant + options.AR;
    elseif strcmpi(options.algorithm,'beta')
        numCoeff = nExo + 1 + options.constant + options.AR;
    elseif strcmpi(options.algorithm,'mean')
        numCoeff = nExo + options.constant + options.AR;
    else
        numCoeff = nExo*options.polyLags + options.constant + options.AR;
    end
    T = size(X,1);
    nb_estimator.checkDOF(options,numCoeff,T);

    % Estimate model
    %--------------------------------------------------
    [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = ...
        nb_midasFunc(y,X,options.constant,options.AR,options.algorithm,options.nStep,...
              options.stdType,nExo,options.nLags+1,'draws',options.draws,...
              'polyLags',options.polyLags);
                                                                                                         
    % Get estimation results
    %--------------------------------------------------
    y                  = nb_mlead(y,options.nStep);
    results            = struct();
    results.beta       = beta;
    results.betaD      = betaD;
    results.stdBeta    = stdBeta;
    results.tStatBeta  = tStatBeta;
    results.pValBeta   = pValBeta;
    results.residual   = residual;
    results.sigma      = sigma;
    results.sigmaD     = sigmaD;
    results.predicted  = y(1:end-1,:) - residual;

    % Get estimation dates of low frequency
    results.recursive_estim_start_ind_low = [];
    results.estim_end_ind_low             = T;
    
    % Get aditional test results
    %--------------------------------------------------
    if options.doTests

        numCoeff      = size(beta,1);
        numEq         = options.nStep;
        rSq           = nan(1,numEq);
        adjRSq        = rSq;
        logLikelihood = rSq;
        aic           = rSq;
        sic           = rSq;  
        hqc           = rSq;
        dwtest        = rSq;
        archTest      = rSq;
        autocorrTest  = rSq;
        normalityTest = rSq;
        SER           = rSq;
        SOSR          = rSq;
        for ii = 1:numEq
            residualT            = residual(1:end-ii+1,ii);
            [rSq(ii),adjRSq(ii)] = nb_rSquared(y(1:end-ii,ii),residualT,numCoeff);
            logLikelihood(ii)    = nb_olsLikelihood(residualT);
            dwtest(ii)           = nb_durbinWatson(residualT);
            [SER(ii),SOSR(ii)]   = nb_SERegression(residualT,numCoeff);
            aic(ii)              = nb_infoCriterion('aic',logLikelihood(ii),T-ii+1,numCoeff);
            sic(ii)              = nb_infoCriterion('sic',logLikelihood(ii),T-ii+1,numCoeff);
            hqc(ii)              = nb_infoCriterion('hqc',logLikelihood(ii),T-ii+1,numCoeff);
            archTest(ii)         = nb_archTest(residualT,round(options.nLagsTests));
            autocorrTest(ii)     = nb_autocorrTest(residualT,round(options.nLagsTests));
            normalityTest(ii)    = nb_normalityTest(residualT,numCoeff);
        end
        results.rSquared       = rSq;
        results.adjRSquared    = adjRSq;
        results.logLikelihood  = logLikelihood;
        results.aic            = aic;
        results.sic            = sic;
        results.hqc            = hqc;
        results.dwtest         = dwtest;
        results.archTest       = archTest;
        results.autocorrTest   = autocorrTest;
        results.normalityTest  = normalityTest;
        results.SERegression   = SER;
        results.sumOfSqRes     = SOSR;

        % Full system 
        results.fullLogLikelihood = nb_olsLikelihood(residual(1:end-numEq+1,:),'full');
        results.aicFull           = nb_infoCriterion('aic',results.fullLogLikelihood,T-numEq+1,numCoeff);
        results.sicFull           = nb_infoCriterion('sic',results.fullLogLikelihood,T-numEq+1,numCoeff);
        results.hqcFull           = nb_infoCriterion('hqc',results.fullLogLikelihood,T-numEq+1,numCoeff);

    end

end
