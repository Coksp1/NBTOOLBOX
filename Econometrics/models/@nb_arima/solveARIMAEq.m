function tempSol = solveARIMAEq(results,opt)
% Syntax:
%
% tempSol = nb_arima.solveARIMAEq(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta = permute(results.beta,[2,1,3]);

    % Provide solution on the form y = A*y_1 + B*x + C*e
    %--------------------------------------------------------------
    numAR    = opt.AR;
    numMA    = opt.MA;
    numSAR   = opt.SAR > 0;
    SAR      = opt.SAR;
    numART   = numAR + SAR;
    numSMA   = opt.SMA > 0;
    SMA      = opt.SMA;
    numMAT   = numMA + SMA;
    const    = opt.constant;
    nPeriods = size(beta,3);

    % Seperate coefficients
    betaC   = beta(:,logical(const),:);
    betaAR  = beta(:,1 + const:const + numAR,:);
    betaMA  = beta(:,1 + const + numAR:const + numAR + numMA,:);
    betaSAR = beta(:,1 + const + numAR + numMA:const + numAR + numMA + numSAR,:);
    betaSMA = beta(:,1 + const + numAR + numMA + numSAR:const + numAR + numMA + numSAR + numSMA,:);
    betaExo = beta(:,1 + const + numAR + numMA + numSAR + numSMA:end,:);
    if isfield(opt,'transition') && ~isempty(opt.transition)
        nTran    = sum(opt.transition);
        betaExoT = betaExo(:,1:nTran,:);
        exoT     = opt.exogenous(opt.transition);
        betaExo  = betaExo(:,nTran+1:end,:);
        exo      = opt.exogenous(~opt.transition);
    else
        exoT     = {};
        betaExoT = [];
        exo      = opt.exogenous;
    end
    if numAR > 0 || numSAR > 0

        betaAR   = expandAR(betaAR,numAR,betaSAR,numSAR,SAR);
        betaMA   = expandMA(betaMA,numMA,betaSMA,numSMA,SMA);
        predBeta = [betaAR,betaMA];
        Iar      = repmat(eye(numART-1),[1,1,nPeriods]);
        Ima      = repmat(eye(numMAT-1),[1,1,nPeriods]);
        if numMAT > 0
            A = [predBeta;
                 Iar,zeros(numART-1,1+numMAT,nPeriods);
                 zeros(1,numMAT+numART,nPeriods);
                 zeros(numMAT-1,numART,nPeriods),Ima,zeros(numMAT-1,1,nPeriods)];
        else
            A = [predBeta;
                 Iar,zeros(numART-1,1,nPeriods)];
        end
        if numMAT > 0          
            C               = zeros(numART + numMAT,1,nPeriods);
            C(1,1,:)        = ones(1,1,nPeriods);
            C(1+numART,1,:) = ones(1,1,nPeriods);
        else
            C            = ones(numART,1,nPeriods);
            C(2:end,:,:) = zeros(numART-1,1,nPeriods);
        end

    else

        betaMA = expandMA(betaMA,numMA,betaSMA,numSMA,SMA);
        I      = repmat(eye(numMAT-1),[1,1,nPeriods]);
        A      = [betaMA;
                  zeros(1,numMAT,nPeriods);
                  I,zeros(numMAT-1,1,nPeriods)];
        if numMAT >0
            C          = zeros(numMAT + 1,1,nPeriods);
            C(1:2,1,:) = ones(2,1,nPeriods);
        else
            C = ones(1,1,nPeriods);
        end
        
    end
    
    if const
        exo = [{'Constant'}, exo];
    end
    if isempty(A)
        A = zeros(1,1,nPeriods);
    end
    B = zeros(size(A,1),size(betaExoT,2),nPeriods);
    if ~isempty(betaExoT)
        B(1,:,:) = betaExoT;
    end
    
    % Observation equation
    G = [betaC,betaExo];
    if isempty(G)
        G = zeros(1,1,nPeriods);
    end
    
    % The final solution
    tempSol.A   = A;
    tempSol.B   = B;
    tempSol.C   = C;
    tempSol.G   = G;
    tempSol.vcv = results.sigma;
   
    % Get the names of the residual
    res = {'E_U'};
    
    % Get the names of the endogenous + auxiliary (lags)
    endo = {'U'};
    if numART > 0
        lags = nb_cellstrlag(endo,numART-1);
        endo = [endo,lags];
    end
    
    % Append the past shock to the "endogenous" variables
    if numMAT > 0
        lags = nb_cellstrlag(res,numMAT);
        endo = [endo,lags];
    end
    
    % Get the ordering
    tempSol.endo        = endo;
    tempSol.exo         = exoT;
    tempSol.res         = res;
    tempSol.observables = opt.dependent;
    tempSol.factors     = exo;

end

%==========================================================================
function betaAR = expandAR(betaAR,numAR,betaSAR,numSAR,SAR)

    if numSAR
        rhoInit          = betaAR;
        [s1,~,s3]        = size(betaAR);
        rhoSAR           = betaSAR.*[ones(s1,1,s3),rhoInit];
        rho              = zeros(1,numAR+SAR,size(betaAR,3));
        rho(:,1:numAR,:) = rhoInit;
        ind              = SAR:SAR + numAR;
        rho(:,ind,:)     = rho(:,ind,:) + rhoSAR;
        betaAR           = rho;
    end

end

function betaMA = expandMA(betaMA,numMA,betaSMA,numSMA,SMA)

    if numSMA
        rhoInit          = betaMA;
        [s1,~,s3]        = size(betaMA);
        rhoSMA           = betaSMA.*[ones(s1,1,s3),rhoInit];
        rho              = zeros(1,numMA+SMA,size(betaMA,3));
        rho(:,1:numMA,:) = rhoInit;
        ind              = SMA:SMA + numMA;
        rho(:,ind,:)     = rho(:,ind,:) + rhoSMA;
        betaMA           = rho;
    end
    
end
