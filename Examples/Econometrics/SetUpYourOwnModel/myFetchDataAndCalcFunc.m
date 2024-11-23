function [results,options] = myFetchDataAndCalcFunc(options)
% Syntax:
%
% [results,options] = myFetchDataAndCalcFunc(options)
%
% Description:
%
% This is an example file on how to program your own calculator, and make 
% it work with the rest of NB toolbox.
% 
% See also:
% nb_manualCalcEstimator.estimate
%
% Written by Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get data
    if length(options.dependent) ~= 1
        error('The dependent option must have length 1.')
    end

    % If no data is given then fetch manually.
    if isfield(options,'data') && isempty(options.data)
        options = fetchData(options);
        options.dataVariables = options.dependent;
        
    end

    X = nb_manualCalcEstimator.getData(options,options.dependent,'dependent');
    
    if isempty(X)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
            
    if options.handleMissing
       % Insert code to handle missing values here if not in the calculator
       % itself.
    end

    % Get estimation sample
    [options,X] = nb_estimator.testSample(options,'handleNaN',X);

    [date,freq] = nb_date.date2freq(options.dataStartDate);
    dof         = options.requiredDegreeOfFreedom*freq;
    date        = date + (options.estim_start_ind - 1);
    
    if options.recursive_estim
        % Estimate model recursively
        res = calcRecursive(options,X);

    else 
          
        % Check the degrees of freedom
        T        = size(X,1);
        nb_estimator.checkDOF(options,dof,T);
        
        % Estimate model
        res = calcNormal(nb_math_ts(X ,date));
         
    end

    results                 = struct();
    results.F               = double(res);
    results.startDateOfCalc = res.startDate;
      
end

%==========================================================================
function res = calcNormal(X)
    
    res = expand(fillNaN(X),'1999Q1','','obs');
   
end

%==========================================================================
function res = calcRecursive(options,X)

    % Check the sample
    [date,freq]             = nb_date.date2freq(options.dataStartDate);
    dof                     = options.requiredDegreeOfFreedom*freq;
    date                    = date + (options.estim_start_ind - 1);
    T                       = size(X,1);
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,dof,T);
    
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
    calc = cell(1,iter);
    
    % Loop the recursive estimation steps
    kk = 1;
    for tt = start:T
        
        % Get data this recursion
        XThis = X(ss(kk):tt,:);
        
        % Estimate model on this sample
        calc{kk} = calcNormal(nb_math_ts(XThis ,date));
        
        % Notify waitbar
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end
    
    res = deptcat(calc{:},'expand',true);
      
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end

end

function options = fetchData(options)
    rng(1) % Set seed
    
    T       = 100;
    e       = randn(T,1);
    ex      = randn(T,1);
    x       = nan(T,1);
    x(1)    = randn(1,1);
    lambdaX = 0.6;
    for ii = 2:T
        x(ii) = lambdaX*x(ii-1) + ex(ii); 
    end
    y       = nan(T,1);
    y(1)    = randn(1,1);
    lambdaY = 0.8;
    beta    = 0.4;
    for ii = 2:T
        y(ii) = lambdaY*y(ii-1) + beta*x(ii) + e(ii); 
    end
    
    % Transform to nb_ts object
    data                 = nb_ts(x,'','2000Q1',{'Original'});
    data.data(1:2:end,:) = NaN;
    options.data          = data.data;
    options.dataStartDate = toString(data.startDate);
    freq                  = data.frequency;

    if options.recursive_estim
        options.recursive_estim_start_ind = nb_date.toDate(...
            options.recursive_estim_start_date,freq) ...
            - data.startDate + 1;
    end
   
end
