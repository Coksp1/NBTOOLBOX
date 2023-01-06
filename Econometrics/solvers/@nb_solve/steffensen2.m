function results = steffensen2(opt,fVal)
% Syntax:
%
% results = nb_solve.steffensen2(opt,fVal)
%
% Description:
%
% Solve the problem using a two step version of the Steffensen algorithm.
% 
% See also:
% nb_solve.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    exitFlag     = 1;
    x            = opt.initialXValue;
    m            = size(x,1);
    funEvals     = 1; % Already evaluated once in nb_solve.solve
    meritFVal    = [];
    meritXChange = [];
    for iter = 1:opt.maxIter
        
        fValPrev = fVal;  
        xPrev    = x;
        
        % First step
        w        = xPrev + fValPrev;
        DDO      = nb_jacobian(opt.F,x,w);
        funEvals = funEvals + m*2;
        if 1/condest(DDO) < eps
            if any(~isfinite(DDO(:)))
                exitFlag = -5;
                break
            else
                exitFlag = -4;
                break
            end
        end 
        z = xPrev - DDO\fValPrev;
        
        % Secon step
        x        = z - DDO\opt.F(z);
        fVal     = opt.F(x);
        funEvals = funEvals + 2;
        if any(~isfinite(fVal(:)))
            exitFlag = -6;
            break
        end
        
        % Check for convergence
        meritFVal    = opt.meritFunction(fVal);
        meritXChange = opt.meritFunction(x - xPrev);
        if opt.criteria == 1
            critVal = meritFVal;
        else
            critVal = meritXChange;
        end
        if critVal < opt.tolerance
            if opt.display > 1
                nb_solve.reportStatus(opt.displayer,iter,x,meritFVal,'done');
            end
            break
        end
        
        % Check limits
        exitFlag = nb_solve.check(opt,iter,funEvals);
        if exitFlag < 1
            break
        end
        if opt.display == 3
            nb_solve.reportStatus(opt.displayer,iter,x,meritFVal,'iter');
        end
        
    end
    results.x            = x;
    results.fVal         = fVal;
    results.meritFVal    = meritFVal;
    results.meritXChange = meritXChange;
    results.exitFlag     = exitFlag;
    results.iter         = iter;
    results.funEvals     = funEvals;
    
    if opt.display > 0
        if exitFlag < 1
            nb_solve.reportError(opt.displayer,exitFlag);
        end
    end

end
