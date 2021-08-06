function seasonal = getData(results,options)
% Syntax:
%
% seasonal = nb_hpEstimator.getData(results,options)
%
% Description:
%
% Get the shortened original series as a nb_ts object
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isfield(results,'F')
        seasonal = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end 
        seasonal  = nb_ts(results.F, 'shortened', start, options.dependent); 

    end

end
