function results = initialize(options,X)
% Syntax:
%
% results = nb_dfmemlEstimator.initialize(options,X)
%
% Description:
%
% Initialization of the expected maximum likelihood estimator of the
% dynamic factor model.
%
% Inputs:
%
% - options : A struct with estimation options. See 
%             nb_dfmemlEstimator.template or nb_dfmemlEstimator.help.
%
% - X       : A T x N double storing the data on the observables.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Spline each series separately, and use ARI model to fill in for
    % leading and trailing nan values.
    [Xest,nanInd] = nb_estimator.fillInForMissing(X);

    if ~isempty(options.blocks)
        
        % Follow Banbura et al. (2010), "Nowcasting", and block the
        % factor model. Which means that we can estimate each block
        % separatly
        if options.mixedFrequency
            nCol = 5;
        else
            nCol = 1;
        end
        
        % Measurement equation
        [T,N]   = size(X);
        nBlocks = size(options.blocks,2);
        H       = nan(N,nBlocks*nCol);
        F       = nan(T,nBlocks);
        res     = Xest;
        for ii = 1:size(options.blocks,2)
            [H(:,ii:nBlocks:nBlocks*nCol),F(:,ii),res] = doOneMeasurementBlock(options,res,nanInd,ii);
        end
            
    else
        % Measurement equation
        [H,F,res] = doMeasurement(options,Xest,nanInd);
    end
    
    % Transition matrix of factors
    [AF,QF] = doFactorTransition(options,F);

    % Transition matrix of idosyncratic components
    if options.nLagsIdiosyncratic
        [AI,QI,R] = doIdiosyncraticTransition(res,nanInd);
    else
        [AI,QI,R] = doIdiosyncatic(options,res,nanInd);
    end
    
    % Get full matrices
    results = nb_dfmemlEstimator.getSolution(options,H,AF,QF,AI,QI,R);
    
    % Initialize minus the log likelihood
    results.likelihood = inf;
    
end

%==========================================================================
function [HR,F,res] = doOneMeasurementBlock(options,res,nanInd,index)

    % Dimensions of stuff
    [~,N] = size(res);
    if options.mixedFrequency
        nCol  = 5;
        nHigh = options.nHigh;
    else
        nCol  = 1;
        nHigh = N;
    end
    
    % Preallocation
    HR = zeros(N,nCol);
    
    % Calculate the loading of the high frequency series, and estimate
    % the factors based only on the high frequency series
    indexB = options.blocks(1:nHigh,index);
    if sum(indexB) == 1
        % One variable is one factor
        F            = res(:,indexB);
        HR(indexB,1) = 1;
    else
        if options.nonStationary
            dF           = nb_pca(diff(res(:,indexB)),1,'svd','trans','none');
            F            = nb_undiff([nan(1,1);dF],1);
            HR(indexB,1) = nb_ols(res(:,indexB),F);
        else
            [F,HR(indexB,1)] = nb_pca(res(:,indexB),1,'svd','trans','none');
        end
    end
    
    if options.mixedFrequency
        
        loadingQ = options.blocks(nHigh+1:end,index);
        if any(loadingQ)
            
            % Calculate the loading of the low frequency series
            % Start with constructing the lagged factors
            Flag  = nb_mlag(F,nCol-1);
            Fclag = [F(nCol:end,:),Flag(nCol:end,:)];
            locs  = 1:options.nLow;

            for ii = locs(loadingQ)
                
                % Remove missing observations
                isNaN   = nanInd(nCol:end,nHigh+ii);
                resT    = res(nCol:end,:);
                x       = resT(~isNaN,nHigh+ii);
                Fclagii = Fclag(~isNaN,:);

                % Estimate by OLS
                FpFi = (Fclagii'*Fclagii)\eye(nCol);
                Hlow = FpFi*(Fclagii'*x);

                % Get the mapping matrix
                [R,r] = nb_dfmemlEstimator.getMapping(options,nHigh + ii);

                % Apply the mapping 
                Hlow = Hlow - FpFi*R'*((R*FpFi*R')\(R*Hlow - r));

                % Put into full measurement equation 
                HR(nHigh+ii,:) = Hlow';  

            end

            % Backcast factors by zeros
            Fclag = [zeros(nCol-1,nCol); Fclag];
            
        else
            Fclag = [F,zeros(size(F,1),nCol-1)];
        end
        
    else
        Fclag = [F,zeros(size(F,1),nCol-1)];
    end
    
    % Remove this factors from residual
    res = res - Fclag*HR';
    
end

