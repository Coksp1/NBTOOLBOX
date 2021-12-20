function results = ypl(opt,fVal)
% Syntax:
%
% results = nb_solve.dfsane(opt,fVal)
%
% Description:
%
% Solve the problem using the projection method suggested by Yan, Peng and
% Li (2008).
% 
% See also:
% nb_solve.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d            = -fVal;
    exitFlag     = 1;
    x            = opt.initialXValue;
    funEvals     = 1; % Already evaluated once in nb_solve.solve
    meritFVal    = [];
    meritXChange = [];
    alpha        = 1;
    fValZ        = fVal;
    for iter = 1:opt.maxIter
       
        xPrev    = x;
        fValPrev = fVal;
        
        % Step 2: Decide alpha
        alpha = backtrack(fValZ,alpha,d);
        
        % Step 3: Get temporary update
        z        = xPrev + alpha*d;
        fValZ    = opt.F(z);
        funEvals = funEvals + 1;
        if any(~isfinite(fValZ(:)))
            exitFlag = -6;
            break
        end
        meritFValZ = opt.meritFunction(fValZ);
        if meritFValZ < opt.tolerance
            x         = z;
            fVal      = fValZ;
            meritFVal = meritFValZ;
            if opt.display > 1
                nb_solve.reportStatus(opt.displayer,iter,x,meritFVal,'done');
            end
            break
        end
        
        % Step 4: Do full update
        x = xPrev - (fValZ'*(xPrev - z)/norm(fValZ,2)^2)*fValZ;   
        
        % Test for convergence
        fVal     = opt.F(x);
        funEvals = funEvals + 1;
        if any(~isfinite(fVal(:)))
            exitFlag = -6;
            break
        end
        meritFVal = opt.meritFunction(fVal);
        if meritFVal < opt.tolerance
            if opt.display > 1
                nb_solve.reportStatus(opt.displayer,iter,x,meritFVal,'done');
            end
            break
        end
        
        % Step 1: Update the d for next iteration
        [beta_MHS,theta_M,w] = getCoeff(fVal,fValPrev,z,xPrev,d);
        d                    = -fVal + beta_MHS*d + theta_M*w;
        
        % Check limits
        exitFlag = nb_solve.check(opt,iter,funEvals);
        if exitFlag < 1
            break
        end
        if opt.display == 3
            nb_solve.reportStatus(opt.displayer,iter,x,meritFVal,'iter');
        end
        
    end
    
    results.x         = x;
    results.fVal      = fVal;
    results.meritFVal = meritFVal;
    results.exitFlag  = exitFlag;
    results.iter      = iter;
    results.funEvals  = funEvals;
    
    if opt.display > 0
        if exitFlag < 1
            nb_solve.reportError(opt.displayer,exitFlag);
        end
    end

end

%==========================================================================
function [beta_MHS,theta_M,w] = getCoeff(fValLead,fVal,z,x,d)

    y        = fValLead - fVal;
    s        = z - x;
    t        = 1 + norm(fVal)^-1*max(0,(-y'*s)/(norm(s,2)^2));
    w        = y + t*norm(fVal,2)*s;
    beta_MHS = fValLead'*w/(w'*d);
    theta_M  = -fValLead'*d/(w'*d);
        
end

%==========================================================================
function alpha = backtrack(fValZ,alpha,d)

    sigma = 1e-2;
    term1 = -fValZ'*d;
    term2 = sigma*alpha*norm(fValZ,2)*norm(d,2)^2;
    while term1 < term2
        alpha = alpha - 1e-5;
        term1 = -fValZ'*d;
        term2 = sigma*alpha*norm(fValZ,2)*norm(d,2)^2;
    end
    
end
