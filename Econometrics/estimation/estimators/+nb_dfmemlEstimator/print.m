function res = print(results,options,precision)
% Syntax:
%
% res = nb_dfmemlEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_dfmemlEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_dfmemlEstimator.estimate function.
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

    extra = '';
    if isfield(options,'real_time_estim')
        if options.real_time_estim
            extra = ' (real-time)';
        end
    end
    
    % Information on estimated equation
    res = sprintf('Method: %s',['Expected maximum likelihood' extra]);
    res = char(res,sprintf('Model: %s','Dynamic factor model (Banbura et al. (2010))'));
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    res = char(res,'');

    % Equation estimation results
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
    coeff  = nb_dfmemlEstimator.getCoeff(options);
    nCoeff = size(coeff,2);
    beta   = results.beta;
    if isempty(options.recursive_estim_start_ind)
        startRecursive = finish - size(beta,3) + 1;
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
    dates  = start:finish;
    dates  = dates(startRecursive:end)';
    nDates = size(dates,2);

    % Create the table
    table              = cell(nCoeff+1,nDates+1);
    table(2:end,2:end) = nb_double2cell(permute(beta,[1,3,2]),precision);
    table(2:end,1)     = coeff;
    table(1,2:end)     = dates;
    table{1,1}         = 'Estimated parameters';
    tableAsChar        = cell2charTable(table);
    res                = char(res,tableAsChar);
    
end

%==========================================================================
function res = normalPrint(results,options,precision)
    
    % Information on estimated equation
    res = sprintf('Method: %s','Expected maximum likelihood');
    res = char(res,sprintf('Model: %s','Dynamic factor model (Banbura et al. (2010))'));
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
    res = char(res,sprintf('Log likelihood: %s',num2str(-results.likelihood)));
    res = char(res,'');
    
    % Print   
    coeff  = nb_dfmemlEstimator.getCoeff(options);
    nCoeff = size(coeff,2);
    beta   = results.beta;

    % Create the table
    table          = cell(nCoeff+1,2);
    table(2:end,2) = nb_double2cell(beta,precision);
    table(2:end,1) = coeff;
    table{1,2}     = 'Estimated values';
    table{1,1}     = 'Estimated parameters';
    tableAsChar    = cell2charTable(table);
    res            = char(res,tableAsChar);
    
end

