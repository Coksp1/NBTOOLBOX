function [res,options] = estimateSeasonal(options,Z,X)
% No documentation
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen


    [dataStart,freq] = nb_date.date2freq(options.dataStartDate);
    dof              = 3*freq;
    if options.recursive_estim

        % Check the sample
        T                       = size(Z,1);
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,dof,T);
                
        % Estimate the model recursively
        F  = nan(T,size(Z,2),iter);
        kk = 1;
        for tt = start:T
            
            if options.removeZeroRegressors
                ind = ~all(abs(X(ss(kk):tt,:)) < eps,1);
            else
                ind = true(1,size(X,2));
            end
            startDate = dataStart + (options.estim_start_ind + ss(kk) - 2);
            ZObj      = nb_math_ts(Z(ss(kk):tt,:,kk),startDate);
            if isempty(X)
                XObj = [];
            else
                XObj = nb_math_ts(X(ss(kk):tt,ind),startDate);
            end
            [seasObj,~,~,err] = x12Census(ZObj,'missing',options.missing,...
                'maxIter',options.maxIter,'tolerance',options.tolerance,...
                'dummy',XObj);
            check(seasObj,options.dependent,err);
            F(ss(kk):tt,:,kk) = double(seasObj);
            kk                = kk + 1;
        end
           
    %======================
    else % Not recursive
    %======================
        
        T = size(Z,1);
        nb_estimator.checkDOF(options,dof,T);
        
        % Estimate model by whitening
        if options.removeZeroRegressors
            ind = ~all(abs(X) < eps,1);
        else
            ind = true(1,size(X,2));
        end
        startDate = dataStart + (options.estim_start_ind - 1);
        ZObj      = nb_math_ts(Z,startDate);
        if isempty(X)
            XObj = [];
        else
            XObj = nb_math_ts(X(:,ind),startDate);
        end
        [seasObj,~,~,err] = x12Census(ZObj,'missing',options.missing,...
            'maxIter',options.maxIter,'tolerance',options.tolerance,...
            'dummy',XObj);
        check(seasObj,options.dependent,err);
        F = double(seasObj);

    end
    
    % Get estimation results
    res   = struct();
    res.F = F;

end

%==========================================================================
function check(seasObj,dependent,err)

    indFailed = all(isnan(double(seasObj)),1);
    if any(indFailed)
        errFailed = err(indFailed);
        for ii = 1:length(errFailed)
            errFailed{ii} = horzcat(errFailed{ii}, nb_newLine(2));
        end
        error(['The variable(s) ' toString(dependent(indFailed)) ' could not be seasonally adjusted. Error: '...
               nb_newLine(2) horzcat(errFailed{:}) ])
    end

end
