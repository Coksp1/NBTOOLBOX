function out = getData(results,options)
% Syntax:
%
% seasonal = nb_shorteningEstimator.getData(results,options)
%
% Description:
%
% Get the shortened original series as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        out = nb_ts();
    else

        if ~isempty(options.func)
            if size(results.F,2) ~= length(options.outVariables)
                error(['The outVariables option must have the same length ',...
                       'as the number of calculated series ' int2str(size(results.F,2))]);
            end
            out = nb_ts(results.F, 'shortened', results.startDateOfCalc, options.outVariables); 
        else
            startInd = options.estim_start_ind;
            if isempty(startInd)
                start = nb_date.date2freq(options.dataStartDate);
            else
                start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
            end 
            out = nb_ts(results.F, 'shortened', start, options.dependent); 
        end
        
    end

end
