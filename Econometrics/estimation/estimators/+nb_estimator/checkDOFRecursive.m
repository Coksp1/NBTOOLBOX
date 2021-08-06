function [start,iter,ss,options] = checkDOFRecursive(options,numCoeff,T)
% Syntax:
%
% [start,iter,ss] = nb_estimator.checkDOFRecursive(options,numCoeff,T)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options  = nb_defaultField(options,'requiredDegreeOfFreedom',3);
    if isempty(options.rollingWindow)
    
        if isempty(options.recursive_estim_start_ind)
            start = options.requiredDegreeOfFreedom + numCoeff;
            options.recursive_estim_start_ind = start + options.estim_start_ind - 1;
            iter = T - start + 1;
            if iter < 1
                error([mfilename ':: The sample is too short for recursive estimation. '...
                    'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                    'Which require a sample of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff) ' observations.'])
            end
        else
            start = options.recursive_estim_start_ind - options.estim_start_ind + 1;
            if start < options.requiredDegreeOfFreedom + numCoeff
                date         = nb_date.date2freq(options.dataStartDate);
                recStartDate = date + (options.recursive_estim_start_ind - 1);
                startDate    = date + (options.estim_start_ind - 1);
                firstStart   = startDate + (options.requiredDegreeOfFreedom + numCoeff - 1);
                error([mfilename ':: The start date (' toString(recStartDate) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' toString(firstStart) '). ',...
                    'Start date of estimation is ' toString(startDate)])
            end
            iter = T - start + 1;
            if iter < 1
                endDate = nb_date.date2freq(options.dataStartDate) + (options.estim_end_ind - 1);
                error([mfilename ':: The selected recursive_estim_start_date is after the end of the estimation sample (' toString(endDate) ').'])
            end
        end        
        ss = ones(1,iter);
        
    else
        
        if isempty(options.recursive_estim_start_ind)
            start                             = options.rollingWindow;
            options.recursive_estim_start_ind = start + options.estim_start_ind - 1;
        else
            if options.rollingWindow > options.recursive_estim_start_ind - options.estim_start_ind + 1
                date = nb_date.date2freq(options.dataStartDate);
                date = date + (options.recursive_estim_start_ind - 1);
                error([mfilename ':: The recursive_estim_start_date (' toString(date) ') results in an first estimation window with less ',...
                                 'observation (' int2str(options.recursive_estim_start_ind- options.estim_start_ind + 1) ') '...
                                 'then specified by the rollingWindow (' int2str(options.rollingWindow) ') input.' ])
            end
            start = options.recursive_estim_start_ind - options.estim_start_ind + 1;
        end
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
