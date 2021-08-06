function forecastData = getFMDynNowcast(results,options,nowcast,startFcst,fcstVar,forecastData)
% Syntax:
%
% forecastData = nb_forecast.getFMDynNowcast(results,options,nowcast,...
%                   startFcst,fcstVar,forecastData)
%
% Description:
%
% Collect nowcast from smoothed estimated when the model is of class
% nb_fmdyn and some variables are missing.
%
% See also:
% nb_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Preallocate
    dim3        = size(forecastData,3);
    iter        = size(forecastData,4);
    nowCastData = nan(nowcast,size(fcstVar,2),dim3,iter);

    % Fill from smoothed estimates
    [indS,locS] = ismember(fcstVar,results.smoothed.observables.variables);
    locS        = locS(indS);
    startFcst   = startFcst - options.estim_start_ind + 1;
    for ii = 1:iter
        nowCastData(:,indS,:,ii) = results.smoothed.observables.data(startFcst(ii)-nowcast:startFcst(ii)-1,locS);
    end
    forecastData = [nowCastData;forecastData]; 
        
end
