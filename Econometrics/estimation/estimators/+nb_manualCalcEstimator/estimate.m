function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_manualCalcEstimator.estimate(options)
%
% Description:
%
% Calculate new variables according to settings.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_manualCalcEstimator.template. See also 
%              nb_manualCalcEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_manualCalcEstimator.print, nb_manualCalcEstimator.help, 
% nb_manualCalcEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen and Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error(['The options input cannot be empty!'])
    end
    
    % Estimate model
    if isempty(options.calcFunc)
        error(['You need to provide the calcFunc to calculate a manually ' ...
            'programmed model.'])
    end

    if ~isempty(options.path)
        oldDir            = pwd;
        cd(options.path);
        estimFunc         = str2func(options.calcFunc);
        cd(oldDir);
    else 
        estimFunc         = str2func(options.calcFunc);
    end

    [results,options] = estimFunc(options);
    
    % Check outputs
    if isempty(results)
        error('Results cannot be empty after estimation!')
    end

    if ~isfield(results,'F')
        error('The F property of results does not exists!')
    end
    if ~isfield(results,'startDateOfCalc')
        error('The startDateOfCalc property of results does not exists!')
    end

    if isempty(options.estim_start_ind)
        error('The estim_start_ind cannot be empty after estimation!')
    end
    
    if isempty(options.estim_end_ind)
        error('The estim_end_ind cannot be empty after estimation!')
    end
    if options.recursive_estim
        if isempty(options.recursive_estim_start_ind)
            error(['The recursive_estim_start_ind cannot be empty after ' ...
                'recursive estimation!'])
        end
    end
    
    % Assign output
    results.elapsedTime = toc(tStart);
    options.estimator   = 'nb_manualCalcEstimator';
    options.estimType   = 'classic';
    
end
