function [E,X,states,solution] = drawShocksAndExogenous(y0,A,B,C,ss,Qfunc,vcv,nSteps,draws,restrictions,solution,inputs,options)   
% Syntax:
%
% [E,X,solution] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,ss,Qfunc,vcv,
%                       nSteps,draws,restrictions,solution,inputs,options)   
%
% Description:
%
% Draw from the shock distribution given the conditional information.
%
% For Markov switching model this method return only one simulated horizon
% of states. I.e. to take into account the state uncertainty you need to 
% loop this function. This give much more flexibility for the user on how
% to produce the density forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscell(vcv)
        vcv = vcv{1}; % For Markov switching and DSGE models we have assumed this to be the identity matrix!
    end

    % Are we doing conditional forecasting?
    index = restrictions.index;
    if restrictions.softConditioning

        if ~isempty(inputs.missing)
            error([mfilename ':: Conditional density forecast on endogenous variables is not supported when a missing observation estimator is used.'])
        end
        try
            [~,X,states,solution] = dsge.softConditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);
        catch
            error([mfilename ':: This version of NB toolbox does not support soft conditioning.'])
        end
        [E,X]  = dsge.drawShocksForSoftConditioning(restrictions.class,solution,nSteps,draws,X);
        states = states(:,:,ones(1,draws));

    elseif restrictions.condDistribution

        if restrictions.type == 3 
            
            if ~isempty(inputs.missing)
                error([mfilename ':: Conditional density forecast on endogenous variables is not supported when a missing observation estimator is used.'])
            end
            [E,X,states,solution] = nb_forecast.conditionalOnDistributionEngine(y0,A,B,C,ss,Qfunc,nSteps,draws,restrictions,solution,inputs);
            
        else % Only restrictions on exogenous and shocks

            X      = restrictions.X(:,:,index)'; % nb_distribution object
            X      = random(X,draws,1);          % draws x 1 x nvar x nSteps 
            X      = permute(X,[3,4,1,2]);       % nvar x nSteps x draws
            E      = restrictions.E(:,:,index)'; % nb_distribution object
            E      = random(E,draws,1);          % draws x 1 x nvar x nSteps
            E      = permute(E,[3,4,1,2]);       % nvar x nSteps x draws
            states = restrictions.states(:,:,ones(1,draws));
            
        end

    elseif restrictions.type == 3 % Condition on endogenous variables with normally distributed errors
        
        if ~isempty(inputs.missing)
            error([mfilename ':: Conditional density forecast on endogenous variables is not supported when a missing observation estimator is used.'])
        end
        
        simResidual = true;
        if draws == 0
            simResidual = false;
            draws       = 1;
        end
            
        % Uses the mean of the distributions to make a point forecast
        [Et,X,states,solution] = nb_forecast.conditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);
        states                 = states(:,:,ones(1,draws));
        shockHorizon           = solution.numberOfAnticipatedPeriods - 1 + solution.nMax; 
        
        % Draw normally distributed errors around the identified mean
        if simResidual
            E = Et(:,:,ones(1,draws)) + nb_forecast.multvnrnd(vcv,shockHorizon,draws);
        else
            E = Et;
        end
        
        % No uncertainty in exogenous variables
        X = X(:,:,ones(1,draws));
        
    else % Only restrictions on exogenous and shocks
        
        if isfield(inputs,'exoProj')
            exoProj = inputs.exoProj;
        else
            exoProj = '';
        end
        X = restrictions.X(:,:,index)';
        X = X(:,:,ones(1,draws));
        if ~isempty(exoProj)
            XAR = nb_forecast.estimateAndBootstrapX(options,restrictions,draws,restrictions.start,inputs); 
            X   = [X;XAR];
        end
        E = restrictions.E(:,:,index)';
        try
            E = E(:,:,ones(1,draws)) + nb_forecast.multvnrnd(vcv,nSteps,draws);
        catch Err
            vcvCorr = nb_covrepair(vcv);
            E       = E(:,:,ones(1,draws)) + nb_forecast.multvnrnd(vcvCorr,nSteps,draws);
            if sum(vcvCorr(:)-vcv(:)) > eps^(1/4)
                rethrow(Err)
            end
        end
        states = restrictions.states(:,:,ones(1,draws));
        
    end
    
end
