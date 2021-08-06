function sigma_sq = minnesotaVariancePrior(prior,y,constant,timeTrend,H,freq,mixing,indObservedOnly,nLagsAR)
% Syntax:
%
% sigma_sq = nb_bVarEstimator.minnesotaVariancePrior(prior,y,constant,...
%   timeTrend,H,freq,mixing,indObservedOnly,nLagsAR)
%
% Description:
%
% Get the minnesota prior variance, when dealing with missing observations
% or mixed frequency data. 
%
% See also:
% nb_bVarEstimator.minnesotaMF, nb_bVarEstimator.glpMF
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nLags = nLagsAR;
    if ~isempty(freq) % MF-VAR
        
        numDep        = size(y,2) - sum(indObservedOnly);
        priorVarIndex = indObservedOnly;
        if isfield(prior,'mixing')
           if strcmpi(prior.mixing,'low')
               % Switch from using
               priorVarIndex(mixing.locLow) = false;
               priorVarIndex(mixing.loc)    = true;
               freq(mixing.locIn)           = mixing.frequency;
           end
        end
        
        % Remove mixing variables from measurment equation used for 
        % setting up the prior
        yPrior = y(:,~priorVarIndex);
        Hprior = H(~priorVarIndex,:,:);
        
        % Here we use a AR(1) specification on the highest frequency. For
        % variables on the highest frequency we use OLS, otherwise we
        % use maximum likelihood using the measurment equation of the
        % variable of interest an a AR(1) spesification of the state
        % equation (high frequency observations)
        sigma_sq = zeros(1,numDep);
        maxFreq  = max(freq);
        normFac  = nLagsAR + (1 + constant + timeTrend);
        for ii = 1:numDep

            freqi = freq(ii);
            yi    = yPrior(:,ii);
            if freqi == maxFreq 
                
                % Create lags of dependent variables
                yi = yi(~isnan(yi));
                if size(yi,1) < 3
                    if any(mixing.locIn == ii)
                        
                        % See if we have data on the low frequency
                        % variable, this is the same prior used if only
                        % the low frequency variable where observed
                        locLow = mixing.locLow(mixing.locIn == ii);
                        yi     = y(:,locLow);
                        nDep   = size(Hprior,1);   
                        Hi     = H(ii,ii:nDep:end,:);
                        if size(Hi,3) > 1
                            ind = find(any(Hi ~= 0,3),1,'last');
                        else
                            ind = find(Hi ~= 0,1,'last');
                        end
                        Hi = Hi(:,1:ind,:);
                        [~,sigma_sq(ii)] = nb_bVarEstimator.estimateARLowFreq(yi,Hi);
                        
                    else
                        error([mfilename ':: Cannot use a Minnesota Variance Prior when having less then 3 observations on any variable.'])
                    end
                    
                else
                    T_yi   = size(yi,1);
                    yLag_i = nb_mlag(yi,nLagsAR);
                    yLag_i = yLag_i(nLagsAR+1:T_yi,:);
                    y_i    = yi(nLagsAR+1:T_yi);

                    % OLS estimates of i-th equation
                    [~,~,~,~,res] = nb_ols(y_i,yLag_i,constant,timeTrend);
                    sigma_sq(ii)  = (1./(T_yi-normFac))*(res'*res);
                end
                
            else
                % Use Kalman filter
                nDep = size(Hprior,1);   
                Hi   = Hprior(ii,ii:nDep:end,:);
                if size(Hi,3) > 1
                    ind = find(any(Hi ~= 0,3),1,'last');
                else
                    ind = find(Hi ~= 0,1,'last');
                end
                Hi = Hi(:,1:ind,:);
                [~,sigma_sq(ii)] = nb_bVarEstimator.estimateARLowFreq(yi,Hi);
            end

        end
        
    else % Missing observation VAR
        
        % Here we use a AR(1) specification. But we just toss all the 
        % missing observations.
        numDep   = size(y,2);
        normFac  = nLagsAR + (1 + constant + timeTrend);
        sigma_sq = zeros(1,numDep);
        for ii = 1:numDep
        
            % Remove leading and trailing nan values
            indNaN = isnan(y(:,ii));
            s      = find(~indNaN,1);
            e      = find(~indNaN,1,'last');

            if any(indNaN(s:e)) 
                [~,~,~,res] = nb_bVarEstimator.estimateARLowFreq(y(s:e,ii),1);
            else

                % Create lags of dependent variables   
                yLag_i = nb_mlag(y(s:e,ii),1);
                yLag_i = yLag_i(2:end,:);
                y_i    = y(s+1:e,ii);
                T_yi   = size(y_i,1);
                if T_yi < nLagsAR + 3
                    error([mfilename ':: Cannot use a Minnesota Variance Prior when having less then 3 observations (adjusted for ' int2str(nLagsAR) ') on any variable.'])
                end

                % OLS estimates of i-th equation
                [~,~,~,~,res] = nb_ols(y_i,yLag_i,constant,timeTrend);

            end
            sigma_sq(ii) = (1./(T_yi-normFac))*(res'*res);

        end
        
%         sigma_sq = zeros(1,numDep);
%         for ii = 1:numDep
% 
%             % Create lags of dependent variables   
%             yi   = y(:,ii);
%             yi   = yi(~isnan(yi));
%             T_yi = size(yi,1);
%             if T_yi < nLagsAR + 3
%                 error([mfilename ':: Cannot use a Minnesota Prior when having less then 3 observations (adjusted for ' int2str(nLagsAR) ') on any variable.'])
%             end
%             yLag_i = nb_mlag(yi,nLagsAR);
%             yLag_i = yLag_i(nLagsAR+1:T_yi,:);
%             y_i    = yi(nLagsAR+1:T_yi);
%             
%             % OLS estimates of i-th equation
%             [~,~,~,~,res] = nb_ols(y_i,yLag_i,constant,timeTrend);
%             sigma_sq(ii)  = (1./(T_yi-normFac))*(res'*res);
% 
%         end

    end

end
