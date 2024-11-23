function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_harmonizeEstimator.estimate(options)
%
% Description:
%
% Harmonize forecast from other models given som restictions.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_harmonizeEstimator.template. See also 
%              nb_harmonizeEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options.
%
% See also:
% nb_harmonizeEstimator.print, nb_harmonizeEstimator.help, 
% nb_harmonizeEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error('The options input cannot be empty!')
    end
    
    % Get the estimation options
    %------------------------------------------------------
    if isempty(options.data)
        error('Cannot estimate without data.')
    end
    if isempty(options.condDB)
        error('Cannot harmonize forecast without any forecasts. Set condDB.')
    end
    
    % Get the frequencies of the input data
    [~,freq]            = nb_date.date2freq(options.dataStartDate);
    options.frequencies = freq(1,ones(1,length(options.dataVariables)));
    for ii = 1:2:length(options.frequency)
        var = options.frequency{ii};
        if ~nb_isOneLineChar(var)
            error(['Every second element starting with the first element ',...
                'must be a one line char for the frequency option']);
        end
        loc = find(strcmp(var,options.dataVariables),1);
        if isempty(loc)
            error(['The variable ' var ' is not found to be in the dataset, ',...
                'but is given to the frequency input.'])
        end
        if ~nb_isScalarInteger(options.frequency{ii + 1},0)
            error(['Every second element starting with the second element ',...
                'must be a scalar integer greater than 0 for the frequency option']);
        end
        options.frequencies(loc) = options.frequency{ii + 1};
    end
    
    % Get the estimation data
    %------------------------------------------------------
    
    % Get the estimation data
    [y,options] = nb_harmonizeEstimator.getData(options);
    
    % Estimate
    %----------------------------------------------
    if options.recursive_estim
        % Estimate model recursively
        results = nb_harmonizeEstimator.estimateRecursive(options,y);
    else 
          
        % Check the degrees of freedom
        T        = size(y,1);
        numCoeff = options.requiredDegreeOfFreedom;
        nb_estimator.checkDOF(options,numCoeff,T);
        
        % Estimate model
        results = nb_harmonizeEstimator.estimateNormal(options,y,options.estim_end_ind);
         
    end
    
    % Assign generic results
    results.includedObservations = size(y,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_harmonizeEstimator';
    options.estimType = 'classic';

end
