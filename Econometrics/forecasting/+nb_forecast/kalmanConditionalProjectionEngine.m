function [E,Xmean,solution] = kalmanConditionalProjectionEngine(draws,model,s,nSteps,restrictions,solution) 
% Syntax:
%
% [E,Xmean,solution] = nb_forecast.kalmanConditionalProjectionEngine(...
%       draws,model,s,nSteps,restrictions,solution)
%
% Description:
%
% Uses the kalman filter to draw the shocks distributions to match the
% uncertainty of the endogenous variables returned by the kalman filter.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        solution = struct;
    end
    
    if iscell(model.C)
        [nEndo,nExo,numAntPer] = size(model.C{1});
    else
        [nEndo,nExo,numAntPer] = size(model.C);
    end
    
    % Extract the conditional information
    index            = restrictions.index;
    my               = transpose(restrictions.Y(:,:,index));
    me               = transpose(restrictions.E(:,:,index));
    mx               = transpose(restrictions.X(:,:,index));
    [nVarY,nCondPer] = size(my);
    [~,nCondPerE]    = size(me);
    if isempty(mx)
        if iscell(model.B)
            mx = zeros(size(model.B{1},2),nCondPerE);
        else
            mx = zeros(size(model.B,2),nCondPerE);
        end
    end

    if numAntPer < 1
        error([mfilename,':: Number of anticipated periods cannot be less than 1'])
    end
    if numAntPer > 1
        error([mfilename,':: Number of anticipated periods cannot exceed 1, when kalman filter is set to true!'])
    end
    if nVarY == 0
        nCondPer  = 0;
    end
    
    % Maximum number of iterations forward
    nMax = max(nSteps,nCondPer);
     
    if nb_isempty(solution)
        % Store other outputs needed for later
        solution.nEndo                      = nEndo;
        solution.nExo                       = nExo;
        solution.nMax                       = nMax;                      
        solution.numberOfAnticipatedPeriods = numAntPer;
        solution.numberOfCondShocksPeriods  = nCondPer + numAntPer;
    end

    % Append history (Added in nb_forecast.prepareRestrictions)
    nObs                        = size(restrictions.YHist,2);
    myCond                      = nan(nObs,nSteps);
    myCond(restrictions.indY,:) = my;
    if isempty(model.P)
        myAll  = [restrictions.YHist', myCond];
        Xmean  = [restrictions.XHist',mx];
        myHist = restrictions.YHist;
        nHist  = size(restrictions.YHist,1);
    else
        % The model has provided us with an estimate of the one-step 
        % ahead forecast error variance, so we don't need to run the 
        % filter over the whole history! 
        % restrictions.YHist : Contains the state variables in this
        % case!
        myHist = restrictions.statesHist;
        myAll  = myCond;
        Xmean  = mx;
        nHist  = 0;
    end

    % Here we use a Kalman filter approach
    treshold                  = eps(max(myAll(:)));
    [x0,P0,~,H,R,~,~,A,C,~,B] = nb_forecast.getStateSpace(model,nObs,myHist,nSteps);
    [~,~,xs,~,~,Ps]           = nb_kalmanSmootherAndLikelihood(H,R,A,C,x0,P0,myAll,treshold,0,B,Xmean,s);
    
    % Draw from the distribution of the endogenous variables
    Ps      = Ps(1:nObs,1:nObs,nHist+1:end);
    xsDraws = xs(1:nObs,:,ones(1,draws));
    for ii = 1:nSteps
        indR = ~all(abs(Ps(:,:,ii)) < treshold,1);
        if any(indR)
            xsDraws(indR,ii + nHist,:) = xsDraws(indR,ii + nHist,:) + nb_forecast.multvnrnd(Ps(indR,indR,ii),1,draws);
        end
    end
    
    % Identify the shocks for each draw from the distribution of the
    % endogenous variables
    E = nan(nObs,nSteps,draws);
    for ii = 1:draws
        [~,~,~,Et] = nb_kalmanSmootherAndLikelihood(H,R,A,C,x0,P0,xsDraws(:,:,ii),treshold,0,B,Xmean,s);
        E(:,:,ii)  = Et(:,nHist+1:end);
    end
    Xmean = Xmean(:,nHist+1:end);
    
end
