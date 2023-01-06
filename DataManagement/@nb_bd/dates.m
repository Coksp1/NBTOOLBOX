function allDates = dates(obj,format,type)
% Syntax:
%
% allDates = dates(obj)
% allDates = dates(obj,format,type)
%
% Description:
%
% Get all the dates of the object. As a cellstr. Dates where all variables
% are nan are stripped.
% 
% Input:
% 
% - obj       : An object of class nb_bd
%
% - format    : See the method toDates of the nb_year, nb_semiAnnual, 
%               nb_quarter, nb_month, nb_week or nb_day classes.
%
% - type      : Either 'stripped' or 'full' (default). If 'stripped' is
%               given all dates where all observations of the data is nan
%               is removed, otherwise all dates are returned.
% 
% Output:
% 
% - allDates  : A cellstr array of the dates of the object
% 
% Examples:
%
% allDates = obj.dates();
% allDates = obj.dates('xls');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'full';
        if nargin < 2
            format = '';
        end
    end

    if ~isempty(format)
        len      = obj.numberOfObservations;
        allDates = obj.startDate.toDates(0:len-1,format);
    else
        allDates = obj.startDate:obj.endDate;
    end
    if strcmpi(type,'stripped')
        data     = getFullRep(obj);
        isNaN    = all(all(isnan(data),3),2);
        allDates = allDates(~isNaN);
    end
    
end
