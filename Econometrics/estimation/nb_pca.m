function [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = nb_pca(X,r,method,varargin)
% Syntax:
%
% F = nb_pca(X)
% [F,LAMBDA,R,varF,expl,c,sigma,e] = nb_pca(X,r,method,varargin)
%
% Description:
%
% Calculate principal component using either eigenvalue decomposition or
% single value decomposition. 
%
% The following equation applies:
%
% X = (c + F*LAMBDA + e).*sigma, e ~ N(0,R) (1)
% 
% Input:
% 
% - X       : The data as a nobs x nvar double.
%
% - r       : The number of principal component. If empty this number will
%             be found by the Bai and Ng (2002) test, see the optional
%             option crit below, i.e choose the CT part of the selection 
%             criterion; log(V(ii,F)) + CT. Where;
%
%             V(ii,F) = sum(diag(e_ii'*e_ii/T))/ii
%
%             and e_ii is the residual when ii factors are used
%
% - method  : Either 'svd' or 'eig'. Default is 'svd'.
%
%             > 'svd' : Uses single value deomposition to construct the
%                       principal components. This is the numerically best
%                       way, as the 'eig' method could be very unprecise!
%
%             > 'eig'  : Uses the eigenvalue decomposition approach instead
% 
% - Z       : Normalized (and rebalanced) version of X.
%
% Optional inputs:
%
% - 'crit'   : You can choose between the follwing selection criterion
%
%             > 1,10: ii*(NT1/NT)*log(NT/NT1); % IC_p1 and PC_p1 (default) 
%
%             > 2,11: ii*(NT1/NT)*log(CNT2); % IC_p2 and PC_p1
%
%             > 3,12: ii*log(CNT2)/CNT2; % IC_p3 and PC_p1
%
%             > 4: ii*2/T; % AIC_1
%
%             > 5: ii*log(T)/T; % BIC_1
%
%             > 6: CT = ii*2/N; % AIC_2
%       
%             > 7: ii*log(N)/N; % BIC_2
%         
%             > 8: ii*2*(NT1/NT); % AIC_3
%        
%             > 9: (ii*NT1*log(NT))/NT; % BIC_3
%
%             where NT1 = N + T, CNT2 = min(N,T), NT = N*T and ii = 1:rMax.
%
% - 'rMax'  : The maximal number of factors to test for. Must be less than
%             or equal to N. Default is N.
%
% - 'trans' : Give 'demean' if you want to demean the data in the matrix
%             X. Give 'standardize' (default) if you want to 
%             standardise the data in the matrix X. Give 'none' to drop 
%             any kind of transformation of the data in the matrix X. 
%
%             Caution: To get back X when 'demean' is given you need to add
%                      the constant terms in c. I.e;
%
%                      X = c(ones(T,1),1) + F*LAMBDA + e, e ~ N(0,R) (1')
%
%                      To get back X when 'standardise' you need to add
%                      the constant term and multiply with sigma. I.e.
%
%                      X = c(ones(T,1),:) + F*LAMBDA.*sigma(ones(T,1),:) + 
%                          eps, eps ~ N(0,R*) (1*)
%
%                      Be aware that the eps differ from e, as e is the
%                      residual from the standardised regression.
%
% - 'unbalanced' : true or false. Set to true to allow for unbalanced
%                  dataset. Default is false. If false all rows of the
%                  dataset containing nan value are removed from 
%                  calculations. The EM algorithm is essentially the one 
%                  given in the paper "Macroeconomic Forecasting Using 
%                  Diffusion Indexes" by Stock and Watson (2002). The
%                  algorithm is initialized by filling in missing values
%                  with the function nb_estimator.fillInForMissing.
%                  Caution: If all variables has leading or trailing nan,
%                  these observations will be discarded.
%
% Output:
% 
% - F       : The principal component, as a nobs x r double.
%
% - LAMBDA  : The estimated loadings, as a r x nvar
%
% - R       : The covariance matrix of the residual in (1), as a nvar x
%             nvar double.
%
% - varF    : A 1 x r double. Each column will be the variance of the 
%             corresponding column of F.
%
% - expl    : The percentage of the total variance explained by each
%             principal component. As a 1 x r double
%
% - c       : Constant in the factor equation. Double with 1 x nvar. 
%
% - sigma   : See 'trans'. Double with size 1 x nvar.
%
% - e       : Residual of the equation (1) above. As a nobs x nvar double.
%
% - Z       : The normalized version of the input X.
%
% Examples:
% load hald;
% [F,LAMBDA,R,varF,expl] = nb_pca(ingredients)
% [F2,LAMBDA2,R2,varF2,expl2] = nb_pca(ingredients,[],'eig')
%
% See also:
% nb_whiten, nb_ts.pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        method = 'svg';
        if nargin < 2
            r = [];
        end
    end

    [T,N] = size(X);
    if isempty(X)
        error([mfilename ':: X can not be empty'])
    end

    if N < 2
        error([mfilename ':: X must have at least two columns.'])
    end
    
    if T < 10
        error([mfilename ':: At least 10 periods of data is needed'])
    end
    
    % Parse optional inputs
    %----------------------------------------------------------------------
    options = parseInputs(N,varargin{:});
    if isempty(options.rMax)
        options.rMax = N;
    end
    
    % Do the estimation
    %----------------------------------------------------------------------
    isNaN = isnan(X);   
    if options.unbalanced && any(isNaN(:))
        [F,LAMBDA,varF,r,c,sigma,Z] = estimateUnbalanced(options,X,r,method);
    
        % Covariance matrix of the residual
        e = Z - F*LAMBDA';
        R = e'*e/T; 
    
    else

        % Remove the rows with missing observations
        isNaN = any(isNaN,2);
        Z     = X(~isNaN,:);

        % Standardize the data
        [Z,c,sigma,centered] = standardizeData(options,Z);

        % Estimate the principal component
        [F,LAMBDA,varF,r] = estimate(options,Z,r,method,centered);

        % Covariance matrix of the residual
        e = Z - F*LAMBDA';
        R = e'*e/T; 
        
        % Add the rows with missing observations when that is the case
        Zout           = nan(size(isNaN,1),size(Z,2));
        Zout(~isNaN,:) = Z;
        Z              = Zout;
        
        % Add the rows with missing observations when that is the case
        Fout           = nan(size(isNaN,1),r);
        Fout(~isNaN,:) = F;
        F              = Fout;

    end

    % Calculate each component contribution to the total variance
    %----------------------------------------------------------------------
    if nargout > 4
        expl = 100*varF/sum(varF);
        expl = expl(:,1:r);
    end
    if nargout > 3
        varF = varF(:,1:r);
    end
    
    % To make the output the same for all methods, we need to use a sign
    % ordering. Follow the assumption made by MATLAB function pca, which
    % is to assume that the biggest element of the columns of LAMBDA is
    % positive.
    %----------------------------------------------------------------------
    [~,maxind] = max(abs(LAMBDA), [], 1);
    [d1, d2]   = size(LAMBDA);
    colsign    = sign(LAMBDA(maxind + (0:d1:(d2-1)*d1)));
    LAMBDA     = bsxfun(@times, LAMBDA, colsign);
    LAMBDA     = LAMBDA';
    F          = bsxfun(@times, F, colsign); 
    
end

%==========================================================================
% SUB
%==========================================================================
function inputs = parseInputs(N,varargin)

    inputs            = struct();
    inputs.trans      = 'standardize'; 
    inputs.rMax       = N-1;
    inputs.crit       = 1;
    inputs.unbalanced = false;
    for ii = 1:2:size(varargin,2)

        argumentName  = varargin{ii};
        try
            argumentValue = varargin{ii+1};
            cont          = 1;
        catch  %#ok<CTCH>
            cont = 0;
        end

        if cont

            if ischar(argumentName)

                switch lower(argumentName)

                    case 'crit'
                        
                        inputs.crit = argumentValue;

                    case 'rmax'

                        inputs.rMax = argumentValue;
                        
                    case 'trans'
                        
                        inputs.trans = argumentValue;   
                        
                    case 'unbalanced'
                        
                        if ~nb_isScalarLogical(argumentValue)
                            error([mfilename ':: The ''unbalanced'' option must be true or false.'])
                        end
                        inputs.unbalanced = argumentValue; 
                        
                    otherwise

                        error([mfilename ':: The function nb_pca takes no input ' argumentName '.'])

                end

            end

        end

    end
    
end

%==========================================================================
function [Z,c,sigma,centered] = standardizeData(options,Z)

    [T,N]    = size(Z);
    centered = 0;
    if strcmpi(options.trans,'demean')
        c        = mean(Z,1,'omitnan');
        mZ       = ones(T,1)*c;
        Z        = (Z - mZ);
        centered = 1;
        sigma    = ones(1,N);
    elseif strcmpi(options.trans,'standardise') || strcmpi(options.trans,'standardize')
        c        = mean(Z,1,'omitnan');
        mZ       = ones(T,1)*c;
        sigma    = std(Z,0,1,'omitnan');
        stdZ     = ones(T,1)*sigma;
        Z        = (Z - mZ)./stdZ;
        centered = 1;
    else
        c     = zeros(1,N);
        sigma = ones(1,N);
    end

end

%==========================================================================
function [F,LAMBDA,varF,r] = estimate(options,Z,r,method,centered)

    % Estimate the principal component
    [T,N] = size(Z);
    if strcmpi(method,'eig')
        
        % Uses the eigenvalue decomposition to calculate the principal
        % component
        if isempty(r)
            
            zCov           = (Z'*Z)/(T);
            [LAMBDA, varF] = eigs(zCov,options.rMax,'lm');
            F              = Z/LAMBDA';
            
            % Test for the number of included factors
            [LAMBDA,F,~,r] = doTest(options,Z,N,T,LAMBDA,F);
            
        else
            zCov           = (Z'*Z)/(T);
            [LAMBDA, varF] = eigs(zCov,N,'lm');
            F              = Z/LAMBDA';
            if T < r
                % Append missing factors
                F(:, T+1:r)   = 0;
                varF(1,T+1:r) = 0;
            elseif size(F,2) > r
                F      = F(:,1:r);
                LAMBDA = LAMBDA(:,1:r); 
            end
        end
        
        varF = diag(varF)';
        
    else
        
        % Uses the single value decomposition to calculate the principal
        % component
        [U,sig,LAMBDA] = svd(Z,0);
        sig            = diag(sig)';
        varF           = sig.^2./(T-centered);
        F              = bsxfun(@times,U,sig);
        
        if isempty(r)

            % Test for the number of included factors
            [LAMBDA,F,~,r] = doTest(options,Z,N,T,LAMBDA,F);
            
        else

            if T < r
                % Append missing factors
                F(:, T+1:r)   = 0;
                varF(1,T+1:r) = 0;
            elseif size(F,2) > r
                F      = F(:,1:r);
                LAMBDA = LAMBDA(:,1:r); 
            end

        end
        
    end
    
end

function [LAMBDA,F,R,r] = doTest(options,Z,N,T,LAMBDA,F)

    ii   = 1:1:options.rMax;
    ii   = ii';
    crit = options.crit;
    CNT2 = min([N;T]);
    NT   = N*T;
    NT1  = N + T;
    switch crit
        case {1,10}
            CT = ii*(NT1/NT)*log(NT/NT1); % IC_p1 and PC_p1
        case {2,11}
            CT = ii*(NT1/NT)*log(CNT2); % IC_p2 and PC_p1
        case {3,12}
            CT = ii*log(CNT2)/CNT2; % IC_p3 and PC_p1
        case 4
            CT = ii*2/T; % AIC_1
        case 5 
            CT = ii*log(T)/T; % BIC_1
        case 6
            CT = ii*2/N; % AIC_2
        case 7
            CT = ii*log(N)/N; % BIC_2
        case 8
            CT = ii*2*(NT1/NT); % AIC_3
        case 9
            CT = (ii*NT1*log(NT))/NT; % BIC_3
        otherwise
            CT = (ii*NT1*log(NT))/NT; % BIC_3
    end

    LAM = LAMBDA';
    VkF = nan(options.rMax,1);
    R   = nan(N,N,options.rMax);
    for kk = 1:options.rMax
        e         = Z - F(:,1:kk)*LAM(1:kk,:);
        R(:,:,kk) = e'*e/T;
        VkF(kk)   = sum(diag(R(:,:,kk)))/N;
    end
    if crit < 4        
        IC = log(VkF) + CT;
    else
        IC = VkF + VkF(end)*CT;
    end
    [~,r] = min(IC,[],1);
    
    % Return the Factors, the factor loadings and the covariance matrix of
    % the residuals
    F      = F(:,1:r);
    LAMBDA = LAMBDA(:,1:r);
    R      = R(:,:,r);
    
end

%==========================================================================
function [F,LAMBDA,varF,r,c,sigma,Z] = estimateUnbalanced(options,X,r,method)
    
    % Standardize the data
    [X,c,sigma,centered] = standardizeData(options,X);
    
    % Initialize
    [Y,kept]   = nb_estimator.removeLeadingAndTrailingNaN(X);
    [Y,nanInd] = nb_estimator.fillInForMissing(Y);
    
    % Estimate the principal component
    [F,LAMBDA,~,r] = estimate(options,Y,r,method,centered);

    % Fill in missing obsevations
    Z = X(kept,:);
    L = inf(size(LAMBDA));
    while norm(LAMBDA(:) - L(:)) > 1e-04
        
        % Prediction step
        Zpred     = F*LAMBDA';
        Z(nanInd) = Zpred(nanInd);
        
        % Store last estimate
        L = LAMBDA;
        
        % Estimate the principal component
        [F,LAMBDA,varF,r] = estimate(options,Z,r,method,centered);
        
    end
    
    % Expand with nan
    if any(~kept)
        Zout         = nan(size(X,1),size(Z,2));
        Zout(kept,:) = Z;
        Z            = Zout;
        Fout         = nan(size(X,1),size(F,2));
        Fout(kept,:) = F;
        F            = Fout;
    end
    
end
