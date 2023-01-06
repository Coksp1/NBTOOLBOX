function [b,e,X_tilda] = nb_betaProfiling(y,X,constant,AR,nExo,nLags,upper,nGrid)
% Syntax:
%
% [b,e,X_tilda] = nb_betaProfiling(y,X,constant,AR,nExo,nLags,upper,nGrid)
%
% Description:
%
% Beta profiling as in Ghysels and Qian (2019), Estimating MIDAS 
% regressions via OLS with polynomial parameter profiling.
% 
% Input:
% 
% - y        : Left hand side variable of the model. At low frequency. 
%              With size T x 1.
%
% - X        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression. These are of a higher frequency than y. Lags of
%              regressors should already be added. The nExo input must be 
%              set.
%
%              The order of the regressors must be;
%              var1_lag1, var2_lag1, var1_lag2, var2_lag2, var1_lag3
%              i.e. they can have different number of lags. See the 
%              nLags input!
%
% - constant : Set to true to add constant term to the regresson model.
%              Caution: Is not assumed to be included in X!
% 
% - AR       : Set to true to indicate that the first column of X is the
%              lagged series of y.
%
% - nExo     : Number of exogenous variables excluding the lags.
%
% - nLags    : Either a scalar integer with the number of lags of all the
%              regressors, or a vector of integers with length nExo with 
%              the number of lags of each regressor.
%
% - upper    : The upper limit on the grid of the second parameter of the
%              beta lag polynomial. Default is 40. Lower limit is allways
%              set to 1!
%
% - nGrid    : The number of grid points profiled over. Default is 80.
%
% Output:
% 
% - b        : The estimated parameters of the model y = X_tilda*beta + e.
%              The ordering is constant term, AR term, the OLS estimates 
%              and the last element is the selected value of the 
%              profiled parameter beta lag polynomial. Size is constant + 
%              AR + nExo x 1.
%
% - e        : The residual from the regresson model y = X_tilda*beta + e.
%              With size T x 1.
%
% - X_tilda  : The regressors of the model y = X_tilda*beta + e. With size
%              T x (constant + AR + nExo).
%
% Written by Kenneth Sæterhagen Paulsen

    if nargin < 8
        nGrid = 80;
        if nargin < 7
            upper = 40;
        end
    end
    
    if isscalar(nLags)
        nLags = nLags(1,ones(1,nExo));
    end

    % Seperate out AR term
    T = size(y,1);
    if AR
        yLag = X(:,1);
        X    = X(:,2:end);
    else
        yLag = ones(T,0);
    end
    if constant
        C = ones(T,1);
    else
        C = ones(T,0);
    end
    
    % Specify grid
    if nGrid == 1
        grid = upper;
    else
        bins = (upper - 1)/nGrid;
        grid = 1:bins:upper;
    end
    
    % Do profiling
    criteria = nan(nGrid,1);
    beta     = nan(constant + AR + nExo,nGrid);
    for ii = 1:nGrid
    
        % Construct regressors
        Q       = nb_betaPoly(grid(ii),nLags,nExo); 
        X_tilda = transpose(Q*X');
        X_tilda = [C,yLag,X_tilda]; %#ok<AGROW>
        
        % Estimate model with OLS
        [beta(:,ii), ~, e] = regress(y,X_tilda);
        
        % Calculate part of log likelihood that is important
        criteria(ii) = e'*e;
        
    end
    
    % Select the best candidate
    if nGrid ~= 1    
        [~,chosen] = min(criteria);
        b          = beta(:,chosen);
        theta      = grid(chosen);
    else
        b     = beta;
        theta = grid;
    end
    b = [b;theta];
    
    % Construct regressors at estimated value
    Q        = nb_betaPoly(theta,nLags,nExo); 
    X_tilda  = transpose(Q*X');
    X_tilda  = [C,yLag,X_tilda];
    
end
