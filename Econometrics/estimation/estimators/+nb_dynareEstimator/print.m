function res = print(results,options,precision)
% Syntax:
%
% res = nb_dynareEstimator.print(results,options,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_dsge object when running a Dynare model file that does 
%               estimation.
%
% - options   : A struct with the estimation options from the 
%               nb_dsge object when running a Dynare model file that does 
%               estimation.
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

%     if options.recursive_estim
%         res = resursivePrint(results,options,precision);
%     else
        res = normalPrint(results,options,precision);
%     end
         
end

%==================================================================
% SUB
%==================================================================
function res = resursivePrint(results,options,precision)

    error('Printing recursive estimation results are not yet finished.')

end

%--------------------------------------------------------------------------
function res = normalPrint(results,options,precision)

    % Information on estimated equation
    res = sprintf('Method: %s',options.optimizer);
    res = char(res,'Toolbox: Dynare');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    dataStart = options.dataStartDate;
    dataStart = nb_date.date2freq(dataStart);
    start     = dataStart + options.estim_start_ind;
    finish    = dataStart + options.estim_end_ind;
    res       = char(res,sprintf('Sample: %s : %s',toString(start),toString(finish)));
    res       = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));

    % Equation estimation results
    if ~isfield(results,'xparam1')
        error([mfilename ':: Could not locate estimation results from Dynare estimation.'])
    end
    beta    = results.xparam1;
    stdBeta = results.stdxparam1;
    numPar  = size(beta,1);
    table   = cell(numPar*2 + 1,4);

    % Find distribution names
    if ~isfield(options,'prior')
        error([mfilename ':: Could not locate the prior used for the Dynare estimation.'])
    end
    distrName = options.prior(:,3);
    distrName = cellfun(@func2str,distrName,'uniformOutput',false);
    distrName = strrep(distrName,'nb_distribution.','');
    distrName = strrep(distrName,'_pdf','');
    
    % Fill table
    table{1,1}       = 'Estimated parameters';
    table{1,2}       = 'Estimated mode';
    table{1,3}       = 'Inital values';
    table{1,4}       = 'Prior distribution';
    table(2:2:end,1) = options.prior(:,1);
    table(3:2:end,1) = repmat({'(Std. Error)'},numPar,1);
    beta             = nb_double2cell(beta,precision);
    stdBeta          = nb_double2cell(stdBeta,precision);
    table(2:2:end,2) = beta;
    table(3:2:end,2) = stdBeta;
    table(2:2:end,3) = nb_double2cell(vertcat(options.prior{:,2}),precision);
    table(2:2:end,4) = distrName;

    % Report the likelihood as well
%     likTable          = cell(4,4);
%     likelihoods       = [results.logPosterior,results.logLikelihood,results.logPrior];
%     likTable(:,1)     = {'';'Log-posterior';'Log-likelihood';'Log-prior'}; 
%     likTable(2:end,2) = nb_double2cell(likelihoods,precision);
    
    % Merge the tables and convert to char
    %table       = [table;likTable];
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
    
end
