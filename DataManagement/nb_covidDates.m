function [dates,drop] = nb_covidDates(freq)
% Syntax:
%
% [dates,drop] = nb_covidDates(freq)
%
% Description:
%
% Get the dates of the covid episode.
% 
% Input:
% 
% - freq : The frequency of the covid episodes.
% 
% Output:
% 
% - dates : A 1 x nDates nb_date array. 
%
% - drop  : Number of dummies set to all 0, i.e. the X number of dummies at
%           the end.
%
% See also:
% nb_ts.covidDummy, nb_covidDummyNames
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch freq
        case 1
            dates = vec(nb_year(2020),nb_year(2021));
            drop  = 0;
        case 2
            dates = vec(nb_semiAnnual(1,2020),nb_semiAnnual(2,2021));
            drop  = 1;
        case 4
            dates = vec(nb_quarter(1,2020),nb_quarter(4,2021));
            drop  = 2;
        case 12
            dates = vec(nb_month(3,2020),nb_month(12,2021));
            drop  = 6;
        case 52
            dates = vec(nb_week(12,2020),nb_week(52,2021));
            drop  = 26;
        otherwise
            error([mfilename ':: This method does not support the frequency ' nb_date.getFrequencyAsString(freq) '.'])
    end
    
end
