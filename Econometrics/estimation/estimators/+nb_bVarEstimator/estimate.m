function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_bVarEstimator.estimate(options)
%
% Description:
%
% This code is based on code from a paper by Koop and Korobilis (2010), 
% Bayesian Multivariate Time Series Methods for Empirical Macroeconomics.
%
% Estimate a model with bayesian methods. The following priors are
% supported (Can be set by the prior field of the options struct):
%
% - 'jeffrey'   : Diffuse                         (M-C Integration)
% - 'minnesota' : Minnesota                       (M-C Integration) or 
%                                                 (Gibbs sampler)
% - 'nwishart'  : Normal-Wishart                  (M-C Integration)           
% - 'inwishart' : Independent Normal-Wishart      (Gibbs sampler)
% - 'glp'       : This is the prior used in the  
%                 paper by Giannone, Lenza and 
%                 Primiceri (2014), which is of 
%                 the Normal-Wishart type prior.  (Gibbs sampler)
% 
% The code is also extended to handle missing observations and
% mixed-frequency VAR models. Then the following priors are supported:
%
% - 'minnesotaMF' : Minnesota                       (Gibbs sampler)
% - 'nwishartMF'  : Normal-Wishart                  (Gibbs sampler)          
% - 'inwishartMF' : Independent Normal-Wishart      (Gibbs sampler)
% - 'glpMF'       : This is the prior used in the  
%                   paper by Giannone, Lenza and 
%                   Primiceri (2014), which is of 
%                   the Normal-Wishart type prior.  (Gibbs sampler)
%
% A Kalman smoother is ran to get the posterior distribution of the missing
% observations.
%
% Input:
% 
% - options  : A struct on the format given by nb_bVarEstimator.template.
%              See also nb_bVarEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_bVarEstimator.print, nb_bVarEstimator.help, nb_bVarEstimator.template
% nb_var
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','nb_var');
    options = nb_defaultField(options,'missingMethod','');
    options = nb_defaultField(options,'modelSelection','');
    options = nb_defaultField(options,'modelSelectionFixed',[]);
    options = nb_defaultField(options,'seasonalDummy','');
    options = nb_defaultField(options,'empirical',false);
    options = nb_defaultField(options,'saveDraws',true);
    
    % Default prior settings (No dummy observation priors by default)
    options.prior = nb_defaultField(options.prior,'LR',false);
    options.prior = nb_defaultField(options.prior,'SC',false);
    options.prior = nb_defaultField(options.prior,'DIO',false);
    
    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    if isfield(options,'seed')
        seed = options.seed;
    else
        seed = 1;
    end
    rng(seed);
    
    % Modify some options due to beeing a VAR
    %-------------------------------------------------------
    mfvar = false;
    if strcmpi(options.class,'nb_mfvar')
        mfvar = true;
        % The nb_missingEstimator does not make sense for nb_mfvar, but we 
        % want to indicated that we are dealing with missing observation
        % when producing forecast.
        options.missingMethod = ''; % For now!!
    end
    missing = false;
    if any(strcmpi(options.prior.type,nb_var.mfPriors()))
        missing = ~mfvar;
    end
    if ~(mfvar || missing)
        options = nb_olsEstimator.varModifications(options);  
    end
    if missing
        options.missingMethod = 'kalman';
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isfield(options,'block_exogenous')
       tempDep = [tempDep,options.block_exogenous];
    end
    
    if isempty(tempDep)
        error([mfilename ':: You must add the left side variable of the equation to dependent field of the options property.'])
    end
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    if isempty(options.modelSelectionFixed)
        fixed = false(1,length(options.exogenous));
    else
        fixed = options.modelSelectionFixed;
        if ~islogical(fixed)
            fixed = logical(options.modelSelectionFixed);
        end
    end
    options.modelSelectionFixed = fixed;
    
    if strcmpi(options.modelSelection,'autometrics')
        error([mfilename ':: Unsupported option modelSelection (' options.modelSelection ') selected for bayesian VAR estimation'])
    end

    % Get the estimation data
    %------------------------------------------------------
    % Add seasonal dummies
    if ~isempty(options.seasonalDummy)
        options = nb_olsEstimator.addSeasonalDummies(options); 
    end

    % Add lags or find best model
    if ~isempty(options.modelSelection)

        if missing || mfvar
            error([mfilename ':: Model selection is not supported by mixed frequency B-VAR or missing observations B-VAR models.'])
        end
        
        minLags = [];
        if isfield(options,'class')
            if strcmpi(options.class,'nb_var')
                minLags = 0; 
            end
        end
        options = nb_olsEstimator.modelSelectionAlgorithm(options,minLags);

    else
        if ~all(options.nLags == 0) && ~(missing || mfvar)
            options = nb_olsEstimator.addLags(options);
        end
    end

    % Get data
    tempData    = options.data;
    [test,indY] = ismember(tempDep,options.dataVariables);
    if any(~test)
        error([mfilename ':: Some of the selected dependent variables are not found in the data; ' toString(tempDep(~test))])
    end
    y           = tempData(:,indY);
    [test,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~test)
        error([mfilename ':: Some of the selected exogenous variables are not found in the data; ' toString(options.exogenous(~test))])
    end
    X = tempData(:,indX);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
         
    % Do the estimation
    %------------------------------------------------------
    if size(X,2) == 0 && ~options.constant && ~options.time_trend
        if ~(missing || mfvar)
            error([mfilename ':: You must select some regressors.'])
        end
    end

    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end
    
    % Get prior restriction of spesific parameters (only for some priors)
    if ismember(lower(options.prior.type),{'glp','minnesota','minnesotamf'})
        options = nb_estimator.getSpecificPriors(options);
    end
    
    % Get measurement error prior scale
    if ismember(lower(options.prior.type),{'minnesotamf','nwishartMF','inwishartMF'})
        options = nb_bVarEstimator.interpretRScale(options);
    end
    
    %=========================
    if options.recursive_estim
    %========================= 
    
        [res,options] = nb_bVarEstimator.recursiveEstimation(options,y,X,mfvar,missing);
        
    %======================
    else % Not recursive
    %======================
        
        % Shorten sample
        if mfvar || missing
            if isempty(options.estim_start_ind)
                options.estim_start_ind = 1;
            end
            if isempty(options.estim_end_ind)
                options.estim_end_ind = size(y,1);
            end
            sample = options.estim_start_ind:options.estim_end_ind;
            y      = y(sample,:);
            X      = X(sample,:);
            if any(isnan(X(:)))
                test = any(isnan(X),1);
                error([mfilename ':: The estimation data on some of the exogenous variables are ',...
                       'missing for the selected sample; ' toString(options.exogenous(test))])
            end
            nLags  = options.nLags;
            nDep   = size(y,2);
            if mfvar
                nDep = nDep - sum(options.indObservedOnly);
            end
            numCoeff = nLags*nDep + size(X,2) + options.constant + options.time_trend;
        else
            yFull         = y;
            XFull         = X;
            [options,y,X] = nb_estimator.testSample(options,y,X);
            numCoeff      = size(X,2) + options.constant + options.time_trend;
            nLags         = options.nLags + 1;
        end
        
        % Check the degrees of freedom
        T = size(X,1);
        nb_estimator.checkDOF(options,numCoeff,T);
        
        % Check if we have a block_exogenous model
        restrictions = {};
        if isfield(options,'block_exogenous')
            if ~isempty(options.block_exogenous)
                restrictions = nb_estimator.getBlockExogenousRestrictions(options);
            end
        end
        
        % Create waiting bar window
        draws   = options.draws;
        waitbar = false;
        h       = false;
        if draws == 1
             check(options.prior,mfvar,missing);
        else
            if strcmpi(options.prior.type,'minnesota')
                options.prior = nb_defaultField(options.prior,'method','mci');
                if strcmpi(options.prior.method,'mci')
                    options.waitbar = false;
                end   
            end
            if options.waitbar
                h       = nb_estimator.openWaitbar(options,[],false);
                waitbar = ~isempty(h);
            end    
        end
        
        % Estimate the model using Bayesian methods
        %--------------------------------------------------
        if mfvar || missing
            
            if options.prior.LR
                error([mfilename ':: Prior for the long run is not supported for Mixed frequency ',...
                                 'VARs or VARs with missing observations.'])
            end
            if options.empirical
                if ~strcmpi(options.prior.type,'glpmf')
                    error([mfilename ':: Empirical bayesian is not supported for Mixed frequency VARs ',...
                                     'or VARs with missing observations for the prior ' options.prior.type '.'])
                end
            end
            
            nDep = length(tempDep);
            if mfvar
                % Add one extra set of lagged state variables here, if 
                % only 'end' mapping is used
                [H,freq,extra] = nb_mlEstimator.getMeasurmentEqMFVAR(options,1);
                
                % Store the mixing options in the prior
                mixing = nb_bVarEstimator.getMixing(options);
                nDep   = nDep - sum(options.indObservedOnly);
                
                if strcmpi(options.prior.type,'glpmf')
                    if options.empirical 
                        error([mfilename ':: Setting empirical to true for the glpMF prior is not supported for the nb_mfvar class.'])
                    else
                        empiricalOptions = [];
                    end
                end
            else
                % Add one extra set of lagged state variables here
                H      = [eye(nDep),zeros(nDep,nDep*(options.nLags))]; 
                freq   = [];
                extra  = true;
                mixing = [];
                if strcmpi(options.prior.type,'glpmf')
                    if options.empirical 
                        empiricalOptions = options;
                    else
                        empiricalOptions = [];
                    end
                end
                
            end
            switch lower(options.prior.type)
                case 'glpmf'
                    [betaD,sigmaD,R,ys,XX,posterior,fVal,options.prior] = nb_bVarEstimator.glpMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,empiricalOptions,freq,H,mixing); 
                case 'minnesotamf'
                    [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.minnesotaMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,freq,H,mixing);  
                case 'nwishartmf'
                    [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.nwishartMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,H,mixing);     
                case 'inwishartmf'
                    [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.inwishartMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,H,mixing);       
                otherwise
                    error([mfilename ':: Unsupported prior type ' options.prior.type])
            end
            yObs = ys(:,1:nDep);  
            
        else
            
            % Keep original y vector for later
            yObs = y; 
            R    = [];
            
            % Estimate
            if options.empirical
                [betaD,sigmaD,XX,posterior,options,fVal,pY] = nb_bVarEstimator.doEmpiricalBayesian(options,h,nLags,restrictions,y,X,yFull,XFull);
            else
                [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.doBayesian(options,h,nLags,restrictions,y,X,yFull,XFull);
            end
            
        end
        
        beta     = mean(betaD,3);
        stdBeta  = std(betaD,0,3);
        sigma    = mean(sigmaD,3);
        stdSigma = std(sigmaD,0,3);
        T        = size(yObs,1);
        residual = yObs - XX(1:T,1:numCoeff)*beta;
        
        % Delete the waitbar
        if waitbar 
            nb_estimator.closeWaitbar(h);
        end
        
        % Save the posterior draws to a .mat file
        if options.saveDraws
            options.pathToSave = nb_saveDraws(options.name,posterior);
        else
            options.pathToSave = '';
        end
        % Get estimation results
        %--------------------------------------------------
        res            = struct();
        res.beta       = beta;
        res.stdBeta    = stdBeta;
        res.sigma      = sigma;
        res.stdSigma   = stdSigma;
        res.R          = R;
        res.residual   = residual;
        res.sigma      = sigma;
        res.predicted  = yObs - residual;
        res.regressors = XX;
        if options.empirical
            if missing
                res.initialLogPosterior = fVal;
            else
                if options.hyperprior
                    res.logPosterior          = fVal;
                    res.logMarginalLikelihood = pY;
                else
                    res.logMarginalLikelihood = fVal;
                end
            end
        else
            switch lower(options.prior.type)
                case 'glp'
                    res.logMarginalLikelihood = pY;
            end
        end

        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            
            [numCoeff,numEq]  = size(beta);
            logLikelihood     = nb_olsLikelihood(residual);
            res.fTest         = nan(1,numEq);
            res.fProb         = nan(1,numEq);          
            res.rSquared      = nan;
            res.adjRSquared   = nan;
            res.logLikelihood = logLikelihood;
            res.aic           = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
            res.sic           = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
            res.hqc           = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
            res.dwtest        = nb_durbinWatson(residual);
            res.archTest      = nb_archTest(residual,round(options.nLagsTests));
            res.autocorrTest  = nb_autocorrTest(residual,round(options.nLagsTests));
            res.normalityTest = nb_normalityTest(residual,numCoeff);
            [res.SERegression,res.sumOfSqRes]  = nb_SERegression(residual,numCoeff);

            % Full system 
            res.fullLogLikelihood = nb_olsLikelihood(residual,'full');
            res.aicFull           = nb_infoCriterion('aic',res.fullLogLikelihood,T,numCoeff);
            res.sicFull           = nb_infoCriterion('sic',res.fullLogLikelihood,T,numCoeff);
            res.hqcFull           = nb_infoCriterion('hqc',res.fullLogLikelihood,T,numCoeff);
            
        end
        
        % Report filtering/estimation dates
        if mfvar || missing
        
            dataStart           = nb_date.date2freq(options.dataStartDate);
            res.filterStartDate = toString(dataStart + options.estim_start_ind - 1);
            res.filterEndDate   = toString(dataStart + options.estim_end_ind - 1);
            res.realTime        = false;
            
            if extra
                H  = H(:,1:nDep*nLags,:);
                ys = ys(:,1:nDep*nLags);
            end
            if mfvar 
                % Append the low frequency smoothed variables
                [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariables(options,ys,H,tempDep);
            else
                allEndo = [tempDep,nb_cellstrlag(tempDep,options.nLags-1)];
                exo     = strcat('E_',tempDep);
            end
            res.smoothed.variables = struct('data',ys,'startDate',res.filterStartDate,'variables',{allEndo});
            res.smoothed.shocks    = struct('data',residual,'startDate',res.filterStartDate,'variables',{exo});
        
        end
        
    end

    % Assign generic results
    res.includedObservations = size(y,1);
    res.elapsedTime          = toc(tStart);
    
    % Assign results
    results           = res;
    options.estimator = 'nb_bVarEstimator';
    options.estimType = 'bayesian';
    
end

%==========================================================================
function check(prior,mfvar,missing)

    if mfvar || missing
        giveErr = true;
    else
        switch lower(prior.type)
            case 'minnesota'
                method = 'mci';
                if isfield(prior,'method')
                    method = prior.method;
                end
                if strcmpi(method,'mci')
                    giveErr = false;
                else
                    giveErr = true;
                end
            case 'inwishart'
                giveErr = true;
            otherwise
                giveErr = false;
        end
    end

    if giveErr
        error([mfilename ':: The posterior does not have a analytical solution, so you need to draw from ',...
                         'the posterior to estimate the model. Set draws to a number > 500 (at least!).'])
    end
    
end
