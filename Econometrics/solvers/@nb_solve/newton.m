function results = newton(opt,fVal)
% Syntax:
%
% results = nb_solve.newton(opt,fVal)
%
% Description:
%
% Solve the problem using the Newton-Raphson algorithm.
% 
% See also:
% nb_solve.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    exitFlag     = 1;
    x            = opt.initialXValue;
    funEvals     = 1; % Already evaluated once in nb_solve.solve
    meritFVal    = [];
    meritXChange = [];
    for iter = 1:opt.maxIter
        
        JAC      = opt.JF(x);
        funEvals = funEvals + 1;
        if 1/condest(JAC) < eps
            if any(~isfinite(JAC(:)))
                exitFlag = -5;
                break
            else
                exitFlag = -4;
                break
            end
        end
        fValPrev = fVal;   
        xPrev    = x;
        x        = xPrev - JAC\fValPrev;
        
        fVal     = opt.F(x);
        funEvals = funEvals + 1;
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
    results.jacobian     = JAC;
    results.exitFlag     = exitFlag;
    results.iter         = iter;
    results.funEvals     = funEvals;
    
    if opt.display > 0
        if exitFlag < 1
            nb_solve.reportError(opt.displayer,exitFlag);
        end
    end

end
