function YQ = quantileDensityForecast(y0,restrictions,model,options,results,nSteps,iter,inputs)
% Syntax:
%
% YQ = nb_forecast.quantileDensityForecast(y0,restrictions,model,...
%           options,results,nSteps,iter,inputs)
%
% Description:
%
% Produce density forecast of a model that is etimated with quantile
% regression. I.e. one "point" forecast given one quantile.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    q   = options(end).quantile;
    med = false;
    if any(q == 0.5)
        ind = q == 0.5;
        q   = [sort(q(~ind)),q(ind)];
        med = true;
    else
        q = sort(q);
    end

    nq  = length(q);
    nqs = nq;
    if ~med
        nqs = nqs + 1; % Set central projection to empty
    end
    
    % We don't evaluate each quantile!
    inputs.fcstEval = '';
    
    % Forecast each quantile
    modelQ    = nb_forecast.getQuantileModel(options,model,q(1));
    YQ1       = nb_forecast.pointForecast(y0,restrictions,modelQ,options,results,nSteps,iter,[],inputs,struct());
    YQ        = nan(size(YQ1,1),size(YQ1,2),nqs);
    YQ(:,:,1) = YQ1;
    for ii = 2:nq
        modelQ     = nb_forecast.getQuantileModel(options,model,q(ii));
        YQ(:,:,ii) = nb_forecast.pointForecast(y0,restrictions,modelQ,options,results,nSteps,iter,[],inputs,struct());
    end
    
end
