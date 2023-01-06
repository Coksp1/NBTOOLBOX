function res = print(results,options,precision)
% Syntax:
%
% res = nb_fmEstimator.print(results,precision)
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

%     type = options.stdType;

    switch lower(options.modelType)
        case 'singleeq'
            modelType = 'Single equation';
        case 'stepahead'
            if options.unbalanced
                modelType = 'Unbalanced step ahead';
            else
                modelType = 'Step ahead';
            end
        case 'dynamic'
            modelType = 'Dynamic';
        case 'favar'
            modelType = 'FA-VAR';
        otherwise
            error([mfilename ':: Unsupported modelType ' options.modelType])  
    end
    
    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end
    
    % Information on estimated equation
    res = sprintf('Method: %s',['Least Squares', extra]);
    res = char(res,sprintf('Model: %s',modelType));
    %res = char(res,sprintf('STD: %s',type));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Equation estimation results
    switch lower(options.modelType)
        case 'dynamic'
            res = printRecursiveDynamic(res,results,options,precision);
        case 'stepahead'
            res = printRecursiveStepAhead(res,results,options,precision); 
        case 'singleeq'
            res = printRecursiveSingleEq(res,results,options,precision);    
        otherwise 
            res = printRecursiveFAVAR(res,results,options,precision);
    end
    
end

%==========================================================================
function res = printRecursiveDynamic(res,results,options,precision)

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
    
    % Print    
    beta = results.beta;
    if isempty(options.recursive_estim_start_ind)
        startRecursive = finish - size(beta,3) + 1;
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
    stdBeta  = results.stdBeta;
    dates    = start:finish;
    dates    = dates(startRecursive:end)';
    numObs   = size(beta,3);
    dep      = [options.dependent,options.factors];
    numDep   = length(options.dependent);
    numEq    = size(beta,2);
    [~,indB] = nb_fmEstimator.getAllDynamicRegressors(options);
    for ii = 1:numEq
        
        if ii > numDep
            ind = numDep + 1;
            exo = options.factorsRHS{ind};
        else 
            ind = ii;
            exo = [options.exogenous{ind},options.factorsRHS{ind}];
            if options.constant && options.time_trend
                exo = [{'Constant','Time Trend'},exo]; %#ok<AGROW>
            elseif options.constant
                exo = [{'Constant'},exo]; %#ok<AGROW>
            elseif options.time_trend
                exo = [{'Time Trend'},exo]; %#ok<AGROW>
            end
        end
        numExo = length(exo);
        
        betaT = permute(beta(indB{ind},ii,:),[1,3,2]);
        if isempty(stdBeta)
            table = repmat({''},numExo + 1,numObs + 1);
            incr  = 1;
        else
            stdBetaT = permute(stdBeta(indB{ind},ii,:),[1,3,2]);
            table    = repmat({''},numExo*2 + 1,numObs + 1);
            incr     = 2;
        end

        % Create the table
        res                     = char(res,'');
        res                     = char(res,['Estimation result for equation: ' dep{ii}]);
        res                     = char(res,'');
        table(2:incr:end,2:end) = nb_double2cell(betaT,precision);
        if ~isempty(stdBeta)
            table(3:incr:end,2:end) = nb_double2cell(stdBetaT,precision);
        end
        table(2:incr:end,1)  = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end
    
end

%==========================================================================
function res = printRecursiveStepAhead(res,results,options,precision)

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
    
    % Get recursive estimation results
    [RHS,numRHS] = nb_fmEstimator.getCoeff(options);
    
    % Print forecasting eq 
    beta           = results.beta;
    startRecursive = options.recursive_estim_start_ind - startInd + 1;
%     stdBeta = results.stdBeta; 
    dates   = start:finish;
    dates   = dates(startRecursive:end)';
    numObs  = size(beta,3);
    dep     = nb_cellstrlead(options.dependent,options.nStep,'varFast');
    numDep  = length(dep);
    for ii = 1:numDep
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
%         stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for forecasting equation: ' dep{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numRHS + 1,numObs + 1);
        table(2:1:end,2:end) = nb_double2cell(betaT,precision);
%         table(3:2:end,2:end) = nb_double2cell(stdBetaT,precision);
        table(2:1:end,1)     = RHS;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end
    
    % Print observation eq 
    res = char(res,'');
    res = printRecObservationEq(res,results,options,precision,dates);

end

%==========================================================================
function res = printRecursiveSingleEq(res,results,options,precision)

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
    
    % Get recursive estimation results
    [RHS,numRHS] = nb_fmEstimator.getCoeff(options);
     
    % Print forecasting eq 
    beta           = results.beta;
    startRecursive = options.recursive_estim_start_ind - startInd + 1;
