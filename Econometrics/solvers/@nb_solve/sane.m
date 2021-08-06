function results = sane(opt,fVal)
% Syntax:
%
% results = nb_solve.sane(opt,fVal)
%
% Description:
%
% Solve the problem using the Spectral Residual Method of 
% La Cruz and Raydan (2003). The implementation follows Varadhan and 
% Gilbert (2009) with some adjustments.
% 
% See also:
% nb_solve.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % For now set defaults
    timeSincLast  = 0;
    h             = opt.stepLength;
    exitFlag      = 1;
    x             = opt.initialXValue;
    xGlob         = x;
    fValGlob      = fVal;
    meritFVal     = inf;
    funEvals      = 1; % Already evaluated once in nb_solve.solve
    alpha         = min(1,1/norm(fVal,2));
    storeMeritVal = inf(opt.memory,1);
    kk            = 0;
    for iter = 1:opt.maxIter
        
        % Rebase evaluations
        fValPrev = fVal;  
        xPrev    = x;
        
        % Update the solution
        xPlus     = xPrev - alpha*fValPrev;
        fValPlus  = opt.F(xPlus);
        meritValP = opt.meritFunction(fValPlus);
        xMinus    = xPrev + alpha*fValPrev;
        fValMinus = opt.F(xMinus);
        meritValM = opt.meritFunction(fValMinus);
        funEvals  = funEvals + 2;
        if meritValP < meritValM
            meritVal = meritValP;
            x        = xPlus;
            fVal     = fValPlus;
        else
            meritVal = meritValM;
            x        = xMinus;
            fVal     = fValMinus;
        end
        FJF    = fVal'*((opt.F(xPrev + h*fValPrev) - fValPrev)/h);
        term   = opt.gamma*alpha*FJF;
        tested = storeMeritVal + term;
        if any(meritVal < tested) 
            if meritVal < meritFVal
                if opt.meritFunction(xGlob - xPlus) < opt.tolerance
                    timeSincLast = timeSincLast + 1;
                    if timeSincLast > opt.maxIterSinceUpdate
                        % No improvment
                        if opt.display > 1
                            nb_solve.reportStatus(opt.displayer,iter,xGlob,meritFVal,'done');
                        end
                        break
                    end
                else
                    timeSincLast = 0;
                end
                meritFVal = meritVal;
                xGlob     = xPlus;
                fValGlob  = fValPlus;
            end
        else
            % No improvment
            if opt.display > 1
                nb_solve.reportStatus(opt.displayer,iter,xGlob,meritFVal,'done');
            end
            break
        end
        
        % Check limits
        exitFlag = nb_solve.check(opt,iter,funEvals);
        if exitFlag < 1
            break
        end
        
        % Update spectral step length
        sPrev = x - xPrev;
        yPrev = fVal - fValPrev;
        alpha = abs(opt.alphaMethod(sPrev,yPrev));
        if alpha < 1e-5 || alpha > 5
            alpha = meritFVal;
        end
        if opt.display == 3
            nb_solve.reportStatus(opt.displayer,iter,xGlob,meritFVal,'iter');
        end
        
        % Update past merit functions
        if kk == opt.memory 
            kk = 1;
        else
            kk = kk + 1;
        end
        storeMeritVal(kk) = meritFVal;
        
    end
    results.x         = xGlob;
    results.fVal      = fValGlob;
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
