function res = print(results,options,precision)
% Syntax:
%
% res = nb_manualEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_manualEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_manualEstimator.estimate function.
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

    method = getMethod();
    res    = sprintf('Method: %s',[method, extra]);
    res    = char(res,sprintf('%s',nb_clock('gui')));
    res    = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    % Get sample dates
    startD = nb_date.date2freq(options.dataStartDate);
    start  = options.estim_start_ind;
    finish = options.estim_end_ind;
    start  = startD + (start - 1);
    finish = startD + (finish - 1);
    
    % Get coefficients
    [exo,numExo] = nb_manualEstimator.getCoeff(options);
    
    % Print
    beta = results.beta;
    if isfield(results,'stdBeta')
        stdBeta = results.stdBeta;
    else
        stdBeta = nan(size(beta)); 
    end
    dates  = start:finish;
    dates  = dates(end-size(beta,3)+1:end)';
    iter   = size(beta,3);
    nEq    = size(beta,2);
    if isfield(options,'dependent')
        if length(options.dependent) ~= nEq
            eqNames = nb_appendIndexes('Equation',1:nEq);
        else
            eqNames = options.dependent;
        end
    else
        eqNames = nb_appendIndexes('Equation',1:nEq);
    end
    for ii = 1:nEq
        
        betaT    = permute(beta(:,ii,:),[1,3,2]);
        stdBetaT = permute(stdBeta(:,ii,:),[1,3,2]);
        
        % Create the table
        res                  = char(res,'');
        res                  = char(res,['Estimation result for equation: ' eqNames{ii}]);
        res                  = char(res,'');
        table                = repmat({''},numExo*2 + 1,iter + 1);
        table(2:2:end,2:end) = nb_double2cell(betaT,precision);
        table(3:2:end,2:end) = nb_double2cell(stdBetaT,precision);
        table(2:2:end,1)     = exo;
        table(1,2:end)       = dates;
        tableAsChar          = cell2charTable(table);
        res                  = char(res,tableAsChar);
        
    end

end

function res = normalPrint(results,options,precision)

    method = getMethod();

    % Information on estimated equation
    res = sprintf('Method: %s',method);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));
    
    startD = nb_date.date2freq(options.dataStartDate);
    start  = startD + (options.estim_start_ind - 1);
    finish = startD + (options.estim_end_ind - 1);

    res = char(res,sprintf('Sample: %s : %s',start.toString(),finish.toString()));
    if isfield(results,'includedObservations')
        res = char(res,sprintf('Included observations: %s',int2str(results.includedObservations)));
    end
    res = char(res,'');
    
    % Equation estimation results
    beta = results.beta;
    if isfield(results,'stdBeta')
        stdBeta = results.stdBeta;
    else
        stdBeta = nan(size(beta)); 
    end
    numPar = size(beta,1);
    nEq    = size(beta,2);
    table  = cell(numPar*2 + 1,nEq + 1);
    if isfield(options,'dependent')
        if length(options.dependent) ~= nEq
            eqNames = nb_appendIndexes('Equation',1:nEq);
        else
            eqNames = options.dependent;
        end
    else
        eqNames = nb_appendIndexes('Equation',1:nEq);
    end

    % Construct the coeff names
    [exo,numExo] = nb_manualEstimator.getCoeff(options);

    % Fill table
    table{1,1}           = 'Equations';
    table(1,2:end)       = eqNames;
    table(2:2:end,1)     = exo;
    table(3:2:end,1)     = repmat({'(Std. Error)'},numExo,1);
    table(2:2:end,2:end) = nb_double2cell(beta,precision);
    table(3:2:end,2:end) = nb_double2cell(stdBeta,precision);

    % Convert the test result to a cell matrix on the wanted
    % format
    tableAsChar = cell2charTable(table);
    res         = char(res,tableAsChar);

end

function method = getMethod()

    method = 'Manual program ';

end
