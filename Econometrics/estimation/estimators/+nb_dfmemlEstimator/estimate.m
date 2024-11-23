function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_dfmemlEstimator.estimate(options)
%
% Description:
%
% Estimate a dynamic factor model with the two step expected likelihood
% algorithm suggested by Banbura et al. (2010). Some small alteration to
% the algorithm may have been done in special cases. See the help on 
% the nb_fmdyn class for more on the algorithm implemented by this 
% package. 
% 
% Input:
% 
% - options  : A struct on the format given by nb_dfmemlEstimator.template.
%              See also nb_dfmemlEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : Some options may be updated.
%
% See also:
% nb_dfmemlEstimator.print, nb_dfmemlEstimator.help, 
% nb_dfmemlEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;
    
    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    % We want to indicated that we are dealing with missing observations
    % when producing forecast.
    options.missingMethod = 'kalman'; 
    options = nb_defaultField(options,'set2nan',struct());
    options = nb_defaultField(options,'covidAdj',[]);

    if ~isempty(options.covidAdj)
        if ~nb_isempty(options.set2nan)
            error('You cannot provide both set2nan and covidAdj at the same time.')
        end
        if isa(options.covidAdj,'nb_date')
            dates = toString(options.covidAdj);
        end
        options.set2nan = struct('all',{dates});
    end

    % Check inputs
    %------------------------------------------------------
    if ~nb_isScalarInteger(options.nLagsIdiosyncratic,-1,2)
        error([mfilename ':: The option nLagsIdiosyncratic must be either 0 or 1.'])
    end
    if ~nb_isScalarLogical(options.factorRestrictions)
        error([mfilename ':: The option factorRestrictions must be either false or true.'])
    end
    
    % Get the estimation options
    %------------------------------------------------------
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end
    options.observables = cellstr(options.observables);
    if isempty(options.observables)
        error([mfilename ':: The observables must be given!.'])
    end
    options.exogenous = cellstr(options.exogenous);

    % Get the estimation data
    %------------------------------------------------------
    % Add seasonal dummies
    if ~isempty(options.seasonalDummy)
        options = nb_olsEstimator.addSeasonalDummies(options);
    end

    % Shorten sample (Missing observation is no issue here!)
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end
    options = nb_dfmemlEstimator.removeLeadingAndTrailingNaN(options);
    
    % Get frequency and sort variables accordingly
    options = getFrequency(options);
    
    % Do the estimation
    if options.recursive_estim
        [results,options] = nb_dfmemlEstimator.recursiveEstimation(options);
    else % Not recursive
        [results,options] = nb_dfmemlEstimator.normalEstimation(options);
    end

    % Assign generic results
    results.includedObservations = options.estim_end_ind - options.estim_start_ind + 1;
    results.elapsedTime          = toc(tStart);
    
    % Reorder the observables back to original
    options = reorderObservables(options);
    
    % Assign results
    options.estimator = 'nb_dfmemlEstimator';
    options.estimType = 'classic';

end

%==========================================================================
function options = getFrequency(options)

    % Store original ordering
    options.observablesOrig = options.observables; 
    
    % Get the frquency of each variable
    N        = size(options.observables,2);
    [~,freq] = nb_date.date2freq(options.dataStartDate);
    freq     = freq(1,ones(1,N));
    for ii = 1:N
        if ~isempty(options.frequency{ii})
           freq(ii) = options.frequency{ii};
        end
    end
    
    % Reorder so that the lower frequency variables comes last
    [freq,i]            = sort(freq,'descend');
    options.observables = options.observables(i); 
    options.frequency   = options.frequency(i);
    options.mapping     = options.mapping(i);
    if ~isempty(options.blocks)
        options.blocks = options.blocks(i,:);
    end
    
    % How many series of each frequency do we have
    if all(freq == freq(1))
        options.nHigh = length(freq);
        options.nLow  = 0;
    else
        if ~any(ismember(freq,[4,12]))
            error([mfilename ':: Mixed frequency dynamic factor model is only supported for monhtly and quarterly frequencies.'])
        end
        options.nHigh = sum(freq == 12);
        options.nLow  = sum(freq == 4);
    end
    if options.nHigh == 0 || options.nLow == 0
        options.mixedFrequency = false;
    else
        options.mixedFrequency = true;
    end
    if ~isempty(options.seasonalDummy) && options.mixedFrequency
        error([mfilename ':: Cannot add seasonal dummies when having mixed frequency data.'])
    end
    
    % Reorder index
    [~,options.reorderLoc] = ismember(options.observablesOrig,options.observables);
    
end

%==========================================================================
function options = reorderObservables(options)

    options.observables = options.observablesOrig;
    options             = rmfield(options,'observablesOrig');
    
end
