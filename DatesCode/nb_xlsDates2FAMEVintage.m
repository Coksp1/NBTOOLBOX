function [d,years,months,days] = nb_xlsDates2FAMEVintage(dates)
% Syntax:
%
% d                     = nb_xlsDates2FAMEVintage(dates)
% [d,years,months,days] = nb_xlsDates2FAMEVintage(dates)
%
% Description:
%
% Convert dates from the format 'dd.mm.yyyy' to 'yyyymmdd'.
% 
% Input:
% 
% - dates : A cellstr or char array where each element is on the format
%           'dd.mm.yyyy'.
% 
% Output:
% 
% - d      : A cellstr where each element is on the format 'yyyymmdd'.
%
% - years  : A double with the years of the provided dates.
%
% - months : A double with the months of the provided dates.
%
% - days   : A double with the days of the provided dates.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscellstr(dates)
        dates = char(dates);
    elseif ~ischar(dates)
        error([mfilename ':: The dates input must be a char or a cellstr.'])
    end
    if size(dates,2) ~= 10
        error([mfilename ':: The elements of the array must have 10 characters.'])
    end
    years  = dates(:,7:end);
    months = dates(:,4:5);
    days   = dates(:,1:2);
    d      = [years,months,days];
    d      = cellstr(d);
    
end
