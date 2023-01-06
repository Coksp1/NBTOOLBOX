function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do Chow-test. Results are stored in the property results.
% 
% Input:
% 
% - obj : An object of class nb_chowTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_chowTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the estimation results
    if isa(obj.model,'nb_model_generic')
        mResults  = obj.model.results;
        mEstOpt   = obj.model.estOptions;
    else
        error([mfilename ':: The Chow-test can only be done on a object which is of a subclass of nb_model_generic'])
    end
    opt = obj.options;
    
    if strcmpi(mEstOpt.estimator,'nb_arimaEstimator')
        error([mfilename ':: Chow test is not yet defined for ARIMA models.'])
    elseif strcmpi(mEstOpt.estimator,'nb_tslsEstimator')
        mResults                = mResults.mainEq;
        mEstOpt                 = mEstOpt.mainEq;
        mEstOpt.estim_start_ind = mEstOpt.estim_start_ind;
        mEstOpt.estim_end_ind   = mEstOpt.estim_end_ind;
        requiredDegreeOfFreedom = 10;
    else
        requiredDegreeOfFreedom = mEstOpt.requiredDegreeOfFreedom;
    end
    mEstOpt.recursive_estim = 0;
    
    % Check breakpoint input
    %--------------------------------------------------------------
    [dataS,freq] = nb_date.date2freq(mEstOpt.dataStartDate);
    start        = dataS + mEstOpt.estim_start_ind;
    finish       = dataS + mEstOpt.estim_end_ind;
    k            = size(mResults.beta,1);
    dof          = requiredDegreeOfFreedom + k + 1;
    if opt.recursive
        
        
        startRec = start + dof;
        endRec   = finish - dof;
        periods  = (endRec - startRec) + 1;
        chowTest = nan(periods,1);
        chowProb = nan(periods,1);
        for ii = 1:periods
            bP                          = startRec + (ii-1);
            [chowTest(ii),chowProb(ii)] = doOneIteration(bP,mEstOpt,dataS,k);
        end
        bP     = {startRec:endRec};
        models = [];
        
    else
    
        bP = nb_date.toDate(opt.breakpoint,freq);
        if bP > finish - dof || bP < start + dof
            error([mfilename ':: The breakpoint is too close to the start or end of estimation sample to satisfy '...
                             'the number of degrees of freedom to estimate one/both of the subsamples.'])
        end
        [chowTest,chowProb,resFull,res1,res2,optFull,opt1,opt2] = doOneIteration(bP,mEstOpt,dataS,k);
        
        % Store all the model results
        models = struct('results',{resFull,res1,res2},'options',{optFull,opt1,opt2});
        
    end
        
    % Report results
    res = struct('chowTest',    chowTest,...
                 'chowProb',    chowProb,...
                 'dependent',   {mEstOpt.dependent},...
                 'models',      models,...
                 'breakPoint',  bP);
    obj.results = res;

end

%==========================================================================
function [chowTest,chowProb,resFull,res1,res2,optFull,opt1,opt2] = doOneIteration(bP,mEstOpt,start,k)

    % Set up the split estimation samples
    estMethod              = mEstOpt.estimator;
    estMethod              = str2func([estMethod '.estimate']);
    mOpt1                  = mEstOpt;
    mOpt1.estim_end_ind    = (bP - start) + 1;
    [res1,opt1]            = estMethod(mOpt1);
    mOpt2                  = mEstOpt;
    mOpt2.estim_start_ind  = (bP - start) + 2;
    [res2,opt2]            = estMethod(mOpt2);
    [resFull,optFull]      = estMethod(mEstOpt);

    % Get sum of squared residuals
    SSR  = resFull.sumOfSqRes;
    SSR1 = res1.sumOfSqRes;
    SSR2 = res2.sumOfSqRes;

    % Get statistics
    T        = resFull.includedObservations;
    d1       = (SSR - SSR1 - SSR2)/k;
    d2       = (SSR1 + SSR2)/(T - k);
    chowTest = d1./d2;
    chowProb = nb_fStatPValue(chowTest, k, T - 2*k);

end
