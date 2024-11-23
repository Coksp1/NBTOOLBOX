function [res,options] = estimateFactors(options,Z)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if options.recursive_estim

        if isempty(options.nFactors)
            error([mfilename ':: The number of factors (nFactors) to estimate must be given when recursive_estim is set to true.'])
        end
        
        % Check the sample
        numObs                  = size(Z,2);
        T                       = size(Z,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numObs,T);
                
        % Estimate the model recursively
        lambda = nan(options.nFactors,numObs,iter);
        F      = nan(T,options.nFactors,iter);
        R      = nan(numObs,numObs,iter);
        varF   = nan(1,options.nFactors,iter);
        expl   = nan(1,options.nFactors,iter);
        c      = nan(1,numObs,iter);
        sigma  = nan(1,numObs,iter);
        e      = nan(T,numObs,iter);
        ZNorm  = nan(T,numObs,iter);
        kk     = 1;
        for tt = start:T
            [F(ss(kk):tt,:,kk),lambda(:,:,kk),R(:,:,kk),varF(:,:,kk),expl(:,:,kk),...
                c(:,:,kk),sigma(:,:,kk),e(ss(kk):tt,:,kk),ZNorm(ss(kk):tt,:,kk)] = nb_pca(Z(ss(kk):tt,:,kk),options.nFactors,'svd',...
                'crit',options.factorsCriterion,'rMax',options.nFactorsMax,...
                'trans','standardize','unbalanced',options.unbalanced);
            kk = kk + 1;
        end
           
    %======================
    else % Not recursive
    %======================
        
        numObs = size(Z,2);
        T      = size(Z,1);
        nb_estimator.checkDOF(options,numObs,T);
        
        % Estimate model by pca
        [F,lambda,R,varF,expl,c,sigma,e,ZNorm] = nb_pca(Z,options.nFactors,'svd',...
            'crit',options.factorsCriterion,'rMax',options.nFactorsMax,...
            'trans','standardize','unbalanced',options.unbalanced);
        options.nFactors = size(F,2);

    end
    
    % Get estimation results
    res        = struct();
    res.F      = F;
    res.lambda = lambda;
    res.R      = R;
    res.varF   = varF;
    res.expl   = expl;
    res.c      = c;
    res.sigma  = sigma;
    res.e      = e;
    res.ZNorm  = ZNorm;

end
