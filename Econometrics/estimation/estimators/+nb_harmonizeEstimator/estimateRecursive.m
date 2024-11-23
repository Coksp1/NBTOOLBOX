function results = estimateRecursive(options,y)
% Syntax:
%
% results = nb_harmonizeEstimator.estimateRecursive(options,y)
%
% Description:
%
% Estimate model and harmonize forecast recursively.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check the sample
    numCoeff                = nb_harmonizeEstimator.getNumCoeff(options);
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
    yPred     = nan(size(options.condDB,1),size(options.condDB,2),1,iter);
    startFcst = nan(1,iter);
    
    % Check conditional information
    if size(options.condDB,3) ~= iter
        error(['The number of pages of the condDB input must be equal ',...
            'to the number of iterations during recursive estimation. ',...
            'Is ' int2str(size(options.condDB,3)) ', but must be ' int2str(iter)]);
    end
    
    % Loop the rest
    kk        = 1;
    start_ind = options.estim_start_ind;
    results   = [];
    condDBRec = options.condDB;
    for tt = start:T
        
        % Get data this recursion
        yThis = y(ss(kk):tt,:);
        
        % Get conditional information
        options.condDB = condDBRec(:,:,kk);
        
        % Estimate model on this sample
        results = nb_harmonizeEstimator.estimateNormal(options,yThis,start_ind + tt - 1);
        
        % Assign estimation results
        yPred(:,:,:,kk) = results.forecast; % Forecast
        startFcst(:,kk) = results.start; % Start index of forecast
        
        % Notify waitbar
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    
    % Assign results
    results.forecast = yPred;
    results.start    = startFcst;
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end

end
