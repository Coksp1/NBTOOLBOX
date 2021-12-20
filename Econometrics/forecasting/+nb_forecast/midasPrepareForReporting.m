function optLow = midasPrepareForReporting(options)
% Syntax:
%
% optLow = nb_forecast.midasPrepareForReporting(options)
%
% Description:
%
% Create reported variables based on simulated forecast.
% 
% See also:
% nb_forecast.midasPointForecast, nb_forecast.midasDensityForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    optLow                 = options;
    optLow.data            = options.data(options.start_low:options.increment:options.end_low,:);
    optLow.dataStartDate   = options.estim_start_date_low;
    optLow.estim_start_ind = 1;
    optLow.estim_end_ind   = size(optLow.data,1);
    shiftData              = double(options.shift);
    shiftData              = shiftData(options.start_low:options.increment:options.end_low,:);
    optLow.shift           = nb_ts(shiftData,'',options.estim_start_date_low,options.shift.variables);

end
