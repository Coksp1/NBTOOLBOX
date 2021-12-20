function [Emean,Xmean,states,solution] = boundedConditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution,inputs)
% Syntax:
%
% [Emean,Xmean,states,solution]...
%       = nb_forecast.boundedConditionalProjectionEngine(Y0,A,...
%           B,CE,ss,Qfunc,nSteps,restrictions,solution,inputs)
%
% Description:
%
% Identify the shocks/residuals to meet the conditional restriction given
% bounds on some endogenous variables.
%
% See also:
% nb_forecast.conditionalProjectionEngine,
% nb_forecast.condShockForecastEngine,
% nb_forecast.pointForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(restrictions.condAssumption,'before')
        error([mfilename ':: The condAssumption cannot be set to ''after'' when using the bounds input.'])
    end
    
    % Identify the shocks given the current restrictions.
    [Emean,Xmean,states,solution] = nb_forecast.conditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);
    
    % Produce a conditional forecast
    [Y,states] = nb_forecast.condShockForecastEngine(y0,A,B,C,ss,Qfunc,Xmean,Emean,states,restrictions,nSteps);
    Y          = Y';
    
    % Check if bounds are satisfied
    bounds  = inputs.bounds;
    fields  = fieldnames(bounds);
    numF    = length(fields);
    newRest = false;
    for ii = 1:numF
        
        % Get upper and lower bound
        bound = bounds.(fields{ii}); 
        upp   = bound.upper;
        low   = bound.lower;
        if isa(upp,'function_handle')
            upper = upp(Y);
        else
            upper = upp(ones(nSteps,1),1);
        end
        if isa(low,'function_handle')
            lower = low(Y);
        else
            lower = low(ones(nSteps,1),1);
        end   
        
        % Test bounds
        y      = Y(2:end,bound.endoInd);
        belowL = y <= lower - exp(-10);
        aboveL = y >= upper + exp(-10);
        
        % To prevent to fast convergance (i.e condition on to many 
        % observations). We only do half of the constrained periods
        if bound.half
            if any(belowL)
                belowL = doHalf(belowL,fields{ii});
            end
            if any(aboveL)
                aboveL = doHalf(aboveL,fields{ii});
            end
        end
        
        % Provide new restrictions for next iteration
        if any(belowL) || any(aboveL)
            restrictions.Y(belowL,bound.endoInd) = lower(belowL);
            restrictions.Y(aboveL,bound.endoInd) = upper(aboveL);
            restrictions.E(belowL,bound.exoInd)  = nan;
            restrictions.E(aboveL,bound.exoInd)  = nan;
            newRest                              = true;
        end
        
    end
    
    % Do we need to do another iteration?
    if newRest
        [Emean,Xmean,states,solution] = nb_forecast.boundedConditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution,inputs);
    end

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