%     stdBeta = results.stdBeta; 
    dates   = start:finish;
    dates   = dates(startRecursive:end)';
    numObs  = size(beta,3);
    dep     = options.dependent;
    numDep  = length(dep);
    for ii = 1:numDep
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
%         stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for final equation: ' dep{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numRHS + 1,numObs + 1);
        table(2:1:end,2:end) = nb_double2cell(betaT,precision);
%         table(3:2:end,2:end) = nb_double2cell(stdBetaT,precision);
        table(2:1:end,1)     = RHS;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end
    
    % Print observation eq 
    res = char(res,'');
    res = printRecObservationEq(res,results,options,precision,dates);

end

%==========================================================================
function res = printRecursiveFAVAR(res,results,options,precision)

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
    
    % Print    
    beta = results.beta;
    if isempty(options.recursive_estim_start_ind)
        startRecursive = options.requiredDegreeOfFreedom + size(beta,1);
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
%     stdBeta = results.stdBeta; 
    dates   = start:finish;
    dates   = dates(startRecursive:end)';
    numObs  = size(beta,3);
    dep     = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    dep          = [dep,options.factors];
    numDep       = length(dep);
    [exo,numExo] = nb_fmEstimator.getCoeff(options);
    for ii = 1:numDep
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
%         stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for equation: ' dep{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numExo + 1,numObs + 1);
        table(2:1:end,2:end) = nb_double2cell(betaT,precision);
%         table(3:2:end,2:end) = nb_double2cell(stdBetaT,precision);
        table(2:1:end,1)     = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end
    
    % Print observation eq 
    res = char(res,'');
    res = printRecObservationEq(res,results,options,precision,dates);

end

%==========================================================================
function res = printRecObservationEq(res,results,options,precision,dates)

    res = char(res,'Factor estimation');
    res = char(res,'Method: Principal component');
    res = char(res,'');

    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    [exo,numExo] = nb_fmEstimator.getCoeff(options,true);
    lambda       = results.lambda;
    numObs       = size(lambda,3);
    obser        = options.observables;
    numObser     = length(obser);
    for ii = 1:numObser
        
        lambdaT = permute(lambda(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for observation equation: ' obser{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numExo + 1,numObs + 1);
        table(2:end,2:end)   = nb_double2cell(lambdaT,precision);
        table(2:end,1)       = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end

end

%==========================================================================
function res = normalPrint(results,options,precision)

    type = options.stdType;

    switch lower(options.modelType)
        case 'singleeq'
            modelType = 'Single equation';
        case 'stepahead'
            if options.unbalanced
                modelType = 'Unbalanced step ahead';
            else
                modelType = 'Step ahead';
            end
        case 'dynamic'
            modelType = 'Dynamic';
        case 'favar'
            modelType = 'FA-VAR';
        otherwise
            error([mfilename ':: Unsupported modelType ' options.modelType]) 
    end
    
    % Information on estimated equation
    res = sprintf('Method: %s','Least Squares');
    res = char(res,sprintf('Model: %s',modelType));
    res = char(res,sprintf('STD: %s',type));
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

    % Equation estimation results
    switch lower(options.modelType)
        case 'dynamic'
            res = printNormalDynamic(res,results,options,precision);
        case 'stepahead'
            res = printNormalStepAhead(res,results,options,precision);
        case 'singleeq'
            res = printNormalSingleEq(res,results,options,precision);
        otherwise
            res = printNormalFAVAR(res,results,options,precision);
    end
    
end

%==========================================================================
function res = printNormalStepAhead(res,results,options,precision)

    beta      = results.beta;
    stdBeta   = results.stdBeta;
    
    % Print results for each of the forecasting equations
    %-------------------------------------------------------------------
    numPar   = size(beta,1);
    numEndo  = size(beta,2);
    if isempty(stdBeta)
        table = cell(numPar + 1,numEndo + 1);
        incr  = 1;
    else
        table = cell(numPar*2 + 1,numEndo + 1);
        incr  = 2;
    end

    [exo,numExo] = nb_fmEstimator.getCoeff(options);

    % Fill table
    firstRow                = nb_cellstrlead(options.dependent,options.nStep,'varFast');
    table{1,1}              = 'Variable';
    table(1,2:end)          = firstRow;
    table(2:incr:end,1)     = exo;
    beta                    = nb_double2cell(beta,precision);
    table(2:incr:end,2:end) = beta;
    if ~isempty(stdBeta)
        table(3:incr:end,1)     = repmat({'(Std. Error)'},numExo,1);
        stdBeta                 = nb_double2cell(stdBeta,precision);
        table(3:incr:end,2:end) = stdBeta;
    end

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
            results.archTest;
            results.autocorrTest;
            results.normalityTest];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
        tests = nb_addStars(tests,15,[],13,14);
        
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
            ['Arch test(' int2str(options.nLagsTests) ')'];
            ['Autocorrelation test(' int2str(options.nLagsTests) ')'];
            'Normality test'};

        testTable   = [testTable,tests];
        table       = [table;testTable];
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        
    end
    
    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    res = char(res,'');
    res = printObservationEq(res,results,options,precision);
    
