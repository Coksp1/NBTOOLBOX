function [Y,X,E] = forecastStochasticTrend(y0,restrictions,solution,options,results,nSteps,iter,inputs)
% Syntax:
%
% [Y,X,E] = nb_forecast.forecastStochasticTrend(y0,restrictions,solution,...
%                          options,results,nSteps,iter,inputs)
%
% Description:
%
% Produce forecast of a DSGE model with a stochastic trends.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if inputs.parameterDraws > 1
        error([mfilename ':: Cannot produce density forecast of a DSGE model with stochastic trend yet.'])
    end
    
    if restrictions.softConditioning
        error([mfilename ':: Cannot produce soft conditioned density forecast of a DSGE model with stochastic trend.'])
    elseif restrictions.type == 3 
        error([mfilename ':: Conditional density forecast on endogenous variables is not supported for a DSGE model with stochastic trend.'])
    end
    
    % Produce conditional forecast on exogenous only
    [X,E] = condOnExo(inputs,restrictions,solution,nSteps);
    Y     = forecastCondOnExo(y0,X,E,solution,options,results,nSteps,iter,inputs);
    
    % Reorder forecast on endogenous (exogenous and shock are done later)
    Y = permute(Y(:,2:end,:),[2,1,3]);
    
end

%==========================================================================
function [X,E] = condOnExo(inputs,restrictions,solution,nSteps)
% Only restrictions on exogenous and shocks

    if inputs.draws > 1 || inputs.density
        
        if restrictions.condDistribution
            X = restrictions.X(:,:,restrictions.index)'; % nb_distribution object
            X = random(X,inputs.draws,1);                % draws x 1 x nvar x nSteps 
            X = permute(X,[3,4,1,2]);                    % nvar x nSteps x draws
            E = restrictions.E(:,:,restrictions.index)'; % nb_distribution object
            E = random(E,inputs.draws,1);                % draws x 1 x nvar x nSteps
            E = permute(E,[3,4,1,2]);                    % nvar x nSteps x draws
        else 
            X   = restrictions.X(:,:,restrictions.index)';
            X   = X(:,:,ones(1,inputs.draws));
            E   = restrictions.E(:,:,restrictions.index)';
            vcv = solution.vcv;
            E   = E(:,:,ones(1,inputs.draws)) + nb_forecast.multvnrnd(vcv,nSteps,inputs.draws);
        end
        
    else

        if restrictions.condDistribution
            X = restrictions.X(:,:,restrictions.index)'; % nb_distribution object
            X = mean(X); %#ok<UDIM>
            E = restrictions.E(:,:,restrictions.index)'; % nb_distribution object
            E = mean(E); %#ok<UDIM>
        else
            X = restrictions.X(:,:,restrictions.index)';
            E = restrictions.E(:,:,restrictions.index)';
        end
        
    end
    
end

%==========================================================================
function Y = forecastCondOnExo(y0,X,E,solution,options,results,nSteps,iter,inputs)

    if ~isfield(solution,'CE')
        numAntPer = 1;
    else
        numAntPer = size(solution.CE,3);
    end

    % Endogenous and steady state
    nEndo    = size(solution.A,1);
    Y        = zeros(nEndo,nSteps + 1,inputs.draws);
    Y(:,1,:) = y0(:,:,ones(1,inputs.draws));
    
    % Steady state is not updated before period 2 of IRF
    ss = solution.ss(:,iter);
    
    % Produce forecast
    for jj = 1:inputs.draws
    
        A = solution.A(:,:,iter);
        B = solution.B(:,:,iter);
        if ~isfield(solution,'CE')
            C = solution.C(:,:,iter);
        else
            C = solution.CE(:,:,:,iter);
        end
        ssjj = ss;
        for tt = 1:nSteps

            % Roll over one period
            Y(:,tt+1,jj) = A*(Y(:,tt,jj) - ssjj);
            for h = 1:numAntPer
                Y(:,tt+1,jj) = Y(:,tt+1,jj) + C(:,:,h)*E(:,tt+h-1,jj);
            end
            Y(:,tt+1,jj) = Y(:,tt+1,jj) + ssjj + B*X(:,tt,jj); 

            % Update the solution given potential stochastic trends
            % Here we assume that the stochastic trend updates based on 
            % lagged endogenous variables!
            if tt ~= nSteps
                [A,B,C,CE,ssjj,~,err] = nb_dsge.solveOneIteration(options,results,Y(:,tt+1,jj));
                if ~isempty(err)
                    error('nb_forecast:forecastCondOnExo',...
                          [mfilename ':: Forecast failed at horizon ' int2str(tt) '. Error:: ' err])
                end
                if numAntPer > 1
                    C = CE;
                end
            end

        end
        
    end
    
end

