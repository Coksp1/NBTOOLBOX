function indicator = weightedCombination(syntheticData,options)
% Syntax:
%
% o[results,options] = weightedCombination(options)
%
% Description:
%
% Take weighted combination of individual weighted series.
% 
% Input:
%
% - options   : A struct with options for estimation.
%
% Output:
% 
% - indicator : Weighted combination of synthetic series to be used in the
%               final model.
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    dblSyntheticData = double(syntheticData);
    weights          = repmat(options.modelWeights,size(dblSyntheticData,1),1);
    nanidx           = isnan(dblSyntheticData);
    weights(nanidx)  = 0;
    
    % Make sure weights sum to 1 for each period
    weights = weights ./ sum(weights,2);
    
    weightedData = weights .* dblSyntheticData;
    indicator    = sum(weightedData,2,'omitnan');
    indicator    = nb_ts(indicator,'',syntheticData.startDate,['IND_',options.varOfInterest]);
    
end
