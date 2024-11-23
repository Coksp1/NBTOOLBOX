function ARcoeffs = getARCoeffs(y,T,constant,timeTrend,indCovid)
% Syntax:
%
% ARcoeffs = nb_bVarEstimator.getARCoeffs(y,T,constant,timeTrend,indCovid)
%
% Description:
%
% Get OLS estimate of individual AR(1) models.
% 
% See also:
% nb_bVarEstimator.minnesota, nb_bVarEstimator.glp
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        indCovid = [];
    end

    ARcoeffs = nan(1,size(y,2));
    for ii = 1:size(y,2)
        
        % Create lags of dependent variables   
        yLag_i = nb_mlag(y(:,ii),1);
        yLag_i = yLag_i(2:T,:);
        y_i    = y(2:T,ii);

        if ~isempty(indCovid)
            y_i    = y_i(indCovid(2:end));
            yLag_i = yLag_i(indCovid(2:end));
        end

        % OLS estimates of i-th equation
        beta         = nb_ols(y_i,yLag_i,constant,timeTrend);
        ARcoeffs(ii) = beta(constant+timeTrend+1);
        
    end

end
