function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_synthesizerEstimator.estimate(options)
%
% Description:
%
% Construct a synthetic time-series for a variable.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_synthesizerEstimator.template.
%              See also nb_synthesizerEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_pca, nb_synthesizerEstimator.help, nb_synthesizerEstimator.template
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    
    % Check that inputs are correct
    nb_synthesizerEstimator.checkOptions(options);

    % Start timer
    tStart = tic;
    
    % Periods to remove from all models
    if ~isempty(options.removePeriods)
       for ii = 1:size(options.removePeriods,1)
           for kk = 1:length(options.models)
              options.models(kk).data = options.models(kk).data.setToNaN(options.removePeriods{ii,1},options.removePeriods{ii,2});
           end
       end
    end
    
    if options.parallel
        % Open parallel pool if not already open
        ret = nb_openPool(options.cores);
    end
    
    if options.method == 1
        if size(options.folds,2) == 3
            options = nb_synthesizerEstimator.constructKFolds(options);
        end
        % Cross validate models, estimate them on the full sample and weight them together. 
        options                   = nb_synthesizerEstimator.crossValidate(options);
        [syntheticData,estmodels] = nb_synthesizerEstimator.getIndSyntheticSeries(options);
        indicator                 = nb_synthesizerEstimator.weightedCombination(syntheticData,options);
    elseif options.method == 2
        % Estimate models on the full sample and estimate a factor using PCA
        [syntheticData,estmodels] = nb_synthesizerEstimator.getIndSyntheticSeries(options);
        indicator                 = nb_pca(double(syntheticData),1);
        indicator                 = nb_ts(indicator,'',syntheticData.startDate,['IND_',options.varOfInterest]);
    else
        if size(options.folds,2) == 3
            options = nb_synthesizerEstimator.constructKFolds(options);
        end
        % Cross validate models, estimate them on the full sample and give all of them to final step 
        options               = nb_synthesizerEstimator.crossValidate(options);
        [indicator,estmodels] = nb_synthesizerEstimator.getIndSyntheticSeries(options);
    end
    
    if options.parallel
        % Close parallel pool only if it where open locally
        nb_closePool(ret);
    end
    
    % Combine series in a final VAR model to ensure that synthetic series 
    % sums to quarterly one
    [results,options] = nb_synthesizerEstimator.estimateCombinatorModel(indicator,options); 
    results.models    = estmodels;
    
    % Assign generic results
    results.includedObservations = size(indicator,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_synthesizerEstimator';
    options.estimType = 'classic';
end
