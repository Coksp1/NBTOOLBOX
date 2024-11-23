function out = getCalculated(results,options)
% Syntax:
%
% seasonal = nb_manualCalcEstimator.getCalculated(results,options)
%
% Description:
%
% Get the manually calculated series as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen and Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'F')
        out = nb_ts();
    else

        start = nb_date.date2freq(results.startDateOfCalc);
        if size(results.F,3) > 1
            dataStart    = nb_date.toDate(options.dataStartDate,start.frequency);
            recStartDate = dataStart + (options.recursive_estim_start_ind - 1);
            if isempty(options.outVariables)
                out = nb_ts(results.F, 'Calculated', start, options.dependent); 
            else 
                out = nb_ts(results.F, 'Calculated', start, options.outVariables);
            end
            out.dataNames = recStartDate:recStartDate+size(results.F,1)-1;
        else
            if isempty(options.outVariables)
                out = nb_ts(results.F, 'Calculated', start, options.dependent); 
            else 
                out = nb_ts(results.F, 'Calculated', start, options.outVariables); 
            end
        end
    
    end

end
