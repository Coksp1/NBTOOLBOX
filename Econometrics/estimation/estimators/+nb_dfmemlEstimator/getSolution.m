function results = getSolution(options,H,AF,QF,AI,QI,R)
% Syntax:
%
% results = nb_dfmemlEstimator.getSolution(options,H,AF,QF,AI,QI,R)
%
% Description:
%
% We want the solution on the form of equation 12 of Banbura et al. 
% (2010), "Nowcasting", but introduce the residual impact matrix to
% reduce the dimension of Q:
%
% X(t) = Z*alpha(t) + nu(t)
% 
% alpha(t) = T*alpha(t-1) + BQ*e(t)
%
% where e(t) ~ N(0,I) and nu(t) ~ N(0,R).
%
% See also:
% nb_dfmemlEstimator.initialize, nb_dfmemlEstimator.emlIteration
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen 

    N = size(H,1);
    if options.mixedFrequency
        if 5 < options.nLags
           % We have more lags in the factor VAR than in the original
           % measurement equation induced by mixed frequency mapping.
           M = (options.nLags-5)*options.nFactors;
           H = [H,zeros(N,M)];
        end
    else
        M = (options.nLags-1)*options.nFactors;
        H = [H,zeros(N,M)];
    end
    
    if options.nLagsIdiosyncratic
        % Add loading on idiosyncratic components in the measurement 
        % equation
        if options.mixedFrequency
            nHigh     = options.nHigh;
            nLow      = options.nLow;
            Hlow      = nb_dfmemlEstimator.getIdiosyncraticMapping(options);
            H2        = [eye(nHigh),zeros(nHigh,5*nLow);
                         zeros(nLow,nHigh),Hlow];
            results.Z = [H,H2];
        else
            results.Z = [H,eye(size(H,1))];
        end
    else
        if options.mixedFrequency
            % In this case the low frequency variables load one more than
            % one idiosyncratic component
            Hlow  = nb_dfmemlEstimator.getIdiosyncraticMapping(options);
            nLow  = options.nLow;
            nHigh = options.nHigh;
            H2    = [zeros(nHigh,5*nLow);Hlow];
            H     = [H,H2];    
        end
        results.Z = H;
    end

    % Get full transition matrix
    AF = AF';
    if options.mixedFrequency
        if 5 > options.nLags
            % More lags in measurement equation than in the VAR, so appen zeros
            M  = (5 - options.nLags)*options.nFactors;
            AF = [AF,zeros(options.nFactors,M)];
        end
        P = options.nFactors*max(options.nLags-1,4);
    else
        P = options.nLags-1;
    end
    A = [AF;eye(P),zeros(P,options.nFactors)];
    if options.nLagsIdiosyncratic
        if options.mixedFrequency

            % Transition of high frequency idosyncatic components
            Alpha    = cell(1,2);
            Alpha{1} = diag(AI(1:nHigh));

            % Transition of low frequency idosyncatic components
            Alpha{2} = [diag(AI(nHigh+1:end)),zeros(nLow,4*nLow);
                        eye(nLow*4),zeros(nLow*4,nLow)];

        else
            Alpha = {diag(AI)};
        end
        results.T = blkdiag(A,Alpha{:});
    else
        if options.mixedFrequency
            % Transition of low frequency idosyncatic components
            AR        = zeros(nLow); % Set AR to 0
            Alpha     = [AR,zeros(nLow,4*nLow);
                         eye(nLow*4),zeros(nLow*4,nLow)];
            results.T = blkdiag(A,Alpha);
        else
            results.T = A;
        end
    end

    % Get transition residual covariance matrix
    if options.factorRestrictions
        QF = diag(QF);
    end
    if options.nLagsIdiosyncratic || options.mixedFrequency
        results.Q = blkdiag(QF,diag(QI));
    else
        % All variances is put in the measurement error in this case
        results.Q = QF;
    end
    
    % Get residual impact matrix
    B = zeros(size(results.T,1),size(results.Q,1));
    
    % Impact of factor residuals on current factors only 
    indFac           = 1:options.nFactors;
    B(indFac,indFac) = eye(options.nFactors);
    
    if options.nLagsIdiosyncratic
        
        % Impact of high frequency residuals on current idosyncatic components
        if options.mixedFrequency
            nHigh     = options.nHigh;
            startHigh = options.nFactors*max(options.nLags,5) + 1;
        else
            nHigh     = N;
            startHigh = options.nFactors*options.nLags + 1;
        end
        
        indHigh             = startHigh:startHigh + nHigh - 1;
        indHigh2            = options.nFactors + 1:options.nFactors + nHigh;
        B(indHigh,indHigh2) = eye(nHigh);

        % Impact of low frequency residuals on current idosyncatic components
        if options.mixedFrequency
            nLow              = N - nHigh;
            startLow          = indHigh(end) + 1;
            indLow            = startLow:startLow + nLow - 1;
            indLow2           = indHigh2(end) + 1:indHigh2(end) + nLow;
            B(indLow,indLow2) = eye(nLow);
        end
    else
        if options.mixedFrequency
            nLow              = options.nLow;
            startLow          = options.nFactors*max(options.nLags,5) + 1;
            indLow            = startLow:startLow + nLow - 1;
            indLow2           = options.nFactors + 1:options.nFactors + nLow;
            B(indLow,indLow2) = eye(nLow);
        end
    end
    results.B = B; 
    
    % Standardize residuals to have a covariance matrix as the identity
    % matrix
    results = nb_dfmemlEstimator.getBQ(results);
    
    % Measurement error
    results.R = R;

end
