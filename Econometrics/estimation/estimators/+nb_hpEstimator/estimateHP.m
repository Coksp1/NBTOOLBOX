function [res,options] = estimateHP(options,Z)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if options.oneSided
        func = @hpfilter1s;
    else
        func = @hpfilter;
    end

    [~,freq] = nb_date.date2freq(options.dataStartDate);
    dof      = options.requiredDegreeOfFreedom*freq;
    if options.recursive_estim

        % Check the sample
        T                       = size(Z,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,dof,T);
                
        % Estimate the model recursively
        F  = nan(T,size(Z,2),iter);
        kk = 1;
        for tt = start:T
            data = func(Z(ss(kk):tt,:,kk),options.lambda);
            if strcmpi(options.type,'trend')
                data = Z(ss(kk):tt,:,kk) - data;
            end
            F(ss(kk):tt,:,kk) = data;
            kk                = kk + 1;
        end
           
    %======================
    else % Not recursive
    %======================
        
        T = size(Z,1);
        nb_estimator.checkDOF(options,dof,T);
        
        % Apply HP-filter
        F = func(Z,options.lambda);
        if strcmpi(options.type,'trend')
            F = Z - F;
        end

    end
    
    % Get estimation results
    res   = struct();
    res.F = F;

end
