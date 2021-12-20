function [res,options] = doShortening(options,Z)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
            F(ss(kk):tt,:,kk) = Z(ss(kk):tt,:,kk);
            kk                = kk + 1;
        end
           
    %======================
    else % Not recursive
    %======================
        
        T = size(Z,1);
        nb_estimator.checkDOF(options,dof,T);
        F = Z;

    end
    
    % Get estimation results
    res   = struct();
    res.F = F;

end
