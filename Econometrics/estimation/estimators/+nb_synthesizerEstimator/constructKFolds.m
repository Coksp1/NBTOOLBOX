function options = constructKFolds(options)
% Syntax:
%
% optionsOut = constructKFolds(optionsIn)
%
% Description:
%
% Construct an equally sized folds.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_synthesizerEstimator.template.
%              See also nb_synthesizerEstimator.help.
%              Note that the folds input must be on the form
%              {k,evalPeriodStart,evalPeriodEnd}.
% 
% Output:
%
% - options : The estimation options with updated folds field.
%
% See also:
% nb_synthesizerEstimator.help, nb_synthesizerEstimator.template,
% nb_synthesizerEstimator.crossValidate
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    freq = options.models(1).data.frequency;
    
    if nb_isOneLineChar(options.folds{2})
        % If char is used, convert to nb_date
        options.folds{2} = nb_date.toDate(options.folds{2},freq);
    end
    if nb_isOneLineChar(options.folds{3})
        options.folds{3} = nb_date.toDate(options.folds{3},freq);
    end
    
    % Get vector of dates of all dates in evaluation period
    dates = options.folds{2}:options.folds{3};
    
    % Remove periods that are ignored across models
    if ~isempty(options.removePeriods)
       for ii = 1:size(options.removePeriods,1)
           idxStart = find(ismember(dates,options.removePeriods{ii,1}));
           idxEnd   = find(ismember(dates,options.removePeriods{ii,2}));
           dates(idxStart:idxEnd) = [];
       end
    end

    numPeriods     = length(dates);
    periodsPerFold = floor(numPeriods/options.folds{1});
    extra          = mod(numPeriods,options.folds{1});
    
    if periodsPerFold < 1
       error([mfilename ':: Number of observations are less than the number of folds (after adjusting for removed periods).',...
           'Decrease k, expand the evaluation period, or decrease the number of removed periods.']);
    end
    
    % Vector of periods per fold
    periods = repmat(periodsPerFold,options.folds{1},1);
    
    % Add remainder periods to most recent periods
    extra   = ones(extra,1);
    extra   = [zeros(length(periods)-length(extra),1);extra];
    periods = periods + extra;
        
    % Construct folds
    folds = cell(options.folds{1},2);
    ctr   = 1;
    for kk = 1:size(folds,1)
        folds{kk,1} = dates{ctr};
        folds{kk,2} = dates{ctr + periods(kk) - 1};
        ctr = ctr + periods(kk);
    end
    
    % Save updated folds in options 
    options.folds = folds;
    
    if isempty(options.foldWeights)
       % Equally-weighted weights adjusted for differences in periods 
       options.foldWeights = (periods ./ sum(periods))';
    end
end
