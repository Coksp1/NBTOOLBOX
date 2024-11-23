function [results,options] = myEstimAndFcstFunc(options)
% Syntax:
%
% [results,options] = myEstimAndFcstFunc(options)
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
        results = estimateNormal(options,y,X,options.estim_end_ind);
         
    end
    
    % Tell which variable that has been forecasted!
    results.forecasted = options.dependent;
    
    % Assign generic results
    results.includedObservations = size(y,1);
    
    % Assign coeff names
    options.coeff = [nb_appendIndexes('AR',options.AR), options.exogenous];
   
end

%==========================================================================
function results = estimateNormal(options,y,X,endInd)

    condDB = nb_manualEstimator.getCondDB(options,endInd,options.exogenous,'exogenous');
    beta   = nb_ols(y,X);
    
    % Do conditonal forecasting
    yPred  = nan(options.nFcstSteps,1);
    nExo   = size(condDB,2);
    indExo = options.AR + 1:options.AR + nExo;
    indAR  = 1:options.AR;
    X      = nan(1,options.AR + nExo);
    y0     = y(end - options.AR + 1:end)';
    for ii = 1:options.nFcstSteps
        X(indExo) = condDB(ii,:);
        if options.AR
            X(indAR) = y0; 
        end
        yPred(ii) = X*beta;
        if options.AR
            y0 = [y0(2:end),yPred(ii)];
        end
    end
    results.forecast = yPred;
    results.start    = endInd + 1;
    
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
    
    % Check conditional information
    if ~isempty(options.condDB)
        if size(options.condDB,3) ~= iter
            error(['The number of pages of the condDB input must be equal ',...
                'to the number of iterations during recursive estimation. ',...
                'Is ' int2str(size(options.condDB,3)) ', but must be ' int2str(iter)]);
        end
    end
    
    % Preallocation
    numDep    = length(options.dependent);
    forecast  = nan(options.nFcstSteps,numDep,1,iter);
    startFcst = nan(1,iter);
    
    % Loop the recursive estimation steps
    kk        = 1;
    condDBRec = options.condDB;
    start_ind = options.estim_start_ind;
    for tt = start:T
        
        % Get data this recursion
        yThis = y(ss(kk):tt,:);
        XThis = X(ss(kk):tt,:);
        
        % Get conditional information
        if ~isempty(condDBRec)
            options.condDB = condDBRec(:,:,kk);
        end
        
        % Estimate model on this sample
        results = estimateNormal(options,yThis,XThis,start_ind + tt - 1);
        
        % Assign estimation results
        forecast(:,:,:,kk) = results.forecast; 
        startFcst(:,kk)     = results.start;
        
        % Notify waitbar
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    
    % Assign results
    results.forecast = forecast;
    results.start    = startFcst;
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end

end
