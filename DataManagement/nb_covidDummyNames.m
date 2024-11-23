function names = nb_covidDummyNames(freq,covidDummyDates)
% Syntax:
%
% names = nb_covidDummyNames(freq)
% names = nb_covidDummyNames(freq,covidDummyDates)
%
% Description: 
%
% The dummy names for the covid-19 episode. 
% 
% Input:
% 
% - freq            : The frequency of the covid dummy.           
% 
% - covidDummyDates : A cellstr with the dates of the covid-19 crisis.
%                     Default is the period 16.03.2020 - 31.12.2021. 
%                     Hint: Use nb_month(3,2020):nb_month(12,2021).
%
% Output:
% 
% - names : A cellstr with the names of the covid dummies.
%
% See also:
% nb_ts.covidDummy, nb_covidDates
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isScalarInteger(freq)
        error([mfilename ':: The freq input must be a scalar integer.'])
    end
    
    % The covid dates
    if nargin < 2
        switch freq
            case 1
                covidDummyDates = {'2020','2021'};
            case 2
                covidDummyDates = nb_semiAnnual(1,2020):nb_semiAnnual(2,2021);
            case 4
                covidDummyDates = nb_quarter(1,2020):nb_quarter(4,2021);
            case 12
                covidDummyDates = nb_month(3,2020):nb_month(12,2021); 
            case 52
                covidDummyDates = nb_week(12,2020):nb_week(22,2020);
            otherwise
                error([mfilename ':: This method does not support the frequency ' nb_date.getFrequencyAsString(freq) '.'])
        end
    end
    
    % Find locations of dummies
    nDummies = length(covidDummyDates);
    
    % Add to variables and data
    names = nb_appendIndexes('covidDummy',1:nDummies)';
    
end
