function res = print(results,options,precision)
% Syntax:
%
% res = nb_statespaceEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_statespaceEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_statespaceEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - results : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<3
        precision = '';
    end
    
    precision = nb_estimator.interpretPrecision(precision);
    if options.recursive_estim
        res = resursivePrint(results,options,precision);
    else
        res = normalPrint(results,options,precision);
    end
         
end

%==================================================================
% SUB
%==================================================================
function res = resursivePrint(results,options,precision)

    error('Printing recursive estimation results are not yet finished.')

end

%--------------------------------------------------------------------------
function res = normalPrint(results,options,precision)

    if isfield(results,'fval') % User defined objective!
        normalEst = false;
    else
        normalEst = true;
    end

    % Information on estimated equation
    res = sprintf('Method: %s',options.optimizer);
    res = char(res,'Toolbox: NB');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    if normalEst
        dataStart = options.dataStartDate;
        dataStart = nb_date.date2freq(dataStart);
        start     = dataStart + (options.estim_start_ind - 1);
        finish    = dataStart + (options.estim_end_ind - 1);
        res       = char(res,sprintf('Sample: %s : %s',toString(start),toString(finish)));
        res       = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));
    end
    
    % Equation estimation results
    beta    = results.beta(results.estimationIndex,:);
    stdBeta = results.stdBeta;
    if options.parser.nBreaks > 0
        [beta,stdBeta,isNotBreakD] = addBreakPoints(options,beta,stdBeta,options.prior(:,1));
    else
        isNotBreakD = true(size(beta,1),1);
    end
    numPar = size(beta,1);
    table  = cell(numPar*2 + 1,4);
   
    % Find distribution names
    distrName = options.prior(isNotBreakD,3);
    distrName = cellfun(@func2str,distrName,'uniformOutput',false);
    distrName = strrep(distrName,'nb_distribution.','');
    distrName = strrep(distrName,'_pdf','');
    for ii = 1:length(distrName)
        if strcmpi(distrName{ii},'truncated') 
            priorInp = options.prior{ii,4};
            lb       = priorInp{3};
            ub       = priorInp{4};
            if isempty(ub)
                ub = 'inf';
            else
                ub = nb_num2str(ub);
            end
            if isempty(lb)
                lb = '-inf';
            else
                lb = nb_num2str(lb);
            end
            distrName{ii} = [priorInp{1}, '[', lb, ',', ub,']'];
        end
    end
    
    % Fill table
    table{1,1}       = 'Estimated parameters';
    table{1,2}       = 'Estimated mode';
    table{1,3}       = 'Inital values';
    table{1,4}       = 'Prior distribution';
    table(2:2:end,1) = options.prior(isNotBreakD,1);
    table(3:2:end,1) = repmat({'(Std. Error)'},numPar,1);
    table(2:2:end,2) = nb_double2cell(beta,precision);
    table(3:2:end,2) = nb_double2cell(stdBeta,precision);
    table(2:2:end,3) = nb_double2cell(vertcat(options.prior{isNotBreakD,2}),precision);
    table(2:2:end,4) = distrName;

    % Report the likelihood as well
    if normalEst
        sytemPriorUsed = false;
        if isfield(results,'logSystemPrior')
            if ~isempty(results.logSystemPrior)
                sytemPriorUsed = true;
            end
        end
        if sytemPriorUsed
            fvalTable          = cell(5,4);
            likelihoods        = [results.logPosterior,results.logLikelihood,results.logPrior,results.logSystemPrior];
            fvalTable(:,1)     = {'';'Log-posterior';'Log-likelihood';'Log-prior';'Log-system-prior'}; 
            fvalTable(2:end,2) = nb_double2cell(likelihoods,precision);
        else
            fvalTable          = cell(4,4);
            likelihoods        = [results.logPosterior,results.logLikelihood,results.logPrior];
            fvalTable(:,1)     = {'';'Log-posterior';'Log-likelihood';'Log-prior'}; 
            fvalTable(2:end,2) = nb_double2cell(likelihoods,precision);
        end
    else
        fvalTable          = cell(2,4);
        fvalTable(:,1)     = {'';'Objective value'}; 
        fvalTable(2:end,2) = nb_double2cell(results.fval,precision);
    end
    if isfield(results,'laplaceApproxML')
        fvalTableML      = cell(1,size(fvalTable,2));
        fvalTableML{1,1} = 'Log-ML (laplace approx)';
        fvalTableML(1,2) = nb_double2cell(results.laplaceApproxML,precision);
        fvalTable        = [fvalTable;fvalTableML];
    end
    table = [table;fvalTable];
    
    % Report estimation of break-points
    if any(~isNotBreakD)
        breakTable = reportBreaks(results,options,isNotBreakD);
        table      = [table;breakTable];
    end
    
    % Merge the tables and convert to char
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end

%==========================================================================
function breakTable = reportBreaks(results,options,isNotBreakD)

    betaBreak       = results.estimatedValues(~isNotBreakD);
    numEstBreak     = size(betaBreak,1);
    breakTable      = cell(numEstBreak + 3,4);
    breakTable(1,:) = {'','','',''};
    breakTable(2,:) = {'Timing of breaks:','','',''};
    breakTable(3,:) = {'Initial value','Estimated','',''};
    nBreaks         = options.parser.nBreaks;
    breakPoints     = options.parser.breakPoints;
    kk              = 4;
    for ii = 1:nBreaks
        breakP      = strcat('break_',toString(breakPoints(ii).date));
        [indB,locB] = ismember(breakP,options.prior(:,1));
        if any(indB)
            breakTable{kk,1} = toString(breakPoints(ii).date - round(results.estimatedValues(locB)));
            breakTable{kk,2} = toString(breakPoints(ii).date);
            kk               = kk + 1;
        end
    end
        
end

%==========================================================================
function [betaNew,stdBetaNew,isNotBreakD] = addBreakPoints(options,beta,stdBeta,estimated)

    [breakP,values,stdvalues] = nb_dsge.getBreakPointParameters(options.parser,false);
    breakD                    = nb_dsge.getBreakTimingParameters(options.parser,false);
    isNotBreakD               = ~ismember(estimated,breakD);
    estimated                 = estimated(isNotBreakD); % Estimation of the timing of break are reported elsewhere!
    isBreakP                  = ismember(estimated,breakP); 
    betaNew                   = nan(length(isBreakP),1);
    stdBetaNew                = nan(length(isBreakP),1);
    betaNew(isBreakP)         = values;
    betaNew(~isBreakP)        = beta;
    stdBetaNew(isBreakP)      = stdvalues;
    stdBetaNew(~isBreakP)     = stdBeta;
    
end

