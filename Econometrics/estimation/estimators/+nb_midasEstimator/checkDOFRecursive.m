function [start,iter,ss,options] = checkDOFRecursive(options,numCoeff,T)
% Syntax:
%
% [start,iter,ss] = nb_midasEstimator.checkDOFRecursive(options,numCoeff,T)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    startInd = options.start_low;
    if isempty(options.rollingWindow)
    
        if isempty(options.recursive_estim_start_ind)
            start = options.requiredDegreeOfFreedom + numCoeff;
            options.recursive_estim_start_ind = options.increment*start + startInd - 1;
        else
            start = options.recursive_estim_start_ind - startInd + 1;
            if start < (options.requiredDegreeOfFreedom + numCoeff)*options.increment
                error([mfilename ':: The start period (' int2str(options.recursive_estim_start_ind) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' int2str(options.requiredDegreeOfFreedom + numCoeff + startInd - 1) ').'])
            end
            if rem(start,options.increment) ~= 0
                error([mfilename ':: The recursive estimation start date must be given as an observation at the end of the sub period of the highest frequency. '...
                                 'E.g. Q4 when dealing with quarterly data.'])
            end
            start = start/options.increment;
        end
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The sample is too short for recursive estimation. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a sample of at least ' int2str(options.requiredDegreeOfFreedom - numCoeff) ' observations.'])
        end
        ss = ones(1,iter);
        
    else
        
        if isempty(options.recursive_estim_start_ind)
            start                             = options.increment*options.rollingWindow;
            options.recursive_estim_start_ind = start + startInd - 1;
        else
            if options.increment*options.rollingWindow > options.recursive_estim_start_ind
                date = nb_date.date2freq(options.dataStartDate);
                date = date + (options.recursive_estim_start_ind - 1);
                error([mfilename ':: The recursive_estim_start_date (' toString(date) ') results in an first estimation window with less observation (' int2str(options.recursive_estim_start_ind) ') '...
                                 'then specified by the rollingWindow (' int2str(options.rollingWindow) ') input.' ])
            end
            start = options.recursive_estim_start_ind - startInd + 1;
            if rem(start,options.increment) ~= 0
                error([mfilename ':: The recursive estimation start date must be given as an observation at the end of the sub period of the highest frequency. '...
                                 'E.g. Q4 when dealing with quarterly data.'])
            end
        end
        start = start/options.increment;
        if options.requiredDegreeOfFreedom + numCoeff > start
            error([mfilename ':: The rolling window length is to short. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a window of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff) ' observations.'])
        end
        iter  = T - start + 1;
        first = (start - options.rollingWindow) + 1;
        last  = (T - options.rollingWindow) + 1;
        if iter < 1
            error([mfilename ':: The rolling window length is longer than the estimation period.']);
        end
        ss = first:last;
        
    end


end
