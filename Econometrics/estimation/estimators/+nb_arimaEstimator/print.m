function res = print(results,options,precision)
% Syntax:
%
% res = nb_arimaEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_arimaEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_arimaEstimator.estimate function.
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
    if isempty(fieldnames(results))
        res = 'Estimation not done.\n';
        return
    end

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

    method = getMethod(options);
    res    = sprintf('Method: %s',[method, extra]);
    res    = char(res,sprintf('%s',nb_clock('gui')));
    res    = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    % Get sample dates
    startD = nb_date.date2freq(options.dataStartDate);
    start  = options.estim_start_ind;
    finish = options.estim_end_ind;
    if isempty(start)
        start = startD;
    else
        start = startD + (start - 1);
    end
    
    if isempty(finish)
        finish = startD + (size(options.data,1) - 1);
    else
        finish = startD + (finish - 1);
    end
    
    % Get coefficients
    [exo,numExo] = nb_arimaEstimator.getCoeff(options);
    
    % Print
    beta           = results.beta;
    stdBeta        = results.stdBeta; 
    dates          = start:finish;
    dates          = dates(end-size(beta,3)+1:end)';
    numObs         = size(beta,3);
    numDep         = size(beta,2);
    for ii = 1:numDep
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
        stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for equation: ' options.dependent{ii}]);
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

    method = getMethod(options);

    % Information on estimated equation
    res = sprintf('Method: %s',method);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    startD = nb_date.date2freq(options.dataStartDate);
    start  = options.estim_start_ind;
    finish = options.estim_end_ind;
    if isempty(start)
        start = startD;
    else
        start = startD + (start - 1);
    end
    
    if isempty(finish)
        finish = startD + (size(options.data,1) - 1);
    else
        finish = startD + (finish - 1);
    end
    res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));
    res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));
    res = char(res,sprintf('Degree of integration: %s',int2str(options.integration)));
    res = char(res,'');
    
    % Equation estimation results
    beta      = results.beta;
    stdBeta   = results.stdBeta;
    tStatBeta = results.tStatBeta;
    pValBeta  = results.pValBeta;
    numPar    = size(beta,1);
    numEndo   = size(beta,2);
    table     = cell(numPar*4 + 1,numEndo + 1);

    % Construct the coeff names
    [exo,numExo] = nb_arimaEstimator.getCoeff(options);

    % Fill table
    table{1,1}           = 'Variable';
    table(1,2:end)       = options.dependent;
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
    if options.doTests
        
        tests = [...
            results.logLikelihood;
            results.aic;
            results.sic;
            results.hqc];

        tests = [repmat({''},1,size(tests,2));nb_double2cell(tests,precision)];

        % Test results
        testTable = {
            '';
            'Log likelihood';
            'Akaike info criterion'; 
            'Schwarz criterion';
            'Hannan-Quinn criterion'};

        testTable   = [testTable,tests];
        table       = [table;testTable];
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
        
    else 
        tableAsChar = cell2charTable(table);
        res         = char(res,tableAsChar);
    end

end

function method = getMethod(options)

    method = 'ARIMA : ';
    switch lower(options.algorithm)
        case 'hr'
            method = [method,'Hannan-Rissanen'];
        case 'ml'
            method = [method,'Maximum likelihood'];
        case 'yw'
            method = [method,'Yule-Walker']; 
    end

end
