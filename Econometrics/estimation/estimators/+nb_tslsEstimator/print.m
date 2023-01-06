function res = print(results,options,precision)
% Syntax:
%
% res = nb_tslsEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_tslsEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_tslsEstimator.estimate function.
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
    
    if options.('mainEq').recursive_estim

        res = resursivePrint(results.('mainEq'),options.('mainEq'),precision);

    else   

        % Get the printed result from the main eq
        res = nb_olsEstimator.print(results.mainEq,options.mainEq,precision);
        res = char(res,'');
        
        % Loop through the first stage equations
        firstStageResults = rmfield(results,'mainEq');
        fields            = fieldnames(firstStageResults);
        for ii = 1:length(fields)
            res = char(res, nb_olsEstimator.print(results.(fields{ii}),options.(fields{ii}),precision));
            res = char(res,'');
        end
        
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

    res = sprintf('Method: %s',['Two Stage Least Squares', extra]);
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,sprintf('Elapsed time: %s',num2str(results.elapsedTime)));

    % Get recursive estimation results
    [exo,numExo] = nb_tslsEstimator.getCoeff(options);
    
    % Get sample
    dataStart = options.dataStartDate;
    dataStart = nb_date.date2freq(dataStart);
    startInd  = options.estim_start_ind;
    endInd    = options.estim_end_ind;
    if isempty(startInd)
        start    = dataStart;
        startInd = 1;
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
    stdBeta        = results.stdBeta; 
    dates          = start:finish;
    dates          = dates(startRecursive:end)';
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
