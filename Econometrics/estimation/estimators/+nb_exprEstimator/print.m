function res = print(results,options,precision)
% Syntax:
%
% res = nb_exprEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_exprEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_exprEstimator.estimate function.
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
    
    type  = getMethod(results,options);
    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end

    res = sprintf(['Method: Least Squares ' extra]);
    res = char(res,sprintf('STD: %s',type));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get sample
    dataStart      = options.dataStartDate;
    dataStart      = nb_date.date2freq(dataStart);
    startInd       = options.estim_start_ind;
    endInd         = options.estim_end_ind;
    start          = dataStart + (startInd - 1);
    finish         = dataStart + (endInd - 1);
    startRecursive = options.recursive_estim_start_ind - startInd + 1;
    
    % Print 
    dates  = start:finish;
    dates  = dates(startRecursive:end)';
    numObs = size(dates,2);
    dep    = options.dependent;
    numDep = length(dep);
    for ii = 1:numDep
        
        % Create the table for equation ii
        beta                 = permute(results.beta{ii},[1,3,2]);
        stdBeta              = permute(results.stdBeta{ii},[1,3,2]);
        [exo,numExo]         = nb_exprEstimator.getCoeff(options,ii);
        res                  = char(res,'');
        res                  = char(res,['Estimation result for equation: ' dep{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numExo*2 + 1,numObs + 1);
        table(2:2:end,2:end) = nb_double2cell(beta,precision);
        table(3:2:end,2:end) = nb_double2cell(stdBeta,precision);
        table(2:2:end,1)     = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end

end

%--------------------------------------------------------------------------
function res = normalPrint(results,options,precision)

    type = getMethod(results,options);
    nDep = size(results.beta,2);
    res  = '';
    for ii = 1:nDep
    
        if nDep > 1
            res = char(res,['Equation: ' int2str(ii)]);
        end
        
        % Information on estimated equation
        res = char(res,'Method: Least Squares');
        res = char(res,sprintf('STD: %s',type));
        res = char(res,sprintf('%s',nb_clock('gui')));
        res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
        res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations(ii))));

        % Equation estimation results
        beta         = results.beta{ii};
        stdBeta      = results.stdBeta{ii};
        tStatBeta    = results.tStatBeta{ii};
        pValBeta     = results.pValBeta{ii};
        numPar       = size(beta,1);
        table        = cell(numPar*4 + 1,2);
        [exo,numExo] = nb_exprEstimator.getCoeff(options,ii);

        % Fill table
        table{1,1}           = 'Variable';
        table(1,2:end)       = options.dependent(ii);
        table(2:4:end,1)     = exo;
        table(3:4:end,1)     = repmat({'(Std. Error)'},numExo,1);
        table(4:4:end,1)     = repmat({'(t-Statistics)'},numExo,1);
        table(5:4:end,1)     = repmat({'(P-Value)'},numExo,1);
        table(2:4:end,2:end) = nb_double2cell(beta,precision);
        table(3:4:end,2:end) = nb_double2cell(stdBeta,precision);
        table(4:4:end,2:end) = nb_double2cell(tStatBeta,precision);
        table(5:4:end,2:end) = nb_double2cell(pValBeta,precision);

        % Convert the test result to a cell matrix on the wanted
        % format
        if ~options.doTests
            tableAsChar = cell2charTable(table);
            res         = char(res,tableAsChar);
        else

            tests = [...
                results.tests{ii}.rSquared;
                results.tests{ii}.adjRSquared;
                results.tests{ii}.SERegression;
                results.tests{ii}.sumOfSqRes;
                results.tests{ii}.logLikelihood;
                results.tests{ii}.fTest;
                results.tests{ii}.fProb;
                results.tests{ii}.aic;
                results.tests{ii}.sic;
                results.tests{ii}.hqc;
                results.tests{ii}.dwtest;
                results.tests{ii}.whiteTest;
                results.tests{ii}.archTest;
                results.tests{ii}.autocorrTest;
                results.tests{ii}.normalityTest];

            tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];
            tests = nb_addStars(tests,16,13,14,15);

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
            testTable   = [testTable,tests]; %#ok<AGROW>
            table       = [table;testTable]; %#ok<AGROW>
            tableAsChar = cell2charTable(table);
            res         = char(res,tableAsChar);
            res         = char(res,' ');
            
        end
        
    end
    res = res(2:end,:); % Remove first line with no content
    
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

