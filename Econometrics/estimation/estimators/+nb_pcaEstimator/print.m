function res = print(results,options,precision)
% Syntax:
%
% res = nb_pcaEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_fmEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_fmEstimator.estimate function.
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

    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end
    
    % Information on estimated equation
    res = sprintf('Method: %s',['Principal components ', extra]);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get sample
    dataStart = options.dataStartDate;
    dataStart = nb_date.date2freq(dataStart);
    startInd  = options.estim_start_ind;
    endInd    = options.estim_end_ind;
    if isempty(startInd)
        start = dataStart;
    else
        start = dataStart + (startInd - 1);
    end
    if isempty(endInd)
        finish = dataStart + (size(options.data,1) - 1);
    else
        finish = dataStart + (endInd - 1);
    end
    if isempty(options.recursive_estim_start_ind)
        startRecursive = options.requiredDegreeOfFreedom + size(beta,1);
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
    dates = start:finish;
    dates = dates(startRecursive:end)';
    
    [factors,numF] = nb_pcaEstimator.getCoeff(options);
    lambda         = results.lambda;
    numRec         = size(lambda,3);
    obser          = options.observables;
    numObser       = length(obser);
    for ii = 1:numObser
        
        lambdaT = permute(lambda(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for observation equation: ' obser{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numF + 1,numRec + 1);
        table(2:end,2:end)   = nb_double2cell(lambdaT,precision);
        table(2:end,1)       = factors;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end
    
end



%==========================================================================
function res = normalPrint(results,options,precision)

    % Information on estimated equation
    res = sprintf('Method: %s','Principal components');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    dataStart = options.dataStartDate;
    dataStart = nb_date.date2freq(dataStart);
    startInd  = options.estim_start_ind;
    endInd    = options.estim_end_ind;
    if isempty(startInd)
        start = dataStart;
    else
        start = dataStart + (startInd - 1);
    end

    if isempty(endInd)
        finish = dataStart + (size(options.data,1) - 1);
    else
        finish = dataStart + (endInd - 1);
    end
    res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));
    res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));

    % Print the estimation result of the observation equation
    lambda = results.lambda;
    numF   = size(lambda,1);
    numObs = size(lambda,2);
    table  = cell(numF + 1,numObs + 1);

    % Fill table
    fators             = nb_pcaEstimator.getCoeff(options);
    firstRow           = options.observables;
    table{1,1}         = 'Variable';
    table(1,2:end)     = firstRow;
    table(2:end,1)     = fators;
    lambda             = nb_double2cell(lambda,precision);
    table(2:end,2:end) = lambda;
    tableAsChar        = cell2charTable(table);
    res                = char(res,tableAsChar);
    
end
