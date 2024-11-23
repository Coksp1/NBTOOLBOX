function s = getSVProcess(options,start,nSteps,fcstOnly)
% Syntax:
%
% s = nb_forecast.getSVProcess(options,start,nSteps,fcstOnly)
%
% Description:
%
% Get the stochastic volatility process when the 
% stochastic-volatility-dummy prior
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the stochastic volatility process for the whole estimation
    % sample + forecast horizon
    T     = start - options(end).estim_start_ind + 1;
    s     = nb_bVarEstimator.constructInvWeights(options.prior,T);
    sFcst = 1 + (s(T) - 1)*options.prior.rho.^(1:nSteps);  
    
    % Return only the process for the forecast horizon
    if fcstOnly
        s = sFcst;
    else
        s = [s;sFcst'];
    end
    
    % The process is the STD, so convert to the variance
    s = s.^2;

end
