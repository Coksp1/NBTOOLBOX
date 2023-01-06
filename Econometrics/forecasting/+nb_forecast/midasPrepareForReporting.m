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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    optLow                 = options;
    optLow.data            = options.data(options.mappingDep,:);
    optLow.dataStartDate   = options.estim_start_date_low;
    optLow.estim_start_ind = 1;
    optLow.estim_end_ind   = size(optLow.data,1);
    if isfield(options,'shift')
        if ~isempty(options.shift)
            shiftData    = double(options.shift);
            shiftData    = shiftData(options.mappingDep,:);
            optLow.shift = nb_ts(shiftData,'',options.estim_start_date_low,options.shift.variables);
        end
    end

end
