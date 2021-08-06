function [nlags,y,X] = nb_lagLengthSelection(constant,time_trend,maxLagLength,criterion,method,y,X,fixed,startInd,varargin)
% Syntax:
%
% nlags = nb_lagLengthSelection(y,X,constant,time_trend,...
%                               maxLagLength,criterion,method)
%
% Description:
%
% Lag length selection algorithm.
% 
% Input:
% 
% - constant     : 1 if constant should be included in the 
%                  regression, otherwise 0.
%
% - time_trend   : 1 if time trend should be included in the 
%                  regression, otherwise 0.
%
% - maxLagLength : The maximal number of tested lags. As a double.
%
% - criterion    : The criterion to use for the selection.
%
%                  > 'aic'  : Akaike information criterion
%
%                  > 'maic' : Modified Akaike information criterion 
%
%                  > 'sic'  : Schwarz information criterion
%
%                  > 'msic' : Modified Schwarz information 
%                             criterion 
%
%                  > 'hqc'  : Hannan-Quinn information criterion
%
%                  > 'mhqc' : Modified Hannan-Quinn information 
%                             criterion 
%
% - method       : The estimation method to use.
%
%                  > 'ols'      : Ordinary least squares. Assumes that
%                                 the residual are normally distributed.
%
%                  > 'quantile' : Quantile regression. Assumes that
%                                 the residual are normally distributed.
%                                 This may be a bad assumption!
%
% - y            : Dependent variable. As an nobs x 1 double.
%
% - X            : Exogenous regressors. As an nobs x nvar double.
%
% - fixed        : Indicate if an exogenous regressor should have
%                  fixed lag length. A 1 x nvar logical.
%
% - startInd     : The index to start the estimation from. Be aware that
%                  if you set this to 1 and maxLagLength > 0, then
%                  the data will include nan values, so startInd should be
%                  at least 1 + maxLagLength.
% 
% Output:
% 
% - nlags        : Number of (extra) lags selected for the provided 
%                  model.
%
% - y            : Dependent variable(s). Shrinked to the new 
%                  sample.
%
% - X            : Selected regressors. (Without constant and 
%                  time-trend). Shrinked to the new sample.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 9
        startInd = [];
    end

    [~,nvar] = size(X);

    % Setup the model to test
    %--------------------------------------------------------------
    if isempty(fixed)
        fixed = false(1,nvar);
    end
    
    if ~islogical(fixed)
        fixed = logical(fixed);
    end
        
    XFixed = X(:,fixed);
    XNotF  = X(:,~fixed);
    XNotFL = nb_mlag(XNotF,maxLagLength,'varFast');
    extX   = [XFixed,XNotF,XNotFL];
    ind    = size(XFixed,2);
    sVar   = size(XNotF,2);
    
    % Add constant and time trend if wanted
    %--------------------------------------------------------------
    N      = size(extX,1);
    indRho = 1;
    if time_trend 
        indRho = indRho + 1;
        if isempty(startInd)
            trend  = 1:N;
            trend  = trend';
            trendL = nb_mlag(trend,maxLagLength);
            trend  = [trend,trend,trendL];
        else
            trend  = 1:N-startInd+1;
            trend  = [zeros(startInd-1,1);trend'];
            trend  = repmat(trend,[1,maxLagLength + 2,1]);
        end
        ind    = ind + 1;
    else
        trend = nan(0,maxLagLength + 2);
    end
    
    if constant 
        extX   = [ones(N,1),extX];
        ind    = ind + 1;
        indRho = indRho + 1;
    end
    
    % Estimate the model with different lags
    %--------------------------------------------------------------
    likelihood = nan(maxLagLength + 2,1);
    numCoeff   = nan(maxLagLength + 2,1);
    kappa      = nan(maxLagLength + 2,1);
    N          = nan(maxLagLength + 2,1);
    
    switch lower(method)
        
        case 'ols'
            
            for ii = 0:maxLagLength + 1
    
                % Estimate model
                if isempty(startInd)
                    if ii == 0
                        start = 1;
                    else
                        start = ii;
                    end
                else
                   start = startInd; 
                end
                
                trend_lag        = trend(:,ii + 1);
                estX             = [trend_lag,extX];
                estX             = estX(start:end,1:ii*sVar + ind);     % Remove lags
                yM               = y(start:end,:);
                beta             = nb_ols(yM,estX);                     % Estimate the model by ols
                e                = yM - estX*beta;                      % Residual of regression
                numCoeff(ii + 1) = size(beta,1)*size(beta,2);
                
                % Likelihood given that the residual are ~N(0,vare).
                if size(e,2) == 1
                    l = nb_olsLikelihood(e,'single');    
                else
                    l = nb_olsLikelihood(e,'full');          
                end

                % Store likelihood
                N(ii + 1)          = size(estX,1);
                likelihood(ii + 1) = l;
                

                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                
                % Stored modification component of criterion
                % (Only for unit-root tests. See Eview user manual 
                % 2.)
                if size(beta,1) < indRho
                    kappa(ii + 1) = 0;
                else
                    if size(beta,1) == 0
                        kappa(ii + 1) = 0;
                    else
                        if size(beta,2) == 1
                            rho  = beta(indRho); % Coefficient on the lag
                            ylag = estX(:,indRho);
                        else
                            rho  = diag(diag(beta(indRho:indRho + size(beta,2) - 1,:))); % Coefficient on the lags
                            ylag = estX(:,indRho:indRho + size(beta,2) - 1);
                        end
                        ylagsquare     = det(ylag'*ylag);
                        vare           = det(e'*e);
                        rho            = det(rho);
                        kappa(ii + 1)  = (rho^2*ylagsquare)/vare;
                    end
                end
                
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            end
            
        case 'quantile'
            
            for ii = 0:maxLagLength + 1
    
                % Estimate model
                if isempty(startInd)
                    if ii == 0
                        start = 1;
                    else
                        start = ii;
                    end
                else
                   start = startInd; 
                end
                
                trend_lag        = trend(:,ii + 1);
                estX             = [trend_lag,extX];
                estX             = estX(start:end,1:ii*sVar + ind);     % Remove lags
                yM               = y(start:end,:);
                beta             = nb_qreg(varargin{:},yM,estX);        % Estimate the model by quantile regression
                e                = yM - estX*beta;                      % Residual of regression
                numCoeff(ii + 1) = size(beta,1)*size(beta,2);
                
                % Likelihood given that the residual are ~N(0,vare).
                if size(e,2) == 1
                    l = nb_olsLikelihood(e,'single');    
                else
                    l = nb_olsLikelihood(e,'full');          
                end

                % Store likelihood
                N(ii + 1)          = size(estX,1);
                likelihood(ii + 1) = l;
                

                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                
                % Stored modification component of criterion
                % (Only for unit-root tests. See Eview user manual 
                % 2.)
                if size(beta,1) < indRho
                    kappa(ii + 1) = 0;
                else
                    if size(beta,1) == 0
                        kappa(ii + 1) = 0;
                    else
                        if size(beta,2) == 1
                            rho  = beta(indRho); % Coefficient on the lag
                            ylag = estX(:,indRho);
                        else
                            rho  = diag(diag(beta(indRho:indRho + size(beta,2) - 1,:))); % Coefficient on the lags
                            ylag = estX(:,indRho:indRho + size(beta,2) - 1);
                        end
                        ylagsquare     = det(ylag'*ylag);
                        vare           = det(e'*e);
                        rho            = det(rho);
                        kappa(ii + 1)  = (rho^2*ylagsquare)/vare;
                    end
                end
                
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            end
            
        otherwise
            
            error([mfilename ':: The estimation method ' method 'not supported by this function.'])
            
    end
    
    % Criterion taken from Eviews User Guide II page 100.
    %--------------------------------------------------------------
    results = nb_infoCriterion(criterion,likelihood,N,numCoeff,kappa);
    
    % Get the lag length by minimizing the criterion over different
    % lag lengths and return the selected model
    %--------------------------------------------------------------
    [~, minInd] = min(results);
    nlags       = minInd - 2;
    
    % Return the selected model (without constant and time-trend)
    %--------------------------------------------------------------
    if isempty(startInd)
        
        if nlags == -1
            % All the non-fixed variables are not included in the 
            % prefered model
            X = XFixed;
        else
            extX = [XFixed,XNotF,XNotFL(:,1:nlags*sVar)];
            X    = extX(nlags + 1:end,:);
            y    = y(nlags + 1:end,:);
        end
        
    else
        if nlags == -1
            % All the non-fixed variables are not included in the 
            % prefered model
            X = XFixed(startInd:end,:);
            
        else
            extX = [XFixed,XNotF,XNotFL(:,1:nlags*sVar)];
            X    = extX(startInd:end,:);
        end
        y = y(startInd:end,:);
    end
    
end
