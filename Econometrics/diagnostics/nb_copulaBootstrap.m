function artificial = nb_copulaBootstrap(y,draws,method,lags)
% Syntax:
%
% artificial = nb_copulaBootstrap(y,draws,method,lags)
%
% Description:
%
% Copula bootstrap time-series to generate artificial draws from
% the assumed data generating processes.
%
% The time-series are assumed stationary.
% 
% Input:
% 
% - y      : A nobs x nvar x npage double.
%
% - draws  : Number of draws to be made.
%
% - method : The method to use. Either:
%
%            > 'autocorr'       : Univariate, autocorrelation robust.
%
% - lags   : Number of lags of the autocrrelation of the series to use. 
%            Default is min(ceil(nobs^(1/3)),5).
% 
% Output:
% 
% - artificial : A nobs x nvar x npage x draws double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        lags = [];
        if nargin < 3
            method = 'autocorr';
            if nargin < 2
                draws = 1000;
            end
        end
    end
    
    [T,nvar,npage] = size(y);
    if isempty(lags)
       lags = min(ceil(T^(1/3)),5);
    end
    
    artificial = nan(T,nvar,npage,draws);
    switch lower(method)
        
        case 'autocorr'
            
            
            for pp = 1:npage
                
                % Estimate distribution
                dist = nb_distribution.sim2KernelDist(permute(y(:,:,pp),[3,2,1]));
                
                % Calculate correlation matrix
                acf = nb_autocorr(y(:,:,pp),lags);
                for vv = 1:nvar 
                    
                    % Construct stacked correlation matrix
                    I     = eye(T);
                    sigma = zeros(T,T);
                    for ii = 2:lags+1
                        repl  = [zeros(ii-1,T-ii+1);I(ii:end,ii:end)];
                        repl  = [repl,zeros(T,ii-1)]; %#ok<AGROW>
                        sigma = sigma + kron(repl,acf(ii-1,vv));
                    end
                    sigma = sigma + sigma';
                    sigma = sigma + I;

                    % Asumme that all observation comes from the same
                    % distribution
                    distVar = dist(vv);
                    distVar = distVar(:,ones(1,T));
                    copVar  = nb_copula(distVar,'sigma',sigma);
                    D       = random(copVar,draws,1);
                    
                    % Assign to output
                    artificial(:,vv,pp,:) = permute(D,[2,3,4,1]);
                    
                end
                    
            end
            
        otherwise
            error([mfilename ':: No method ' method ' supported for this function'])
    end
     
end
