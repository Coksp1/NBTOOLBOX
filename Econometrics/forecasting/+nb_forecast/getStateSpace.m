function [x0,P0,d,H,R,T,c,A,B,Q,G] = getStateSpace(model,nObs,yHist,nSteps)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G] = nb_forecast.getStateSpace(model,nObs,...
%       yHist,nSteps) 
%
% Description:
%
% Go from the state space representation in the model struct to the 
% state space matrices needed by the nb_kalmansmoother_missing function.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Observation equation:
    % y(t) = d + H*x(t) + T*z(t) + v(t), v ~ N(0,R)
    nExo  = size(model.B,2);
    nEndo = size(model.A,2);
    nDep  = size(model.C,2);
    d     = zeros(nObs,1);
    if ~isempty(model.F)
        T = model.F;
    else
        T = zeros(nObs,nExo);
    end
    
    % Measurement equation during history
    if ~isempty(model.P)
        tHist = 0;
    else
        tHist = size(yHist,1);
    end
    if ~isfield(model,'G') || isempty(model.G)
        HHist                = zeros(nObs,nEndo);
        HHist(1:nObs,1:nObs) = eye(nObs);
    else
        HHist = model.G;
    end
    if size(HHist,3) == 1
        HHist = HHist(:,:,ones(1,tHist));   
    end
    
    % Measurement equation during forecast
    if ~isfield(model,'H') || isempty(model.H)
        Hfcst                = zeros(nObs,nEndo);
        Hfcst(1:nObs,1:nObs) = eye(nObs);
        Hfcst                = Hfcst(:,:,ones(1,nSteps));
    else
        Hfcst = model.H;
    end
    
    % Merge measurement equations
    H                  = zeros(nObs,nEndo,tHist + nSteps);
    H(:,:,1:tHist)     = HHist;
    H(:,:,tHist+1:end) = Hfcst;
    
    % Measurement error covariance matrix
    if ~isfield(model,'R') || isempty(model.R)
        R = zeros(nObs);
    else
        R = model.R;
        if size(R,2) == 1
            R = diag(R);
        end
    end
    
    % Have we calibrated it for forecast?
    if isfield(model,'RCalib') && ~isempty(model.RCalib)
        RAll                  = zeros(nObs,nObs,tHist + nSteps);
        RAll(:,:,1:tHist)     = R(:,:,ones(1,tHist));
        if size(model.RCalib,2) == 1
            model.RCalib = diag(model.RCalib);
        end
        RAll(:,:,tHist+1:end) = model.RCalib(:,:,ones(1,nSteps));
        R                     = RAll;
    end
    
    % State equation:
    % x(t) = c + A*x(t-1) + G*z(t) + B*u(t), u ~ N(0,Q)
    A = model.A;
    G = model.B;
    B = model.C;
    c = 0;
    Q = model.vcv;

    % Initialization of the filter
    if ~isempty(model.P)
        % yHist includes the state variable in this case!
        x0                = A*yHist(end,:)';
        P0                = zeros(nEndo,nEndo);
        P0(1:nDep,1:nDep) = model.P(1:nDep,1:nDep); % Conditional on passed filtered data!
    else
        x0       = zeros(nEndo,1);
        CQC      = model.C(:,:,1)*model.C(:,:,1)';
        [P0,err] = nb_lyapunovEquation(A,CQC);
        if err
            % In this case we just take the covariance of the raw data, and
            % assume RW!
            yHistBal = yHist(all(~isnan(yHist),2),:);
            nLags    = size(A,1)/size(yHistBal,2) - 1;
            covMat   = nb_autocovMat(yHistBal,nLags);
            P0       = nb_constructStackedCorrelationMatrix(covMat);
        end
    end

end
