function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_pcaEstimator.estimate(options)
%
% Description:
%
% Estimate a factors using principal components.
% 
% Input:
% 
% - options  : A struct on the format given by nb_pcaEstimator.template.
%              See also nb_pcaEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_pcaEstimator.print, nb_pcaEstimator.help, nb_pcaEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

    % Get the estimation options
    tempObs = cellstr(options.observables);
    if isempty(tempObs)
        error([mfilename ':: The observables must be given!.'])
    end
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    [test,indZ] = ismember(tempObs,options.dataVariables);
    if any(~test)
        error([mfilename ':: Cannot locate the observed variable(s); ' toString(tempObs(~test))])
    end
    Z = options.data(:,indZ);
    
    % Shorten sample
    if options.unbalanced
        
        % In this case we may have a unbalanced data set
        isNaN    = isnan(Z);
        dataS    = nb_date.date2freq(options.dataStartDate);
        startInd = find(~all(isNaN,2),1,'first');
        if ~isempty(options.estim_start_ind)
            if options.estim_start_ind < startInd
                error([mfilename ':: The selected start date introduce missing observations of all observed variables. ',...
                    'First valid start date is ' toString(dataS + startInd - 1)])
            end
            startInd = options.estim_start_ind;
        else
            options.estim_start_ind = startInd;
        end
        
        endInd = find(~all(isNaN,2),1,'last');
        if ~isempty(options.estim_end_ind)
            if options.estim_end_ind > endInd
                error([mfilename ':: The selected end date introduce missing observations of all observed variables. ',...
                    'Last valid end date is ' toString(dataS + endInd - 1)])
            end
            endInd = options.estim_end_ind;
        else
            options.estim_end_ind = endInd;
        end
        Z = Z(startInd:endInd,:);
        
    else
        [options,Z] = nb_estimator.testSample(options,Z);
    end
    
    % Get factors by PC 
    [results,options] = nb_pcaEstimator.estimateFactors(options,Z);

    % Assign generic results
    results.includedObservations = size(Z,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_pcaEstimator';
    options.estimType = 'classic';
    
end
