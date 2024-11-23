function seasonal = getHP(results,options)
% Syntax:
%
% seasonal = nb_hpEstimator.getHP(results,options)
%
% Description:
%
% Get the estimated HP-filtered series as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        seasonal = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end 
        seasonal  = nb_ts(results.F, 'HP', start, options.dependent); 

    end

end
