function [E,X,states,solution] = drawShocksAndExogenous(y0,model,ss,nSteps,draws,restrictions,solution,inputs,options)   
% Syntax:
%
% [E,X,solution] = nb_forecast.drawShocksAndExogenous(y0,model,ss,nSteps,
%                       draws,restrictions,solution,inputs,options)   
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if iscell(model.vcv)
        model.vcv = model.vcv{1}; % For Markov switching and DSGE models we have assumed this to be the identity matrix!
    end

    % Are we doing conditional forecasting?
    index = restrictions.index;
    if restrictions.softConditioning

        if ~isempty(inputs.missing)
            error([mfilename ':: Conditional density forecast on endogenous variables is not supported when a missing observation estimator is used.'])
        end
        try
            [~,X,states,solution] = dsge.softConditionalProjectionEngine(y0,model.A,model.B,model.C,ss,model.Qfunc,nSteps,restrictions,solution);
        catch
            error([mfilename ':: This version of NB toolbox does not support soft conditioning.'])
        end
        [E,X]  = dsge.drawShocksForSoftConditioning(restrictions.class,solution,nSteps,draws,X);
        states = states(:,:,ones(1,draws));

    elseif restrictions.condDistribution

        if restrictions.type == 3 
            
            if strcmpi(inputs.condDBType,'hard')
                error(['Cannot set condDBType to ''hard'' when the input condDB ',...
                       'is set to a nb_distribution object. Instead set distribution ',...
                       'to constant!'])
            end
            if ~isempty(inputs.missing)
                error([mfilename ':: Conditional density forecast on endogenous variables is not supported when a missing observation estimator is used.'])
            end
            [E,X,states,solution] = nb_forecast.conditionalOnDistributionEngine(y0,model,ss,nSteps,draws,restrictions,solution,inputs);
            
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
        svd = nb_forecast.checkSVDPrior(options);
        if (strcmpi(inputs.condDBType,'hard') && restrictions.kalmanFilter)
            if svd
                s = nb_forecast.getSVProcess(options,restrictions.start,nSteps,false);
            else
                s = [];
            end
            [E,X,solution] = nb_forecast.kalmanConditionalProjectionEngine(draws,model,s,nSteps,restrictions,solution);
            states         = restrictions.states(:,:,ones(1,draws));
        else
            if svd
                error(['If you have estimated a B-VAR model with the stocastic volatility ',...
                       'prior you need to set ''condDBType'' input to ''hard'' and the ',...
                       '''kalmanFilter'' input to true.'])
            end
            [Et,X,states,solution] = nb_forecast.conditionalProjectionEngine(y0,model,ss,nSteps,restrictions,solution);
            states                 = states(:,:,ones(1,draws));
            shockHorizon           = solution.numberOfAnticipatedPeriods - 1 + solution.nMax; 

            % Draw normally distributed errors around the identified mean
            if simResidual
                if strcmpi(inputs.condDBType,'hard')
                    % In this case the conditional information is assumed
                    % without uncertainty, so we should not draw from the
                    % distribution of the indentified shocks!
                    noUnc                        = isnan(restrictions.E');
                    ER                           = nb_forecast.multvnrnd(model.vcv,shockHorizon,draws);
                    ER(noUnc(:,:,ones(1,draws))) = 0;
                    E                            = Et(:,:,ones(1,draws)) + ER;
                else
                    E = Et(:,:,ones(1,draws)) + nb_forecast.multvnrnd(model.vcv,shockHorizon,draws);
                end
            else
                E = Et;
            end
            
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
            if ~isempty(XAR)
                indExo  = restrictions.indExo(:,:,restrictions.index);
                X       = [X(~indExo,:,:);XAR];
                order   = [restrictions.exo(~indExo),restrictions.exo(indExo)];
                [~,loc] = ismember(order,restrictions.exo);
                X       = X(loc,:,:);
            end
        end
        E = restrictions.E(:,:,index)';
        if nb_forecast.checkSVDPrior(options)
            s = nb_forecast.getSVProcess(options,restrictions.start,nSteps,true);
            E = E(:,:,ones(1,draws));
            for tt = 1:nSteps
                E(:,tt,:) = E(:,tt,:) + drawE(s(tt)*model.vcv,1,draws);
            end
        else
            E = E(:,:,ones(1,draws)) + drawE(model.vcv,nSteps,draws);
        end
        states = restrictions.states(:,:,ones(1,draws));
        
    end
    
end

%==========================================================================
function ED = drawE(vcv,nSteps,draws)
    try
        ED = nb_forecast.multvnrnd(vcv,nSteps,draws);
    catch Err
        vcvCorr = nb_covrepair(vcv);
        if sum(vcvCorr(:)-vcv(:)) > eps^(1/4)
            rethrow(Err)
        end
        try 
            ED = nb_forecast.multvnrnd(vcvCorr,nSteps,draws);
        catch
            rethrow(Err)
        end
    end

end
