function [results,options] = recursiveEstimation(options,y,X,nExo,startLowPeriods)
% Syntax:
%
% [results,options] = nb_midasEstimator.recursiveEstimation(options,...
%                                       y,X,nExo,startLowPeriods)
%
% Description:
%
% Estimate MIDAS model recursivly.
%
% See also:
% nb_midasEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check the sample
    if strcmpi(options.algorithm,'unrestricted')
        numCoeff = size(X,2) + options.constant + options.AR;
    elseif strcmpi(options.algorithm,'beta')
        numCoeff = 1 + nExo + options.constant + options.AR;
    elseif strcmpi(options.algorithm,'mean')
        numCoeff = nExo + options.constant + options.AR;
    else
        numCoeff = sum(options.polyLags) + options.constant + options.AR;
    end
    T                       = size(y,1);
    [start,iter,ss,options] = checkDOFRecursive(options,numCoeff + options.nStep,T);
    
    % Create waiting bar window
    waitbar = false;
    if options.waitbar && ~strcmpi(options.algorithm,'unrestricted')
        h = nb_estimator.openWaitbar(options,iter);
        if ~isempty(h)
            waitbar = true;       
            h.lock  = 2;
            note    = nb_when2Notify(iter);
        end
    else
        h = false;
    end

    % Estimate the model recursively
    %--------------------------------------------------
    beta     = nan(numCoeff,options.nStep,iter);
    stdBeta  = nan(numCoeff,options.nStep,iter);
    constant = options.constant;
    stdType  = options.stdType;
    residual = nan(T-1,options.nStep,iter);
    sigma    = nan(options.nStep,options.nStep,iter);
    if options.draws > 1
        betaD  = nan(numCoeff,options.nStep,options.draws,iter);
        sigmaD = nan(options.nStep,options.nStep,options.draws,iter);
    else
        betaD  = nan(0,0,0,iter);
        sigmaD = nan(0,0,0,iter);
    end
    kk = 1;
    for tt = start:T
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,residual(ss(kk):tt-1,:,kk),sigma(:,:,kk),betaD(:,:,:,kk),sigmaD(:,:,:,kk)] = ...
            nb_midasFunc(y(ss(kk):tt,:),X(ss(kk):tt,:),constant,options.AR,options.algorithm,...
                   options.nStep,stdType,nExo,options.nLags+1,'draws',options.draws,'polyLags',options.polyLags);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end                                                            
        kk = kk + 1;  
    end

    % Get estimation results
    %--------------------------------------------------
    results          = struct();
    results.beta     = beta;
    results.stdBeta  = stdBeta;
    results.sigma    = sigma;
    results.residual = residual;
    results.betaD    = betaD;
    results.sigmaD   = sigmaD;
    
    % Get recursive estimation start ind of low frequency
    options.recursive_estim_start_ind_low = options.start_low_in_low + (start - 1);
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end

end

function [start,iter,ss,options] = checkDOFRecursive(options,numCoeff,T)
% Here we need to take care of that somthing is in low frequency:
% - T, numCoeff, options.rollingWindow + all outputs
% 
% While something is in high frequency:
% - options.recursive_estim_start_ind, options.estim_start_ind

    [sDataDate,options.dataFrequency] = nb_date.date2freq(options.dataStartDate);
    sDataDateL    = convert(sDataDate,options.frequency);
    sDate         = sDataDate + (options.estim_start_ind - 1);
    startL        = convert(sDate,options.frequency);
    
    fact        = options.dataFrequency/options.frequency;
    startInd    = (startL - sDataDateL) + 1;
    options     = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    if isempty(options.rollingWindow)
    
        if isempty(options.recursive_estim_start_ind)
            start = options.requiredDegreeOfFreedom + numCoeff;
            options.recursive_estim_start_ind = start*fact + options.estim_start_ind - 1;
        else
            recStartDate  = sDataDate + (options.recursive_estim_start_ind - 1);
            recStartDateL = convert(recStartDate,options.frequency);
            recStartInd   = (recStartDateL - sDataDateL) + 1;
            start         = recStartInd - startInd + 1;
            if start < options.requiredDegreeOfFreedom + numCoeff
                startDate = sDataDate + (options.estim_start_ind - 1 + (options.requiredDegreeOfFreedom + numCoeff)*fact);
                error([mfilename ':: The start period (' toString(recStartDate) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' ...
                    toString(startDate) ').'])
            end
        end
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The sample is too short for recursive estimation. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. ',...
                'Which require a sample of at least ' int2str((options.requiredDegreeOfFreedom - numCoeff)*fact),...
                ' observations.'])
        end
        ss = ones(1,iter);
        
    else
        
        if isempty(options.recursive_estim_start_ind)
            start                             = options.rollingWindow;
            options.recursive_estim_start_ind = start*fact + options.estim_start_ind - 1;
        else
            recStartDate  = sDataDate + (options.recursive_estim_start_ind - 1);
            recStartDateL = convert(recStartDate,options.frequency);
            recStartInd   = (recStartDateL - sDataDateL) + 1;
            if options.rollingWindow > recStartInd - startInd + 1
                startDate = sDataDate + (options.estim_start_ind - 1 + (options.rollingWindow)*fact);
                error([mfilename ':: The recursive_estim_start_date (' toString(recStartDate) ') results in an first estimation window with less ',...
                                 'observation at low frequency (' int2str(recStartInd - startInd + 1) ') '...
                                 'then specified by the rollingWindow (' int2str(options.rollingWindow) ') input. Need it to be ' toString(startDate)])
            end
            start = recStartInd - startInd + 1;
        end
        if options.requiredDegreeOfFreedom + numCoeff > start
            error([mfilename ':: The rolling window length is to short. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. ',...
                'Which require a window of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff),...
                ' observations at low frequency.'])
        end
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The rolling window length is longer than the estimation period.']);
        end
        first = (start - options.rollingWindow) + 1;
        last  = (T - options.rollingWindow) + 1;
        ss    = first:last;
        
    end


end
