function res = estimateFactors(options,y,Z,ZF)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    T = size(Z,1);
    if strcmpi(options.modelType,'favar') % Factor augmented VAR
    
        if isempty(options.observablesFast) % No restriction on the observable equation
            
            % Here I use the algorithm presented in footnote 9 of Boivin, 
            % Giannoni and Ilian Mihov (2009)
            
            % Get a initial value of the factors
            F0 = nb_pca(Z,options.nFactors,'svd',...
                    'rMax',options.nFactorsMax,...
                    'crit',options.factorsCriterion,...
                    'trans','standardise',...
                    'unbalanced',options.unbalanced);
            nFact = size(F0,2);
                
            % Iterate until convergence of the cleansed factors 
            crit  = 10;
            nDepC = size(y,2) + 1;
            yWc   = [ones(T,1),y]; % y with constant
            Z0    = Z;
            while crit > exp(-10)
                
                lambdaIter = nb_ols(Z0,[y,F0],1); % With constant
                Z0         = Z0 - yWc*lambdaIter(1:nDepC,:);
                F_         = nb_pca(Z0,nFact,'svd');
                crit       = norm(F_ - F0);
                F0         = F_;
                
            end
            
            % Do one last estimation of the observation eq with the 
            % converged factors, but know we use the true Z
            [lambda,~,~,~,e_] = nb_ols(Z,[F0,y],1);
            
            % Report the needed results
            F    = F0;
            R    = e_'*e_/T;
            varF = var(F,0,1);
            expl = 100*varF/sum(varF); 
            
        else
            
            % Get the factors based on the slow responding variables
            F = nb_pca(Z,options.nFactors,'svd',...
                    'rMax',options.nFactorsMax,...
                    'crit',options.factorsCriterion,...
                    'trans','standardise',...
                    'unbalanced',options.unbalanced);
            
            % Estimate the observation equation with the full set of 
            % variables
            [lambda,~,~,~,e_] = nb_ols([Z,ZF],F,1);
                
            % Report the needed results
            R    = e_'*e_/T;
            varF = var(F,0,1);
            expl = 100*varF/sum(varF); 
            
        end
          
    else % Factor model
         
        % Estimate the observation equation and get the factors
        [F,LAMBDA,R,varF,expl,c,sigma,e_] = nb_pca(Z,options.nFactors,'svd',...
            'rMax',options.nFactorsMax,...
            'crit',options.factorsCriterion,...
            'trans','standardise',...
            'unbalanced',options.unbalanced);
        
        % Concatenate and scale to the wanted format
        lambda = LAMBDA.*sigma(ones(1,size(LAMBDA,1)),:); % Scale back to non-standardised metric
        lambda = [c;lambda];
        
    end
    
    % Report a struct with the needed results
    %------------------------------------------
    res = struct('lambda',lambda,'F',F,'R',R,'varF',varF,'expl',expl,'obsResidual',e_);

end
