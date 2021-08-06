function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_statespaceEstimator.estimate(options)
%
% Description:
%
% Estimate a state-space model using the NB Toolbox.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_statespaceEstimator.template. See also 
%              nb_statespaceEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change when for example setting
%             default estimation dates.
%
% See also:
% nb_statespaceEstimator.print, nb_statespaceEstimator.help, 
% nb_statespaceEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'class','');

    % Get objective to maximize
    getObjectiveFunction = options.getObjectiveFunc;
    if ischar(options.getObjectiveFunc)
        getObjectiveFunction = str2func(getObjectiveFunction); 
    end
    [fh,estStruct,lb,ub,opt,options] = getObjectiveFunction(options);
    opt.displayer.names              = estStruct.estimated;
    
    % Get constraints as function handle
    constrFunc = nb_model_parse.constraints2func(options.parser,options.prior(:,1));
    
    % Do the estimation
    %------------------------------------------------------
    if options.recursive_estim

        error([mfilename ':: Recursive estimation is not yet supported for estimation of DSGE models solved using NB Toolbox.'])

    %======================
    else % Not recursive
    %======================
          
        init = estStruct.init;
        if any(strcmpi(options.optimizer,{'nb_abc','bee_gate'}))
            [lb,ub] = nb_estimator.getBounds(options.prior,lb,ub);
        elseif any(strcmpi(options.optimizer,{'nb_fmin'}))
            opt.initialC = getPriorSTD(estStruct);
            opt.tau      = 100;
        elseif isfield(opt,'Display')
            opt.Display = 'iter';
        end
        [estPar,fval,Hessian] = nb_callOptimizer(options.optimizer,fh,init,lb,ub,opt,...
            ':: Estimation of the state-space model failed.','NONLCON',constrFunc,...
            estStruct);
        
        % Get standard deviation of estimated parameters
        omega     = Hessian\eye(size(Hessian,1));
        stdEstPar = sqrt(diag(omega));
        if any(~isreal(stdEstPar))
            if options.covrepair
                omega     = nb_covrepair(omega,false);
                stdEstPar = sqrt(diag(omega));
            else
                warning([mfilename ':: Standard error of paramters are not real, something went wrong...'])
            end
        end
        
        % Evaluate prior
        getObjectiveFunctionStr = func2str(getObjectiveFunction);
        if strcmpi(getObjectiveFunctionStr,'nb_dsge.getObjectiveForEstimation')
            normalEst = true;
        else
            normalEst = false;
        end
            
        if normalEst
            logPrior       = nb_model_generic.evaluatePrior(options.prior,estPar);
            logSystemPrior = [];
            if isfield(estStruct.options,'systemPrior')
                if ~isempty(estStruct.options.systemPrior)
                    systemPriorObjective = str2func([options.class '.systemPriorObjective']);
                    logSystemPrior       = systemPriorObjective(estPar,estStruct);
                    logSystemPrior       = logSystemPrior - logPrior;
                end
            end
        end
        
        % Get estimation results
        %--------------------------------------------------
        res = struct();
        if strcmpi(options.class,'nb_dsge') 
            beta = estStruct.beta;
            if normalEst
                beta(estStruct.indPar) = estPar(~estStruct.isBreakP);
                res.beta               = beta;
                res.stdBeta            = stdEstPar(~estStruct.isBreakP);
            else
                beta(estStruct.indPar) = estPar;
                res.beta               = beta;
                res.stdBeta            = stdEstPar;
            end
        else
            res.beta(estStruct.indPar) = estPar;
            res.stdBeta                = stdEstPar;
        end
        res.sigma = nan(0,1);
        res.omega = omega;
        if normalEst
            res.logPosterior   = -fval;
            res.logPrior       = logPrior;
            res.logSystemPrior = logSystemPrior;
            if isempty(res.logSystemPrior)
                res.logLikelihood = res.logPosterior - logPrior;
            else
                res.logLikelihood = res.logPosterior - logPrior - logSystemPrior;
            end
        else
            res.fval = fval;
        end
        
        % Assign to breakPoints struct
        %----------------------------------------------------
        if strcmpi(options.class,'nb_dsge') && normalEst
            if any(estStruct.isBreakP)
                options = assignBreakPoints(options,estStruct.estimated(estStruct.isBreakP),estPar(estStruct.isBreakP),stdEstPar(estStruct.isBreakP));
                options = assignTimingOfBreaks(options,estStruct.estimated(estStruct.isTimeOfBreakP),estPar(estStruct.isTimeOfBreakP));
            end
        end
         
    end

    % Assign generic results
    if normalEst
        res.includedObservations = options.estim_end_ind - options.estim_start_ind + 1;
        % res.filterStartDate      = toString(start);
        % res.filterEndDate        = toString(finish);
    else
        res.includedObservations = 0;
    end
    res.elapsedTime = toc(tStart);

    % Indicator of estimation
    isEstimated                   = false(size(res.beta,1),1);
    isEstimated(estStruct.indPar) = true;
    res.isEstimated               = isEstimated;
    res.estimationIndex           = estStruct.indPar;
    res.estimatedValues           = estPar;
    
    % Assign results
    results             = res;
    options.estimator   = 'nb_statespaceEstimator';
    if ~normalEst
        options.estimType = 'userDefined';
        if options.draws > 1
            warning('nb_statespaceEstimator:drawsNotSupported',...
                    [mfilename ':: When having a user spesified objective it is not possible to produce draws from the parameter distribution.'])
        end
    elseif nb_isempty(options.prior)
        options.estimType = 'classic';
        if options.draws > 1
            warning('nb_statespaceEstimator:drawsNotSupported',...
                    [mfilename ':: To bootstrap the parameters is not yet possible.'])
        end
    else
        options.estimType = 'bayesian';
        
        % Assign default posterior draws options
        postOpt    = options.sampler_options;
        postOpt.lb = lb;
        postOpt.ub = ub;
        posterior  = struct('objective',@(x)-fh(x,estStruct),'betaD',res.beta(estStruct.indPar),...
                           'sigmaD',nan(0,1),'type','statespace',...
                           'options',postOpt,'omega',omega,...
                           'output',struct());
                       
        % Draw from the posterior
        if options.draws > 1
            [~,~,posterior] = nb_statespaceEstimator.sampler(posterior);
        end               
          
        % Save down posterior draws
        options.pathToSave = nb_saveDraws(options.name,posterior);
        
    end
    
