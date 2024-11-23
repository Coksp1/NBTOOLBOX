function res = print(results,options,precision)
% Syntax:
%
% res = nb_olsEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_olsEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_olsEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - res       : A char with the estimation results.
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
    
    type  = getMethod(results,options);
    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end

    res = sprintf('Method: %s',['Least Squares' extra]);
    res = char(res,sprintf('STD: %s',type));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get recursive estimation results
    [exo,numExo] = nb_olsEstimator.getCoeff(options);
   
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
    if options.nStep > 0
        dep = nb_cellstrlead(options.dependent,options.nStep,'varFast');
    else
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep,options.block_exogenous];
        end
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

    type = getMethod(results,options);

    % Information on estimated equation
    res = sprintf('Method: %s','Least Squares');
    res = char(res,sprintf('STD: %s',type));
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
            finish         = finish - options.nStep;
            start          = start - options.nStep;
        end
        res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));
        
    end
    res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));

    % Equation estimation results
    beta         = results.beta;
    stdBeta      = results.stdBeta;
    tStatBeta    = results.tStatBeta;
    pValBeta     = results.pValBeta;
    numPar       = size(beta,1);
    numEndo      = size(beta,2);
    table        = cell(numPar*4 + 1,numEndo + 1);
    [exo,numExo] = nb_olsEstimator.getCoeff(options);

    % Fill table
    if options.nStep > 0
        dep = nb_cellstrlead(options.dependent,options.nStep,'varFast');
    else
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep,options.block_exogenous];
        end
    end
    table{1,1}           = 'Variable';
    table(1,2:end)       = dep;
    table(2:4:end,1)     = exo;
    table(3:4:end,1)     = repmat({'(Std. Error)'},numExo,1);
    table(4:4:end,1)     = repmat({'(t-Statistics)'},numExo,1);
    table(5:4:end,1)     = repmat({'(P-Value)'},numExo,1);
    beta                 = nb_double2cell(beta,precision);
    stdBeta              = nb_double2cell(stdBeta,precision);
    tStatBeta            = nb_double2cell(tStatBeta,precision);
    pValBeta             = nb_double2cell(pValBeta,precision);
    table(2:4:end,2:end) = beta;
    table(3:4:end,2:end) = stdBeta;
    table(4:4:end,2:end) = tStatBeta;
    table(5:4:end,2:end) = pValBeta;

    % Convert the test result to a cell matrix on the wanted
    % format
    if ~options.doTests
        
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        
    else
        
        tests = [...
            results.rSquared;
            results.adjRSquared;
            results.SERegression;
            results.sumOfSqRes;
            results.logLikelihood;
            results.fTest;
            results.fProb;
            results.aic;
            results.sic;
            results.hqc;
            results.dwtest;
            results.whiteTest;
            results.archTest;
            results.autocorrTest;
            results.normalityTest];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
        tests = nb_addStars(tests,16,13,14,15,round(options.nLagsTests));
        
        % Test results
        testTable = {
            '';
            'R-squared';
            'Adjusted R-squared'; 
            'S.E. of regression';
            'Sum squared residuals'; 
            'Log likelihood';
            'F-statistic';
            'P-value(F-statistic)';
            'Akaike info criterion'; 
            'Schwarz criterion';
            'Hannan-Quinn criterion';
            'Durbin-Watson statistic';
            'White test';
            ['Arch test(' int2str(options.nLagsTests) ')'];
            ['Autocorrelation test(' int2str(options.nLagsTests) ')'];
            'Normality test'};
        testTable   = [testTable,tests];
        table       = [table;testTable];
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);

        % Aslo report full statistics if we have a system of eq
        if size(tests,2) > 1

            res = char(res,'');
            res = char(res,'Full system:');
            res = char(res,'');

            tests = [...
            results.fullLogLikelihood;
            results.aicFull;
            results.sicFull;
            results.hqcFull];

            tests = nb_double2cell(tests,precision);

            testTable = {
            'Log likelihood';
            'Akaike info criterion'; 
            'Schwarz criterion';
            'Hannan-Quinn criterion'};

            testTable   = [testTable,tests];
            tableAsChar = cell2charTable(testTable);
            res         = char(res,tableAsChar);

        end
        
    end
    
end

%==========================================================================
function type = getMethod(results,options)

    if isfield(results,'standardErrorMethod')
        type = results.standardErrorMethod;
    else
        switch lower(options.stdType) 
            case 'w'
                type = 'White heteroskedasticity robust'; 
            case 'nw'
                type = 'Newey-West heteroskedasticity and autocorrelation robust'; 
            case 'h'
                type = 'Homoskedasticity only'; 
            otherwise  
                type = options.stdType; 
        end
    end
    
end

