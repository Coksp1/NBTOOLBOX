function [pacf,lBound,uBound] = nb_parcorr(y,lags,errorBound,alpha,varargin)
% Syntax:
%
% pacf = nb_parcorr(y,lags)
% [pacf,lBound,uBound] = nb_parcorr(y,lags,errorBound,alpha)
%
% Description:
%
% Calculate the partial autocorrelation of a stationary time 
% series.
% 
% Input:
% 
% - y          : A nobs x nvar double matrix with the time-series.
%
% - lags       : The number of lags to include
%
% - errorBound : A string. The data must be stationary. Either:
%
%                > 'asymptotic'     : Using asymptotically derived 
%                                     formulas.
%
%                > 'paramBootstrap' : Calculated by estimating the
%                                     data generating process. And 
%                                     use an ARIMA model to 
%                                     simulate artifical 
%                                     time-series. Then the error
%                                     bands are constructed by
%                                     the wanted percentile.
%
%                > 'blockBootstrap' : Calculated by blocking the
%                                     observed series and using
%                                     these blocks to simulate
%                                     artificial time-series. Then
%                                     the error bands are 
%                                     constructed by the wanted
%                                     percentile. See nb_blockBootstrap.
%                                     The method use is 'random'.
%
% - alpha       : Significance level. As a scalar. Default is 0.05.
% 
% Optional inputs:
%
% - 'constant'  : 1 to include constant in the ARIMA model, 
%                 otherwise 0. Default is 1.
%
% - 'maxAR'     : As an integer. See the nb_arima function. Defualt
%                 is 3.
%
% - 'maxMA'     : As an integer. See the nb_arima function. Defualt
%                 is 3.
%
% - 'criterion' : As a string. See the nb_arima function. Defualt
%                 is 'aicc'.
%
% - 'method'    : As a string. See the nb_arima function. Defualt
%                 is 'hr'.
%
% Output:
% 
% - pacf   : Partial autocorrelations function. As a lags x nvar 
%            double. 
%
% - lBound : Lower bound of the error bound of the partial 
%            autocorrelation function. As a lags x nvar double. 
%
% - uBound : Upper bound of the error bound of the partial
%            autocorrelation function. As a lags x nvar double. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        alpha = 0.05;
        if nargin < 3
            errorBound = 'asymtotic';
        end
    end

    [T,numVar,numPage] = size(y);
    
    pacf = zeros(lags,numVar,numPage);
    for page = 1:numPage
    
        for var = 1:numVar
        
            yt = y(:,var,page);
            
            % Create a lagged regression matrix & preallocate for the PACF:
            ylag = nb_mlag(yt,lags);

            % Compute the PACF by fitting successive order AR models by OLS,
            % retaining the last coefficient of each regression:
            for ii = 1:lags

               b                 = nb_ols(yt(ii + 1:end),ylag(ii + 1:end,1:ii),1);
               pacf(ii,var,page) = b(end);

            end
            
        end
        
    end
    
    % Add confidence intervals
    %--------------------------------------------------------------
    % 1. Block bootstrapping
    % 2. Bootstrapping (Estimating ARIMA model)
    % 3. Asymptotic ci 
    
    if nargout > 1
       
        switch lower(errorBound)
            
            case 'asymptotic'

                nLags  = 1:lags;
                bounds = repmat(1./sqrt(T - nLags - 1)',[1,numVar,numPage]);
                Zalpha = norminv(1 - alpha/2,0,1);
                uBound = Zalpha*bounds + pacf;
                lBound = -Zalpha*bounds + pacf;
                
            case 'parambootstrap'
                
                uBound   = pacf;
                lBound   = pacf;
                numDraws = 1000;
                draws    = randn(numDraws,T,numVar,numPage);
                for ii = 1:numPage
                    
                    for jj = 1:numVar
                       
                        yt = y(:,jj,ii);
                        
                        % Fit a ARIMA model to the data
                        results = nb_arimaFunc(yt,nan,0,nan,0,0,varargin{:});
                        const   = results.constant;
                        beta    = results.beta;
                        rho     = beta(const + 1:results.AR + const);
                        theta   = beta(results.AR + const + 1:end);
                        
                        % Simulate from the estimated ARIMA model
                        sim = nan(T,numDraws);
                        for kk = 1:numDraws
                            sim(:,kk) = filter([1,theta'],[1,-rho'],draws(kk,:,jj,ii));
                        end
                        
                        if const
                            sim = sim + beta(1);
                        end
                        
                        % Estimate the autocorrelation for each 
                        % draw
                        simPACF = nb_parcorr(sim,lags);
                        
                        % Calculate bounds
                        alpha2          = alpha/2;
                        simPACF         = sort(simPACF,2,'ascend');
                        alphaL          = round(alpha2*numDraws);
                        alphaU          = numDraws - alphaL;
                        lBound(:,jj,ii) = simPACF(:,alphaL);
                        uBound(:,jj,ii) = simPACF(:,alphaU);
                        
                    end
                    
                end
                
            otherwise
                
                numDraws = 1000;
                alpha2   = alpha/2;
                alphaL   = round(alpha2*numDraws);
                alphaU   = numDraws - alphaL;
                uBound   = pacf;
                lBound   = pacf;
                for ii = 1:numPage
                
                    % Bootstrap the series
                    simTemp = nb_bootstrap(y,numDraws,errorBound);
                    simTemp = permute(simTemp,[3,1,2]);
                    
                    % Estimate the autocorrelation for each 
                    % draw
                    simPACF = nb_parcorr(simTemp,lags);

                    % Calculate bounds
                    simPACF        = sort(simPACF,3,'ascend');
                    lBound(:,:,ii) = simPACF(:,:,alphaL);
                    uBound(:,:,ii) = simPACF(:,:,alphaU);
                
                end
                 
        end
        
        
    end


end
