function [res,options] = doFunc(options,Z)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [date,freq] = nb_date.date2freq(options.dataStartDate);
    dof         = options.requiredDegreeOfFreedom*freq;
    date        = date + (options.estim_start_ind - 1);
    if options.recursive_estim

        % Check the sample
        T                       = size(Z,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,dof,T);
                
        % Estimate the model recursively
        calc = cell(1,iter);
        kk   = 1;
        for tt = start:T
            data     = nb_math_ts(Z(ss(kk):tt,:,kk),date + (ss(kk) - 1));
            calc{kk} = options.func(data); % We do this to allow for fluctuation start and end dates!
            kk       = kk + 1;
        end
        F               = horzcat(calc{:});
        startDateOfCalc = F.startDate; 
        F               = double(F);
           
    %======================
    else % Not recursive
    %======================
        
        T = size(Z,1);
        nb_estimator.checkDOF(options,dof,T);
        data            = nb_math_ts(Z,date);
        F               = options.func(data); % We do this to allow for fluctuation start and end dates!
        startDateOfCalc = F.startDate; 
        F               = double(F);
        
    end
    
    % Get estimation results
    res                 = struct();
    res.F               = F;
    res.startDateOfCalc = startDateOfCalc;

end
