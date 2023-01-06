function [results,options] = myEstimFunc(options)
% Syntax:
%
% [results,options] = myEstimFunc(options)
%
% Description:
%
% This is an example file on how to program your own model, and make it
% work with the rest of NB toolbox.
% 
% See also:
% nb_manualEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get data
    if length(options.dependent) ~= 1
        error('The dependent option must have length 1.')
    end
    y = nb_manualEstimator.getData(options,options.dependent,'dependent');
    X = nb_manualEstimator.getData(options,options.exogenous,'exogenous');
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    yLag = nb_mlag(y,options.AR);
    X    = [yLag,X];
    
    % Get estimation sample
    [options,y,X] = nb_estimator.testSample(options,y,X);
    
    if options.recursive_estim
        % Estimate model recursively
        results = estimateRecursive(options,y,X);
    else 
          
        % Check the degrees of freedom
        T        = size(y,1);
        numCoeff = options.AR + length(options.exogenous);
        nb_estimator.checkDOF(options,numCoeff,T);
        
        % Estimate model
        results = estimateNormal(y,X);
         
    end
    
    % Assign generic results
    results.includedObservations = size(y,1);
    
    % Assign coeff names
    options.coeff = [nb_appendIndexes('AR',options.AR), options.exogenous];
   
end

%==========================================================================
function results = estimateNormal(y,X)

    [results.beta,results.stdBeta,~,~,results.residual] = nb_ols(y,X);
    results.predicted = X*results.beta;
    results.sigma     = results.residual'*results.residual/(size(results.residual,1) - size(X,2));
    
end

%==========================================================================
function results = estimateRecursive(options,y,X)

    % Check the sample
    numCoeff                = options.AR + length(options.exogenous);
    T                       = size(y,1);
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
    
    % Create waiting bar window
    waitbar = false;
    if options.waitbar
        h = nb_estimator.openWaitbar(options,iter);
        if ~isempty(h)
            waitbar = true;       
            h.lock  = 2;
            note    = nb_when2Notify(iter);
        end
    else
        h = false;
    end
    
    % Preallocation
    beta     = nan(numCoeff,1,iter);
    stdBeta  = beta;
    sigma    = nan(1,1,iter); 
    residual = nan(T,1,iter);
    
    % Loop the recursive estimation steps
    kk = 1;
    for tt = start:T
        
        % Get data this recursion
        yThis = y(ss(kk):tt,:);
        XThis = X(ss(kk):tt,:);
        
        % Estimate model on this sample
        results = estimateNormal(yThis,XThis);
        
        % Assign estimation results
        beta(:,:,kk)              = results.beta; 
        stdBeta(:,:,kk)           = results.stdBeta;
        sigma(:,:,kk)             = results.sigma; 
        residual(ss(kk):tt,:,kk)  = results.residual; 
        
        % Notify waitbar
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    
    % Assign results
    results.beta     = beta;
    results.stdBeta  = stdBeta;
    results.sigma    = sigma;
    results.residual = residual;
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end

end
