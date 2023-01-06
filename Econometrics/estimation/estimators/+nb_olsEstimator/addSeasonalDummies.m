function options = addSeasonalDummies(options)
% Syntax:
%
% options = nb_olsEstimator.addSeasonalDummies(options)
%
% Description:
%
% Add seasonal dummies to model.
% 
% Written by Kenneth Sæterhagen Paulsen
      
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    startDate       = options.dataStartDate;
    [ind,frequency] = nb_isQorM(startDate);
    if ind

        % Create seasonals
        period    = str2double(startDate(6:end));
        T         = size(options.data,1) + period - 1;
        seasonals = nb_seasonalDummy(T,frequency,options.seasonalDummy);
        seasonals = seasonals(period:end,:);

        % Add to data
        options.data          = [options.data,seasonals];
        seasVars              = strcat('Seasonal_',cellstr(int2str([1:frequency-1]'))'); %#ok<NBRAK>
        options.dataVariables = [options.dataVariables,seasVars];

        % Add to exogenous variables 
        options.exogenous           = [seasVars,options.exogenous];
        options.modelSelectionFixed = [true(1,frequency-1),options.modelSelectionFixed];

    end

end
