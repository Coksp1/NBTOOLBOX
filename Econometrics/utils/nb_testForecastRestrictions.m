function probability = nb_testForecastRestrictions(data, startDate, variables, restrictions)
% Syntax:
%
% probability = nb_testForecastRestrictions(data,startDate,variables,...
%                                           restrictions)
%
% Description:
%
% Calculate probability of passing all forecast restrictions
%
% Input:
% 
% - data          : Simulation data as a 3D double
%                   (nHorizons x nVariables x nDraws)
%
% - startDate     : First date of the data as a string or nb_date object
% 
% - variables     : The variables of the data as a cell array of strings
%
% - restrictions  : Restrictions as a n x 3 cell array,
%                   {variable, date, test}.
%
%       - variable : The variable(s) to test,
%                    as a string or cell array of strings.
% 
%       - date     : The date as a string. If a cell array is given, a copy
%                    of the restriction will be made for every given date.
%
%       - test     : Restriction test as a function handle. The value(s) of
%                    the variable(s) in 'variable' at time 'date' are passed
%                    as arguments. Should return a logical.
%
% Output:
% 
% - out : The estimated probability as a double
%
% Example:
%
% restrictions = {'QSA_URR', {'2014Q1', '2014Q2'}, @(x) x < 0; ...
%                 {'QSA_URR', 'QSA_DPQ_CP'}, '2014Q1', @(x, y) x < y};
% probability = nb_testForecastRestrictions(...
%   data, '2010Q1', {'QSA_URR', 'QSA_DPQ_CP'}, restrictions);
%
% See also 
% nb_model_generic.testForecastRestrictions
%
% Written by Henrik Halvorsen Hortemo
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Explode restrictions with multiple dates into separate restrictions
    restrictions = explodeDates(restrictions);
    
    startDate = nb_date.date2freq(startDate);
    resultPerDraw = true(1, size(data, 3));
    
    for i = 1:size(restrictions, 1)        
        varNames = cellstr(restrictions{i, 1});
        cellfun(@(varName) assert(ismember(varName, variables), ...
            ['Variable ' varName ' not found']), varNames);
        varIndices = cellfun(@(varName) ...
            find(strcmpi(varName, variables), 1), ...
            varNames, 'UniformOutput', false);
        
        dateIndex = nb_date.date2freq(restrictions{i, 2}) - startDate + 1;      
        assert(dateIndex > 0 && dateIndex <= size(data, 1), 'Date out of bounds');
        
        testFunc = restrictions{i, 3};
        testArguments = cellfun(...
            @(varIndex) data(dateIndex, varIndex, :), ...
            varIndices, 'UniformOutput', false);
        
        localResultPerDraw = testFunc(testArguments{:});
        resultPerDraw(:) = resultPerDraw(:) & localResultPerDraw(:);
    end
    
    probability = mean(resultPerDraw);
    
end

function restrictions = explodeDates(restrictions)
    for i = 1:size(restrictions, 1)
        dates = restrictions{i, 2};        
        if iscell(dates)
            restrictions{i, 2} = dates{1};
            for j = 2:length(dates)
                newRestriction = restrictions(i, :);
                newRestriction{2} = dates{j};
                restrictions(end + 1, :) = newRestriction;
            end
        end
    end
end
