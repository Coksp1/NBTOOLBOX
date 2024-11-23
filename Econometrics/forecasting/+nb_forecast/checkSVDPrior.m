function svd = checkSVDPrior(options)
% Syntax:
%
% svd = nb_forecast.checkSVDPrior(options)
%
% Description:
%
% Check if the stochastic-volatility-dummy prior is used for a VAR model.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    svd = false;
    if isfield(options,'prior')
        if isfield(options.prior,'SVD')
            svd = options.prior.SVD;
        end
    end

end
