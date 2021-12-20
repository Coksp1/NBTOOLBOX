function [Y,E] = computeBoundedForecasts(A,B,C,ss,YF,restrictions,MUx,MUs,inputs,solution,lower,upper,belowL,aboveL,Y,E,iter)
% Syntax:
%
% [Y,E] = computeBoundedForecasts(A,B,C,ss,YF,restrictions,MUx,MUs,inputs,...
%               solution,lower,upper,belowL,aboveL,Y,E,iter)
%
% Decription:
%
% Compute bounded forecast using expected shocks.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    h = inputs.waitbar;
    if isempty(h)
        hasWaitbar = false;
    else
        hasWaitbar = true;
    end
    if hasWaitbar && h.canceling
        error([mfilename ':: User terminated'])
    end
    if iter == 6
        % Report current status in the waitbar's message field
        if hasWaitbar
            h.status3 = h.status3 + 1;
            h.text3   = ['Finished with ' int2str(h.status3) ' of ' int2str(h.maxIterations3) ' draws...'];
        end
        disp('More than 5 iteration is needed...')
        return
    end
    
    % Compute conditional forecasts (without restrictions)
    nSteps = size(Y,2) - 1;
    if iscell(A) % Break point model
        Y = nb_computeForecastAnticipatedBP(A,B,C,ss,Y,MUx,E,restrictions.states);
    else
        Y = nb_computeForecastAnticipated(A,B,C,Y,MUx,E);
    end
    
    % Check if bounds are satisfied
    bounds  = inputs.bounds;
    fields  = fieldnames(bounds);
    numF    = length(fields); 
    endoI   = zeros(1,numF);
    exoI    = zeros(1,numF);
    if iter == 1
        upper  = zeros(nSteps,numF);
        lower  = zeros(nSteps,numF);
        belowL = false(nSteps,numF);
        aboveL = false(nSteps,numF);
        YF     = Y;
    end
    endoRes = nan(nSteps,numF);
    CTs     = zeros(nSteps,size(MUs,1));
    for ii = 1:numF
        
        % Get upper and lower bound
        bound = bounds.(fields{ii}); 
        if iter == 1
            upp = bound.upper;
            if isa(upp,'function_handle')
                upper(:,ii) = upp(Y);
            else
                upper(:,ii) = upp;
            end
            
            low = bound.lower;
            if isa(low,'function_handle')
                lower(:,ii) = low(Y);
            else
                lower(:,ii) = low;
            end   
        end
        
        % Test bounds
        endoI(ii) = bound.endoInd;
        exoI(ii)  = bound.exoInd;
        y         = Y(endoI(ii),2:end)';
        belowLT   = y <= lower(:,ii) - exp(-10);
        aboveLT   = y >= upper(:,ii) + exp(-10);
        if bound.half
            if any(belowLT)
                belowLT = doHalf(belowLT,fields{ii});
            end
            if any(aboveLT)
                aboveLT = doHalf(aboveLT,fields{ii});
            end
        end
        if any(belowLT)
            belowLT = belowLT | belowL(:,ii);
        end
        if any(aboveLT)
            aboveLT = aboveLT | aboveL(:,ii);
        end
        endoRes(belowLT,ii)   = lower(belowLT,ii);
        endoRes(aboveLT,ii)   = upper(aboveLT,ii);
        y                     = YF(endoI(ii),2:end)';
        endoRes(:,ii)         = endoRes(:,ii) - y; % We only add the delta to the unadjusted
        CTs(belowLT,exoI(ii)) = nan;
        CTs(aboveLT,exoI(ii)) = nan;
        belowL(:,ii)          = belowLT;
        aboveL(:,ii)          = aboveLT;
        
    end
    
    if iscell(A) % Break point model
        ssEndo = nan(size(endoRes));
        for ii = 1:numF
            for tt = 1:size(endoRes)
                ssEndo(tt,ii) = ss{restrictions.states(tt)}(endoI(ii));
            end
        end
        endoRes = ssEndo + endoRes;
    end
    
    isNaN = isnan(endoRes);
    cont  = ~all(isNaN(:)) && any(abs(endoRes(~isNaN)) > exp(-10)); 
    if ~cont 
        % Report current status in the waitbar's message field
        if hasWaitbar
            h.status3 = h.status3 + 1;
            h.text3   = ['Finished with ' int2str(h.status3) ' of ' int2str(h.maxIterations3) ' draws...'];
        end
        return
    end
    
    % If the bounds are binding we need to identify the shocks to
    % match does restrictions (Here we only identify the restrictions with 
    % the matching shock/innovation)
    restrictions.index = 1;
    restrictions.Y     = endoRes; 
    restrictions.indY  = endoI; 
    restrictions.X     = nan(nSteps,0);
    restrictions.E     = CTs;

    % Identify the shocks to match the breached bounds
    [EE,~,~,solution] = nb_forecast.conditionalProjectionEngine(Y(:,1),A,B,C,ss,[],nSteps,restrictions,solution);

    % Cut the sample to match the old one. This is not an innocous
    % assumption!!!
    E = MUs + EE(:,1:size(MUs,2));

    % Iterate to we now that the restrictions hold for all periods
    [Y,E] = nb_forecast.computeBoundedForecasts(A,B,C,ss,YF,restrictions,MUx,MUs,inputs,solution,lower,upper,belowL,aboveL,Y,E,iter+1);
             
end

%==========================================================================
function limits = doHalf(limits,var)

    ind = find(limits);
    if all(diff(ind) == 1)
        % All bounded periods in one continues period
        halfInd             = ceil((ind(end) - ind(1) + 1)/2) + ind(1);
        limits(halfInd:end) = 0; 
    else
        error([mfilename ':: Cannot use the half option when dealing with a variable that breaches the ',...
            'bound in two (or more) separate sub-periods. Set half to false for the variable ' var '.'])
    end
    

end
