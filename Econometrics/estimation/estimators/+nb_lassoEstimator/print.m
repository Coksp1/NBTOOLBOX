function res = print(results,options,precision)
% Syntax:
%
% res = nb_lassoEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_lassoEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_lassoEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - res       : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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

    res = sprintf('Method: %s',['LASSO' extra]);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get recursive estimation results
    [exo,numExo] = nb_lassoEstimator.getCoeff(options);
   
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
    
    beta = results.beta;
    if isempty(options.recursive_estim_start_ind)
        startRecursive = options.requiredDegreeOfFreedom + size(beta,1);
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
    
    % Print
    stdBeta = results.stdBeta; 
    dates   = start:finish;
    dates   = dates(startRecursive:end)';
    numObs  = size(beta,3);
    dep     = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    numDep  = length(dep);
    for ii = 1:numDep
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
        stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for equation: ' dep{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numExo*2 + 1,numObs + 1);
        table(2:2:end,2:end) = nb_double2cell(betaT,precision);
        table(3:2:end,2:end) = nb_double2cell(stdBetaT,precision);
        table(2:2:end,1)     = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end

end

%--------------------------------------------------------------------------
function res = normalPrint(results,options,precision)

    % Information on estimated equation
    res = sprintf('Method: %s','LASSO');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    if isempty(options.estim_types) % Time-series

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
        if isfield(options,'nStep')
            finish = finish - options.nStep;
            start  = start - options.nStep;
        end
        res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));
        
    end
    res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));

    % Equation estimation results
    beta         = results.beta;
    stdBeta      = results.stdBeta;
    numPar       = size(beta,1);
    numEndo      = size(beta,2);
    table        = cell(numPar*2 + 1,numEndo + 1);
    [exo,numExo] = nb_lassoEstimator.getCoeff(options);

    % Fill table
    firstRow = options.dependent;
    if isfield(options,'block_exogenous')
        firstRow = [firstRow,options.block_exogenous];
    end
    table{1,1}           = 'Variable';
    table(1,2:end)       = firstRow;
    table(2:2:end,1)     = exo;
    table(3:2:end,1)     = repmat({'(Std. Error)'},numExo,1);
    beta                 = nb_double2cell(beta,precision);
    stdBeta              = nb_double2cell(stdBeta,precision);
    table(2:2:end,2:end) = beta;
    table(3:2:end,2:end) = stdBeta;

    % Convert the test result to a cell matrix on the wanted
    % format   
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);
        
end

