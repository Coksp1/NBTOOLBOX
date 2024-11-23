function factors = getFactors(results,options)
% Syntax:
%
% factors = nb_pcaEstimator.getFactors(results,options)
%
% Description:
%
% Get the estimated factors as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        factors = nb_ts();
    else

        startInd = options.estim_start_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end 
        factors  = nb_ts(results.F, 'Factors', start, nb_appendIndexes('Factor',1:size(results.F,2))); 

    end

end