end

%==========================================================================
function res = printNormalSingleEq(res,results,options,precision)

    beta      = results.beta;
    stdBeta   = results.stdBeta;
    
    % Print results for each of the forecasting equations
    %-------------------------------------------------------------------
    numPar   = size(beta,1);
    numEndo  = size(beta,2);
    if isempty(stdBeta)
        table = cell(numPar + 1,numEndo + 1);
        incr  = 1;
    else
        table = cell(numPar*2 + 1,numEndo + 1);
        incr  = 2;
    end

    [exo,numExo] = nb_fmEstimator.getCoeff(options);

    % Fill table
    firstRow                = options.dependent;
    table{1,1}              = 'Variable';
    table(1,2:end)          = firstRow;
    table(2:incr:end,1)     = exo;
    beta                    = nb_double2cell(beta,precision);
    table(2:incr:end,2:end) = beta;
    if ~isempty(stdBeta)
        table(3:incr:end,1)     = repmat({'(Std. Error)'},numExo,1);
        stdBeta                 = nb_double2cell(stdBeta,precision);
        table(3:incr:end,2:end) = stdBeta;
    end

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
            results.archTest;
            results.autocorrTest;
            results.normalityTest];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
        tests = nb_addStars(tests,15,[],13,14);

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
            ['Arch test(' int2str(options.nLagsTests) ')'];
            ['Autocorrelation test(' int2str(options.nLagsTests) ')'];
            'Normality test'};

        testTable   = [testTable,tests];
        table       = [table;testTable];
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        
    end
    
    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    res = char(res,'');
    res = printObservationEq(res,results,options,precision);
    
end

%==========================================================================
function res = printNormalDynamic(res,results,options,precision)

    beta      = results.beta;
    stdBeta   = results.stdBeta;
    numEq     = length(options.dependent) + 1;
    
    % Print results for each of the forecasting equations and the factor 
    % VAR
    %-------------------------------------------------------------------
    [~,indB] = nb_fmEstimator.getAllDynamicRegressors(options);
    for ii = 1:numEq
        
        if ii == numEq
            betaT    = beta(:,ii:end);
            stdBetaT = stdBeta(:,ii:end);
            exo      = options.factorsRHS{ii};
        else
            betaT    = beta(:,ii);
            stdBetaT = stdBeta(:,ii);
            RHS      = [options.exogenous{ii},options.factorsRHS{ii}];
            if options.constant && options.time_trend
                exo = [{'Constant','Time Trend'},RHS{:}];
            elseif options.constant
                exo = [{'Constant'},RHS{:}];
            elseif options.time_trend
                exo = [{'Time Trend'},RHS{:}];
            else
                exo = [{},RHS{:}];
            end
        end
        numExo   = length(exo);
        betaT    = betaT(indB{ii},:);
        stdBetaT = stdBetaT(indB{ii},:);
        numPar   = size(betaT,1);
        numEndo  = size(betaT,2);
        if isempty(stdBetaT)
            table = cell(numPar + 1,numEndo + 1);
            incr  = 1;
        else
            table = cell(numPar*2 + 1,numEndo + 1);
            incr  = 2;
        end
        
        % Fill table
        if ii == numEq
            firstRow = options.factors;
        else
            firstRow = options.dependent(ii);
        end
        table{1,1}              = 'Variable';
        table(1,2:end)          = firstRow;
        table(2:incr:end,1)     = exo;
        betaT                   = nb_double2cell(betaT,precision);
        table(2:incr:end,2:end) = betaT;
        if ~isempty(stdBetaT)
            table(3:incr:end,1)     = repmat({'(Std. Error)'},numExo,1);
            stdBetaT                = nb_double2cell(stdBetaT,precision);
            table(3:incr:end,2:end) = stdBetaT;
        end
        
        % Convert the test result to a cell matrix on the wanted
        % format
        if ~options.doTests
            
            tableAsChar = cell2charTable(table);
            res         = char(res,tableAsChar);
            
        else
            
            if ii == numEq
                tests = [...
                    results.rSquared(ii:end);
                    results.adjRSquared(ii:end);
                    results.SERegression(ii:end);
                    results.sumOfSqRes(ii:end);
                    results.logLikelihood(ii:end);
                    results.fTest(ii:end);
                    results.fProb(ii:end);
                    results.aic(ii:end);
                    results.sic(ii:end);
                    results.hqc(ii:end);
                    results.dwtest(ii:end);
                    results.archTest(ii:end);
                    results.autocorrTest(ii:end);
                    results.normalityTest(ii:end)];
            else
                tests = [...
                    results.rSquared(ii);
                    results.adjRSquared(ii);
                    results.SERegression(ii);
                    results.sumOfSqRes(ii);
                    results.logLikelihood(ii);
                    results.fTest(ii);
                    results.fProb(ii);
                    results.aic(ii);
                    results.sic(ii);
                    results.hqc(ii);
                    results.dwtest(ii);
                    results.archTest(ii);
                    results.autocorrTest(ii);
                    results.normalityTest(ii)];
            end

            tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
            tests = nb_addStars(tests,15,[],13,14);
            
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
                ['Arch test(' int2str(options.nLagsTests) ')'];
                ['Autocorrelation test(' int2str(options.nLagsTests) ')'];
                'Normality test'};

            testTable   = [testTable,tests]; %#ok<AGROW>
            table       = [table;testTable]; %#ok<AGROW>
            tableAsChar = cell2charTable(table);
            res         = char(res,tableAsChar);
            
        end
        
        res = char(res,'');

    end
    
    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    res = char(res,'');
    res = printObservationEq(res,results,options,precision);
    