%==========================================================================
function [HR,F,res] = doMeasurement(options,res,nanInd)

    % Dimensions of stuff
    [~,N] = size(res);
    nLags = 5;
    if options.mixedFrequency 
        nCol  = 5*options.nFactors;
        nHigh = options.nHigh;
    else
        nCol  = options.nFactors;
        nHigh = N;
    end
    nFac = options.nFactors;
    
    % Calculate the loading of the high frequency series, and estimate
    % the factors based only on the high frequency series
    HR = zeros(nCol,N);
    if options.nonStationary && options.initDiff
        dF                 = nb_pca(diff(res(:,1:nHigh)),options.nFactors,'svd','trans','none');
        F                  = nb_undiff([nan(1,options.nFactors);dF],0);
        HR(1:nFac,1:nHigh) = nb_ols(res(:,1:nHigh),F);
    else
        [F,HR(1:nFac,1:nHigh)] = nb_pca(res(:,1:nHigh),options.nFactors,'svd','trans','none');
    end
    HR = HR';
    
    if options.mixedFrequency
        
        % Calculate the loading of the low frequency series
        % Start with constructing the lagged factors
        Flag     = nb_mlag(F,nLags-1);
        Fclag    = [F(nLags:end,:),Flag(nLags:end,:)];
        nFacLags = nLags*options.nFactors;
        for ii = 1:options.nLow

            % Remove missing observations
            isNaN   = nanInd(nLags:end,nHigh+ii);
            resT    = res(nLags:end,:);
            x       = resT(~isNaN,nHigh+ii);
            Fclagii = Fclag(~isNaN,:);

            % Estimate by OLS
            FpFi = (Fclagii'*Fclagii)\eye(nFacLags);
            Hlow = FpFi*(Fclagii'*x);

            % Get the mapping matrix
            [R,r] = nb_dfmemlEstimator.getMapping(options,nHigh + ii);
            R     = kron(R,eye(options.nFactors));
            r     = repmat(r,[options.nFactors,1]);

            % Apply the mapping 
            Hlow = Hlow - FpFi*R'*((R*FpFi*R')\(R*Hlow - r));

            % Put into full measurement equation 
            HR(nHigh+ii,:) = Hlow';  

        end

        % Backcast factors by zeros
        Fclag = [zeros(nLags-1,nFacLags); Fclag];
        
    else
        Fclag = F;
    end
    
    % Remove this factors from residual
    res = res - Fclag*HR';
    
end

%==========================================================================
function [AF,QF] = doFactorTransition(options,F)

    Flag  = nb_mlag(F,options.nLags,'varFast');
    if options.factorRestrictions
        restr = cell(1,options.nFactors);
        for ii = 1:options.nFactors
            % Restrict coefficients to zero, if not own lags
            restr{ii} = false(1,options.nFactors*options.nLags);
            restr{ii}(ii:options.nFactors:end) = true;
        end
        [AF,~,~,~,resT] = nb_olsRestricted(F(options.nLags+1:end,:),Flag(options.nLags+1:end,:),restr);
        T               = size(resT,1);
        QF              = sum((resT - sum(resT,1)./T).^2, 1)./(T-1); 
    else
        % No restriction on any lags or the covariance matrix.
        [AF,~,~,~,resT] = nb_ols(F(options.nLags+1:end,:),Flag(options.nLags+1:end,:));
        T               = size(resT,1);
        QF              = (resT'*resT)/(T-1); 
    end

end

%==========================================================================
function [AI,QI,R] = doIdiosyncraticTransition(res,nanInd)
% This will only give a crude estimate of the low frequency residual
% as we just discard the mixed frequency induced lag structure of the
% idosyncartic component

    [T,N] = size(res);
    AI    = zeros(N,1);
    QI    = zeros(N,1);
    for ii = 1:N
        
        % Get real start and end observation of this series
        isNaN  = nanInd(:,ii);
        start  = find(~isNaN,1,'first');
        finish = find(~isNaN,1,'last');
        resII  = res(start:finish,ii);
        
        % Estimate AR coefficient on current variable
        if all(abs(resII) < eps)
            % A factor is one variable
            AI(ii) = 0;
            QI(ii) = 0;
        else
            resC   = resII(2:end);
            resLag = resII(1:end-1);
            AI(ii) = nb_ols(resC,resLag);
            eII    = resC - AI(ii)*resLag;
            QI(ii) = eII'*eII/(T-1);  
        end
        
    end
    
    % No measurement error
    R = zeros(N,N);
    
end

%==========================================================================
function [AI,QI,R] = doIdiosyncatic(options,res,nanInd)
% This will only give a crude estimate of the low frequency residual
% as we just discard the mixed frequency induced lag structure of the
% idosyncartic component
%
% Idiosyncratic components are not AR(1) processes as in 
% doIdiosyncraticTransition

    % Measurement error covariance matrix, assume uncorrelated idiosyncratic
    % components
    [T,N] = size(res);
    if options.mixedFrequency
        nHigh = options.nHigh;
    else
        nHigh = N;
    end
    nLow = N - nHigh;
    R    = zeros(N,N);
    for ii = 1:nHigh
        
        % Get real start and end observation of this series
        isNaN  = nanInd(:,ii);
        start  = find(~isNaN,1,'first');
        finish = find(~isNaN,1,'last');
        resII  = res(start:finish,ii);
        
        % Estimate variance in idiosyncratic component 
        if all(abs(resII) < eps)
            % A factor is one variable
            R(ii,ii) = 0;  
        else
            R(ii,ii) = resII'*resII/(T-1);  
        end
        
    end
    
    % High frequency idiosyncratic components are not part of the 
    % transition equation
    AI = [];
    if options.mixedFrequency
        QI = zeros(nLow,1);
        for ii = 1:nLow

            % Get real start and end observation of this series
            isNaN  = nanInd(:,ii);
            start  = find(~isNaN,1,'first');
            finish = find(~isNaN,1,'last');
            resII  = res(start:finish,ii);

            % Estimate variance in idiosyncratic component 
            if all(abs(resII) < eps)
                % A factor is one variable
                QI(ii) = 0;
            else
                QI(ii) = resII'*resII/(T-1);  
            end
            
        end
    else
        QI = [];
    end
    
end
