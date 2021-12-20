function [acf,lBound,uBound] = nb_autocorr(y,lags,errorBound,alpha,varargin)
% Syntax:
%
% acf = nb_autocorr(y,lags)
% [acf,lBound,uBound] = nb_autocorr(y,lags,errorBound,alpha)
%
% Description:
%
% Calculate the autocorrelation of a stationary time series.
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
%                > 'copulaBootstrap' : The observed series is boostraped
%                                      based on a copula approach. See
%                                      Paulsen (2017).
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
% - acf    : Autocorrelations function. As a lags x nvar double. 
%
% - lBound : Lower bound of the error bound of the autocorrelation
%            function. As a lags x nvar double. 
%
% - uBound : Upper bound of the error bound of the autocorrelation
%            function. As a lags x nvar double. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        alpha = 0.05;
        if nargin < 3
            errorBound = 'asymptotic';
        end
    end

    [T,numVar,numPage] = size(y);

    % Compute the autocorrelation function
    nFFT = 2^(nextpow2(T+1));
    F    = fft(y - repmat(mean(y,1),[T,1,1]),nFFT);
    F    = F.*conj(F);
    acf  = ifft(F);
    
    % Retain non-negative lags
    acf  = acf(1:(lags+1),:,:); 
    
    % Normalize
    acf  = acf./repmat(acf(1,:,:),[lags + 1,1,1]); 
    acf  = real(acf);
    acf  = acf(2:end,:,:);
    
    % Add confidence intervals
    %--------------------------------------------------------------
    % 1. Block bootstrapping
    % 2. Bootstrapping (Estimating ARIMA model)
    % 3. Asymptotic ci 
    
    if nargout > 1
       
        switch lower(errorBound)
            
            case 'asymptotic'

                bounds        = nan(lags,numVar,numPage);
                bounds(1,:,:) = 1/sqrt(T);
                for jj = 1:numPage
                    for ii = 2:lags
                        bounds(ii,:,jj) = sqrt((1 + 2*diag(acf(1:ii,:,jj)'*acf(1:ii,:,jj))')/T);
                    end
                end
                Zalpha = norminv(1 - alpha/2,0,1);
                uBound = Zalpha*bounds + acf;
                lBound = -Zalpha*bounds + acf;
                
            case 'parambootstrap'
                
                uBound   = acf;
                lBound   = acf;
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
                        
                        % Simulate from the estimated ARIMA 
                        % model
                        sim = nan(T,numDraws);
                        for kk = 1:numDraws
                            sim(:,kk) = filter([1,theta'],[1,-rho'],draws(kk,:,jj,ii));
                        end
                        
                        if const
                            sim = sim + beta(1);
                        end
                        
                        % Estimate the autocorrelation for each 
                        % draw
                        simACF = nb_autocorr(sim,lags);
                        
                        % Calculate bounds
                        alpha2          = alpha/2;
                        simACF          = sort(simACF,2,'ascend');
                        alphaL          = round(alpha2*numDraws);
                        alphaU          = numDraws - alphaL;
                        lBound(:,jj,ii) = simACF(:,alphaL);
                        uBound(:,jj,ii) = simACF(:,alphaU);
                        
                    end
                    
                end
                
            otherwise
                
                numDraws = 1000;
                alpha2   = alpha/2;
                alphaL   = round(alpha2*numDraws);
                alphaU   = numDraws - alphaL;
                uBound   = acf;
                lBound   = acf;
                for ii = 1:numPage
                
                    % Bootstrap the series
                    simTemp = nb_bootstrap(y(:,:,ii),numDraws,errorBound);
                    simTemp = permute(simTemp,[3,1,2]);
                    
                    % Estimate the autocorrelation for each 
                    % draw
                    simACF = nb_autocorr(simTemp,lags);

                    % Calculate bounds
                    simACF         = sort(simACF,3,'ascend');
                    lBound(:,:,ii) = simACF(:,:,alphaL);
                    uBound(:,:,ii) = simACF(:,:,alphaU);
                
                end
                    
        end
        
        
    end
    
end