end

%==========================================================================
function options = assignTimingOfBreaks(options,estimatedBreak,estParBreak)

    if isempty(estimatedBreak)
        return
    end

    nBreaks     = options.parser.nBreaks;
    breakPoints = options.parser.breakPoints;
    for ii = 1:nBreaks
        breakP      = strcat('break_',toString(breakPoints(ii).date));
        [indB,locB] = ismember(breakP,estimatedBreak);
        if any(indB)
            breakPoints(ii).date = breakPoints(ii).date + round(estParBreak(locB));
        end
    end
    options.parser.breakPoints = breakPoints;

end

%==========================================================================
function options = assignBreakPoints(options,estimatedBreak,estParBreak,stdParBreak)

    nBreaks     = options.parser.nBreaks;
    breakPoints = options.parser.breakPoints;
    for ii = 1:nBreaks
        breakP      = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).date));
        [indB,locB] = ismember(breakP,estimatedBreak);
        if any(indB)
            breakPoints(ii).values(indB)    = estParBreak(locB);
            breakPoints(ii).stdValues       = nan(size(breakPoints(ii).values));
            breakPoints(ii).stdValues(indB) = stdParBreak(locB);
        end
    end
    options.parser.breakPoints = breakPoints;

end

%==========================================================================
function initialC = getPriorSTD(estStruct)

    numCoeff = size(estStruct.options.prior,1);
    initialC = nan(numCoeff,1);
    for ii = 1:numCoeff
        priorFunc = func2str(estStruct.options.prior{ii,3});
        if strcmpi(priorFunc,'nb_distribution.truncated_pdf')
            priorFunc = strrep(priorFunc,'truncated',estStruct.options.prior{ii,4}{1});
            inputs    = estStruct.options.prior{ii,4}{2};
        else
            inputs    = estStruct.options.prior{ii,4};
        end
        priorFunc    = strrep(priorFunc,'_pdf','_std');
        priorFunc    = str2func(priorFunc);
        initialC(ii) = priorFunc(inputs{:});
    end
    initialC = diag(initialC);
    
end
