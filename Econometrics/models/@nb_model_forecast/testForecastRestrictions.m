function probability = testForecastRestrictions(obj, restrictions)
% Syntax:
%
% probability = testForecastRestrictions(model, restrictions)
%
% Description:
%
% Calculate probability of passing all forecast restrictions
%
% Caution: Nowcast can not yet be tested!
%
% Input:
% 
% - obj          : A nb_model_forecast object with density forecast
% 
% - restrictions : Restrictions as a n x 3 cell array,
%                  {variable, date, test}.
%
%       > variable : The variable(s) to test,
%                    as a string or cell array of strings.
% 
%       > date     : The date as a string. If a cell array is given, a 
%                    copy of the restriction will be made for every given 
%                    date.
%
%       > test     : Restriction test as a function handle. The value(s) 
%                    of the variable(s) in 'variable' at time 'date' are 
%                    passed as arguments. Should return a logical.
%
% Output:
% 
% - out : A double with the probability
%
% Example:
%
% restrictions = {'QSA_URR', {'2014Q1', '2014Q2'}, @(x) x < 0; ...
%                 {'QSA_URR', 'QSA_DPQ_CP'}, '2014Q1', @(x, y) x < y};
% probability = model.testForecastRestrictions(restrictions);
%
% See also nb_testForecastRestrictions
%
% Written by Henrik Halvorsen Hortemo 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handles scalar nb_model_forecast object.'])
    end

    forecastOutput = obj.forecastOutput;   
    
    assert(forecastOutput.draws > 1, 'No density forecast produced.');
    assert(isempty(forecastOutput.perc), 'All simulations were not returned.');
    
    % Use last recursive forecast as default
    nSteps  = forecastOutput.nSteps;
    nowcast = 0;
    if isfield(forecastOutput,'nowcast')
        nowcast = forecastOutput.nowcast;
    end
    data        = forecastOutput.data(1+nowcast:nSteps:nowcast, :, 1:end-1, end);
    startDate   = forecastOutput.start{end};
    variables   = forecastOutput.variables;   
    probability = nb_testForecastRestrictions(data, startDate, variables, restrictions);
    
end
