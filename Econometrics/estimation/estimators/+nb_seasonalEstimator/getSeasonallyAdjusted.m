function seasonal = getSeasonallyAdjusted(results,options)
% Syntax:
%
% seasonal = nb_seasonalEstimator.getSeasonallyAdjusted(results,options)
%
% Description:
%
% Get the estimated seasonally adjusted series as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        seasonal = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end 
        seasonal  = nb_ts(results.F, 'SeasAdj', start, options.dependent); 

    end

end
