function res = printCov(results,options,precision)
% Syntax:
%
% res = nb_estimator.printCov(results,precision)
%
% Description:
%
% Get the estimated covariance matrix results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from for example the 
%               nb_olsEstimator.estimate function.
%
% - options   : A struct with the estimation options from for example the  
%               nb_olsEstimator.estimate function.
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
    
    switch lower(options(end).estimator)
        case {'nb_olsestimator','nb_bvarestimator','nb_ecmestimator',...
              'nb_arimaestimator','nb_mlestimator','nb_pitestimator',...
              'nb_exprestimator'}
            res = standardCovPrint(results,options,precision);
        otherwise
            res = '';
            res = char(res,'The estimated covariance matrix cannot be printed.');
            res = char(res,'');    
    end
             
end

function res = standardCovPrint(results,options,precision)

    precision = nb_estimator.interpretPrecision(precision);
    if options(end).recursive_estim
        res = resursivePrint(results,options(end),precision);
    else
        res = normalPrint(results,options,precision);
    end

end

function res = resursivePrint(results,options,precision)

    dep = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    nDep = length(dep);
    if isfield(options,'nstep')
        if ~isempty(options.nStep)
            dep = [dep,nb_cellstrlead(dep,options.nStep-1)];
        end
    end

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
    
    beta = results.sigma;
    if isempty(options.recursive_estim_start_ind)
        startRecursive = options.requiredDegreeOfFreedom + size(beta,1);
    else
        startRecursive = options.recursive_estim_start_ind - startInd + 1;
    end
    if isfield(options,'nStep')
        finish = finish - options.nStep;
        start  = start - options.nStep;
    end
    dates = start:finish;
    dates = dates(startRecursive:end)';
    
    % Reduce covariance matrix.
    sigma   = results.sigma;
    numObs  = size(sigma,3);
    N       = size(sigma,1);
    nPar    = (N^2 + N)/2;
    par     = nan(nPar,numObs);
    for ii = 1:numObs
        par(:,ii) = nb_reduceCov(sigma(:,:,ii));
    end
    
    covNames = {};
    for ii = 1:nDep
        covNames = [covNames,strcat(dep{ii},'_',dep(ii:end))]; %#ok<AGROW>
    end
    
    % Print
    table              = repmat({''},nPar+1,numObs+1);
    table(2:end,2:end) = nb_double2cell(par,precision);
    table(1,2:end)     = dates;
    table(2:end,1)     = covNames;
    res                = cell2charTable(table);
    
end

function res = normalPrint(results,options,precision)
    
    dep = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    if isfield(options,'indObservedOnly')
        dep = dep(~options.indObservedOnly);
    end
    if isfield(options,'nstep')
        if ~isempty(options.nStep)
            dep = [dep,nb_cellstrlead(dep,options.nStep-1)];
        end
    end
    
    nDep               = length(dep);
    table              = repmat({''},nDep+1,nDep+1);
    table(2:end,2:end) = nb_double2cell(results.sigma,precision);
    table(1,2:end)     = dep;
    table(2:end,1)     = dep;
    res                = cell2charTable(table);
    
end
