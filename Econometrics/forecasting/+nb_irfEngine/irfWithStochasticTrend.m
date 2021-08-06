function irfData = irfWithStochasticTrend(solution,options,inputs,results)
% Syntax:
%
% irfData = nb_irfEngine.irfWithStochasticTrend(solution,options,...
%                   inputs,results)
%
% Description:
%
% Produce point IRF of a DSGE model with stochastic trend.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    periods = inputs.periods;
    shocks  = inputs.shocks;
    res     = solution.res;
    
    % Exogenous and shocks
    if isempty(solution.B)
        X = zeros(0,periods);
    else
        % Observation block is added
        X = ones(1,periods);
    end
    if ~isfield(solution,'CE')
        numAntPer = 1;
    else
        numAntPer = size(solution.CE,3);
    end
    E = zeros(length(res),periods + numAntPer - 1);
    
    % Endogenous and steady state
    stInit   = nb_dsge.interpretStochasticTrendInit(options.parser,options.stochasticTrendInit,results.beta);
    nEndo    = size(solution.A,1);
    nShocks  = length(shocks);
    Y        = zeros(nEndo,periods + 1,nShocks);
    init     = solution.ss + solution.B + stInit;
    Y(:,1,:) = init(:,:,ones(1,nShocks));
    ss       = Y;
    
    % Approximation point (steady state) is not updated before period 2 of 
    % the IRF
    ss(:,2,:) = solution.ss; 
    
    % A new state for each iteration
    inputs.states = 2:periods + 1; 

    % Produce IRFs
    for jj = 1:nShocks

        indS       = strcmpi(shocks{jj},res);
        ET         = E;
        ET(indS,1) = inputs.sign; % One standard deviation innovation  
        
        A = solution.A(:,:,1);
        B = solution.B(:,:,1);
        if ~isfield(solution,'CE')
            C = solution.C(:,:,1);
        else
            C = solution.CE(:,:,:,1);
        end
        for tt = 1:periods

            % Roll over one period
            Y(:,tt+1,jj) = A*(Y(:,tt,jj) - ss(:,tt+1,jj));
            for h = 1:numAntPer
                Y(:,tt+1,jj) = Y(:,tt+1,jj) + C(:,:,h)*ET(:,tt+h-1);
            end
            Y(:,tt+1,jj) = Y(:,tt+1,jj) + ss(:,tt+1,jj) + B*X(:,tt); 
        
            % Update the solution given potential stochastic trends
            % Here we assume that the stochastic trend updates based on 
            % lagged endogenous variables!
            if tt ~= periods
                [A,B,C,CE,ssTT,~,err] = nb_dsge.solveOneIteration(options,results,Y(:,tt+1,jj));
                if ~isempty(err)
                    error('nb_irfEngine:irfWithStochasticTrend',...
                          [mfilename ':: IRF failed at iteration ' int2str(tt) ' for shock ' ,...
                           shocks{jj} ' Error:: ' err])
                end
                ss(:,tt+2,jj) = ssTT;
                if numAntPer > 1
                    C = CE;
                end
            end
            
        end

    end
    
    % Collect, normalize or transform IRFs
    irfData = nb_irfEngine.collect(options,inputs,Y,solution.endo,results,ss);

end
