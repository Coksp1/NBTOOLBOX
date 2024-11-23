function res = print(results,options,precision)
% Syntax:
%
% res = nb_ecmEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_ecmEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_ecmEstimator.estimate function.
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

    switch lower(options.stdType) 
        case 'w'
            type = 'White heteroskedasticity robust'; 
        case 'nw'
            type = 'Newey-West heteroskedasticity and autocorrelation robust'; 
        case 'h'
            type = 'Homoskedasticity only'; 
        otherwise
            type = '';
    end
    
    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end

    res = sprintf('Method: %s',['Least Squares', extra]);
    res = char(res,sprintf('STD: %s',type));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get recursive estimation results
    [exo,numExo] = nb_ecmEstimator.getCoeff(options);
   
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

    switch lower(options.stdType) 
        case 'w'
            type = 'White heteroskedasticity robust'; 
        case 'nw'
            type = 'Newey-West heteroskedasticity and autocorrelation robust'; 
        case 'h'
            type = 'Homoskedasticity only'; 
        otherwise
            type = '';   
    end

    % Information on estimated equation
    res = sprintf('Method: %s','Least Squares');
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
    beta      = results.beta;
    stdBeta   = results.stdBeta;
    tStatBeta = results.tStatBeta;
    pValBeta  = results.pValBeta;
    numPar    = size(beta,1);
    numEndo   = size(beta,2);
    table     = cell(numPar*4 + 1,numEndo + 1);

    [exo,numExo] = nb_ecmEstimator.getCoeff(options);

    % Fill table
    firstRow = options.dependent;
    if isfield(options,'block_exogenous')
        firstRow = [firstRow,options.block_exogenous];
    end
    table{1,1}           = 'Variable';
    table(1,2:end)       = firstRow;
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

        % Indicate if significant
        pvalNT  = 1 - chi2cdf(results.normalityTest,2);
        indNT   = 16;
        for ii = 1:size(tests,2)

            if pvalNT(ii) < 0.1
                if pvalNT(ii) < 0.05
                    tests{indNT,ii} = ['**' tests{indNT,ii}];
                else
                    tests{indNT,ii} = ['*' tests{indNT,ii}];
                end
            end

        end

        pvalW = results.whiteProb;
        indW  = 13;
        for ii = 1:size(tests,2)

            if pvalW(ii) < 0.1
                if pvalW(ii) < 0.05
                    tests{indW,ii} = ['**' tests{indW,ii}];
                else
                    tests{indW,ii} = ['*' tests{indW,ii}];
                end
            end

        end

        pvalARCHT  = 1 - chi2cdf(results.archTest,5);
        indARCH    = 14;
        for ii = 1:size(tests,2)

            if pvalARCHT(ii) < 0.1
                if pvalARCHT(ii) < 0.05
                    tests{indARCH,ii} = ['**' tests{indARCH,ii}];
                else
                    tests{indARCH,ii} = ['*' tests{indARCH,ii}];
                end
            end

        end

        pvalAT  = 1 - chi2cdf(results.autocorrTest,5);
        indAT   = 15;
        for ii = 1:size(tests,2)

            if pvalAT(ii) < 0.1
                if pvalAT(ii) < 0.05
                    tests{indAT,ii} = ['**' tests{indAT,ii}];
                else
                    tests{indAT,ii} = ['*' tests{indAT,ii}];
                end
            end

        end

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
    
    % Print first stage estimation results for method 'twoStep'
    if strcmpi(options.method,'twoStep')
        
        egRes  = results.egResults;
        models = results.firstStep;
        
        % Print the test result
        %--------------------------------------------------
        res = char(res,'');
        res = char(res,'');
        res = char(res,'Null Hypothesis: Series are not cointegrated.');
        res = char(res,sprintf('%s',nb_clock('gui')));
        if egRes.lagLength ~= -1
            res = char(res,['Lag length: ' int2str(egRes.lagLength + 1) '']);
        end
        if ~isempty(egRes.lagLengthCrit)
            res = char(res,['Lag length criterion: ' egRes.lagLengthCrit '']);
        end

        res         = char(res,'');
        table       = repmat({''},5,4);
        table{1,3}  = 't-Statistic';
        table{1,4}  = 'Prob.*';
        table{2,1}  = 'ADF test statistic';
        table{3,1}  = 'Test critical values';
        table{3,2}  = '1% level';
        table{4,2}  = '5% level';
        table{5,2}  = '10% level';
        table{2,3}  = num2str(egRes.rhoTTest,precision);
        table{2,4}  = num2str(egRes.rhoPValue,precision);
        table{3,3}  = num2str(egRes.rhoCritValue(3),precision);
        table{4,3}  = num2str(egRes.rhoCritValue(2),precision);
        table{5,3}  = num2str(egRes.rhoCritValue(1),precision);
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        res         = char(res,'*MacKinnon (1996) one-sided p-values.');
        res         = char(res,'');

        % Print the estimation result of the test 
        % equation
        %--------------------------------------------------
        res = char(res,nb_olsEstimator.print(models(1).results,models(1).options,precision));
        res = char(res,'');
        res = char(res,nb_olsEstimator.print(models(2).results,models(2).options,precision));
        res = char(res,'');  
        
    else % oneStep
        
        % Print critical values of PCGive test
        indTest          = strcmpi(strcat(strrep(options.dependent,'diff_',''),'_lag1'),exo);
        [critValues,ret] = getCritValues(options);
        if ret 
            extra = '<';
        else 
            extra = '';
        end
        
        % Print the test result
        %--------------------------------------------------
        res = char(res,'');
        res = char(res,'');
        res = char(res,'Null Hypothesis: Series are not cointegrated.');
        res = char(res,sprintf('%s',nb_clock('gui')));

        res         = char(res,'');
        table       = repmat({''},5,3);
        table{1,3}  = 't-Statistic';
        table{2,1}  = 'PCGive test statistic';
        table{3,1}  = 'Test critical values*';
        table{3,2}  = '1% level';
        table{4,2}  = '5% level';
        table{5,2}  = '10% level';
        table{2,3}  = tStatBeta{indTest};
        table{3,3}  = [extra,num2str(critValues(1),precision)];
        table{4,3}  = [extra,num2str(critValues(2),precision)];
        table{5,3}  = [extra,num2str(critValues(3),precision)];
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        res         = char(res,'*PCGive Critical values.');
        res         = char(res,'');
        
    end
    
    
end

%==========================================================================
function [critValues,ret] = getCritValues(options)

    ret   = false;
    nEndo = length(options.endogenous);
    if options.constant
        critTable = [-3.79,-3.21,-2.91;
                     -4.09,-3.51,-3.19;
                     -4.36,-3.76,-3.44;
                     -4.59,-3.99,-3.66];
    else
        critTable = [-4.25,-3.69,-3.39;
                     -4.50,-3.93,-3.62;
                     -4.72,-4.14,-3.83;
                     -4.93,-4.34,-4.03];
    end
    try
        critValues = critTable(nEndo,:)';
    catch %#ok<CTCH>
        critValues = critTable(4,:)';
        ret        = true;
    end
    
end
