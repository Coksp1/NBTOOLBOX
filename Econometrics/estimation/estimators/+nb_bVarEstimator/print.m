function res = print(results,options,precision)
% Syntax:
%
% res = nb_bVarEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_bVarEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_bVarEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - results : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    priorType = getPriorType(options);
    extra     = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end
    
    res = sprintf('Method: %s',[priorType, extra]);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get recursive estimation results
    [exo,numExo] = nb_bVarEstimator.getCoeff(options);
   
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
    if isfield(options,'indObservedOnly')
        dep = dep(~options.indObservedOnly);
    end
    numDep = length(dep);
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

function res = normalPrint(results,options,precision)

    priorType = getPriorType(options);

    % Information on estimated equation
    res = sprintf('Method: %s',priorType);
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
        res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));

    end
    res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));

    % Equation estimation results
    beta         = results.beta;
    stdBeta      = results.stdBeta;
    numPar       = size(beta,1);
    numEndo      = size(beta,2);
    table        = cell(numPar*2 + 1,numEndo + 1);
    [exo,numExo] = nb_bVarEstimator.getCoeff(options);  

    % Fill table
    firstRow = options.dependent;
    if isfield(options,'block_exogenous')
        firstRow = [firstRow,options.block_exogenous];
    end
    if isfield(options,'indObservedOnly')
        firstRow = firstRow(~options.indObservedOnly);
    end
    table{1,1}           = 'Variable';
    table(1,2:end)       = firstRow;
    table(2:2:end,1)     = exo;
    table(3:2:end,1)     = repmat({'(Std. Error)'},numExo,1);
    beta                 = nb_double2cell(beta,precision);
    stdBeta              = nb_double2cell(stdBeta,precision);
    table(2:2:end,2:end) = beta;
    table(3:2:end,2:end) = stdBeta;

    % Print results of hyperparameters
    if options.empirical
        
        % Get estimated hyperparameters
        [hyperParam,nCoeff,betaHyper] = nb_bVarEstimator.getInitAndHyperParam(options);
        for ii = 1:length(hyperParam)
            if nCoeff(ii) > 1
                hyperParam{ii} = nb_appendIndexes(hyperParam{ii},1:nCoeff(ii));
            end
        end
        hyperParam = nb_nestedCell2Cell(hyperParam);
        
        % Create table
        numHyperPar = size(betaHyper,1);
        if options.hyperprior && ~strcmpi(options.prior.type,'glpMF')
            extra = 5;
            e     = 3;
        else
            extra = 4;
            e     = 2;
        end
        hyperTable            = repmat({''},[numHyperPar + extra,numEndo + 1]);
        hyperTable{2,1}       = 'Hyper parameter';
        hyperTable(3:end-e,1) = hyperParam;
        hyperTable(3:end-e,2) = nb_double2cell(betaHyper,precision);
        if strcmpi(options.prior.type,'glpMF')
            hyperTable{end,1} = 'Initital log posterior';
            hyperTable{end,2} = num2str(results.initialLogPosterior,precision);
        else
            if options.hyperprior
                hyperTable{end-1,1} = 'Log posterior';
                hyperTable{end-1,2} = num2str(results.logPosterior,precision);
                hyperTable{end,1}   = 'Log marginal likelihood';
                hyperTable{end,2}   = num2str(results.logMarginalLikelihood,precision);
            else
                hyperTable{end,1} = 'Log marginal likelihood';
                hyperTable{end,2} = num2str(results.logMarginalLikelihood,precision);
            end
        end
        table = [table;hyperTable];
        
    else
        if isfield(results,'logMarginalLikelihood')
            hyperTable        = repmat({''},[2,numEndo + 1]);
            hyperTable{end,1} = 'Log marginal likelihood';
            hyperTable{end,2} = num2str(results.logMarginalLikelihood,precision);
            table             = [table;hyperTable];
        end
    end
    
    % Convert the test result to a cell matrix on the wanted
    % format
    if ~options.doTests
        
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        
    else
        
        tests = [...
            results.logLikelihood;
            results.aic;
            results.sic;
            results.hqc;
            results.dwtest;
            results.archTest;
            results.autocorrTest;
            results.normalityTest];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];

        % Indicate if significant
        pvalNT  = 1 - chi2cdf(results.normalityTest,2);
        indNT   = 9;
        for ii = 1:size(tests,2)

            if pvalNT(ii) < 0.1
                if pvalNT(ii) < 0.05
                    tests{indNT,ii} = ['**' tests{indNT,ii}];
                else
                    tests{indNT,ii} = ['*' tests{indNT,ii}];
                end
            end

        end

        pvalARCHT  = 1 - chi2cdf(results.archTest,5);
        indARCH    = 7;
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
        indAT   = 8;
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
            'Log likelihood';
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
            res = char(res,'Full system (based on the residuals and normality):');
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
function priorType = getPriorType(options)

    switch lower(options.prior.type)
        case 'glp'
            priorType = 'Giannone, Lenza and Primiceri (2014) prior';
        case 'glpmf'
            priorType = 'Missing Observations Giannone, Lenza and Primiceri (2014) prior';
        case 'jeffrey'
            priorType = 'Diffuse Jeffrey Prior';
        case 'minnesota'
            if isfield(options.prior,'method')
                method = options.prior.method;
            else
                method = 'default';
            end
            if strcmpi(method,'mci') || strcmpi(method,'default')
                priorType = 'Minnesota Prior (fixed sigma)';
            else
                priorType = 'Minnesota Prior';
            end
        case 'minnesotamf'
            if strcmpi(options.class,'nb_mfvar')
                priorType = 'Mixed Frequency Minnesota Type Prior';
            else
                priorType = 'Missing Observations Minnesota Type Prior';
            end
        case 'nwishart'
            priorType = 'Normal-Wishart Prior';
        case 'nwishartmf'
            if strcmpi(options.class,'nb_mfvar')
                priorType = 'Mixed Frequency Normal-Wishart Prior';
            else
                priorType = 'Missing Observations Normal-Wishart Prior';
            end
        case 'inwishart' 
            priorType = 'Independent Normal-Wishart Prior'; 
        case 'inwishartmf'
            if strcmpi(options.class,'nb_mfvar')
                priorType = 'Mixed Frequency Independent Normal-Wishart Prior';
            else
                priorType = 'Missing Observations Independent Normal-Wishart Prior';
            end    
    end
    
    LR = false;
    if isfield(options.prior,'LR')
        LR = options.prior.LR;
    end
    if LR
        priorType = [priorType ' (+ prior for the long run)'];
    end
    
    SC = false;
    if isfield(options.prior,'SC')
        SC = options.prior.SC;
    end
    if SC
        priorType = [priorType ' (+ sum-of-coefficient prior)'];
    end
    
    DIO = false;
    if isfield(options.prior,'DIO')
        DIO = options.prior.DIO;
    end
    if DIO
        priorType = [priorType ' (+ dummy-inital-observation prior)'];
    end
    
end
