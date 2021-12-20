function [res,options] = estimateFactors(options,Z)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if options.recursive_estim

        if isempty(options.nFactors)
            error([mfilename ':: The number of factors (nFactors) to estimate must be given when recursive_estim is set to true.'])
        end
        
        % Check the sample
        numObs                  = size(Z,2);
        T                       = size(Z,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numObs,T);
                
        % Estimate the model recursively
        F  = nan(T,options.nFactors,iter);
        kk = 1;
        for tt = start:T
            F(ss(kk):tt,:,kk) = nb_whiten(Z(ss(kk):tt,:,kk),options.nFactors,'missing',options.missing);
            kk = kk + 1;
        end
           
    %======================
    else % Not recursive
    %======================
        
        numObs = size(Z,2);
        T      = size(Z,1);
        nb_estimator.checkDOF(options,numObs,T);
        
        % Estimate model by whitening
        F                = nb_whiten(Z,options.nFactors,'missing',options.missing);
        options.nFactors = size(F,2);

    end
    
    % Get estimation results
    res   = struct();
    res.F = F;

end