end

%==========================================================================
function res = printNormalFAVAR(res,results,options,precision)

    beta      = results.beta;
    stdBeta   = results.stdBeta;
    
    % Print results for each of the forecasting equations
    %-------------------------------------------------------------------
    numPar   = size(beta,1);
    numEndo  = size(beta,2);
    if isempty(stdBeta)
        table = cell(numPar + 1,numEndo + 1);
        incr  = 1;
    else
        table = cell(numPar*2 + 1,numEndo + 1);
        incr  = 2;
    end

    [exo,numExo] = nb_fmEstimator.getCoeff(options);

    % Fill table
    firstRow                = [options.dependent,options.factors];
    table{1,1}              = 'Variable';
    table(1,2:end)          = firstRow;
    table(2:incr:end,1)     = exo;
    beta                    = nb_double2cell(beta,precision);
    table(2:incr:end,2:end) = beta;
    if ~isempty(stdBeta)
        table(3:incr:end,1)     = repmat({'(Std. Error)'},numExo,1);
        stdBeta                 = nb_double2cell(stdBeta,precision);
        table(3:incr:end,2:end) = stdBeta;
    end

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
            results.archTest;
            results.autocorrTest;
            results.normalityTest];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
        tests = nb_addStars(tests,15,[],13,14);
        
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

            tests = [nb_double2cell(tests,precision)];

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
    
    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    res = char(res,'');
    res = printObservationEq(res,results,options,precision);
    
end


%==========================================================================
function res = printObservationEq(res,results,options,precision)

    res = char(res,'Factor estimation');
    res = char(res,'Method: Principal component');
    res = char(res,'');

    % Print the estimation result of the observation equation
    %--------------------------------------------------------
    lambda    = results.lambda;
    stdLambda = results.stdLambda;
    numPar    = size(lambda,1);
    numEndo   = size(lambda,2);
    if isempty(stdLambda)
        table = cell(numPar + 1,numEndo + 1);
        incr  = 1;
    else
        table = cell(numPar*2 + 1,numEndo + 1);
        incr  = 2;
    end

    [exo,numExo] = nb_fmEstimator.getCoeff(options,true);

    % Fill table
    firstRow = options.observables;
    if isfield(options,'observablesFast')
        firstRow = [firstRow,options.observablesFast];
    end
    table{1,1}              = 'Variable';
    table(1,2:end)          = firstRow;
    table(2:incr:end,1)     = exo;
    lambda                  = nb_double2cell(lambda,precision);
    table(2:incr:end,2:end) = lambda;
    if ~isempty(stdLambda)
        table(3:incr:end,1)     = repmat({'(Std. Error)'},numExo,1);
        stdLambda               = nb_double2cell(stdLambda,precision);
        table(3:incr:end,2:end) = stdLambda;
    end
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);

end
