function indexes = findIndexesOfDates(startDate,endDate,dates)
% Syntax: 
%
% indexes = nb_ts.findIndexesOfDates(startDate,endDate,dates)
%
% Description:
%
% A static method of the nb_ts class.
%
% Find indexes of dates in the interval between startDate and endDate.
% 
% Input:
% 
% - startDate : Start date of the interval. As a nb_date object.
% 
% - endDate   : Start date of the interval. As a nb_date object.
%
% - dates     : A vector of nb_date object, cellstr or a cell array where
%               all elements are a nb_date object.
% 
% Output:
% 
% - indexes   : A logical array with length endDate - startDate + 1. Where 
%               each element matching the dates input is set to true.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iscellstr(dates)
        datesObj = nb_date.cell2Date(dates,startDate.frequency);
    elseif isa(dates,'nb_date')
        datesObj = dates(:);
    elseif iscell(dates)
        try
            datesObj = vertcat(dates{:});
        catch
            error(['The dates input must be a vector of nb_date object, ',...
                   'cellstr or a cell array where each element is a ',...
                   'nb_date object with the same frequency.'])
        end
    else
        error(['The dates input must be a vector of nb_date object, ',...
               'cellstr or a cell array where each element is a ',...
               'nb_date object with the same frequency.'])
    end
    indexes = ismember(startDate:endDate,toString(datesObj));

end
