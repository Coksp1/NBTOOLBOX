function allDates = dates(obj,format)
% Syntax:
%
% allDates = dates(obj)
% allDates = dates(obj,format)
%
% Description:
%
% Get all the dates of the object. As a cellstr.
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - format    : See the method toDates in the nb_date class for supported
%               formats
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        format = '';
    end

    if ~isempty(format)
        len      = obj.numberOfObservations;
        allDates = obj.startDate.toDates(0:len-1,format);
    else
        allDates = obj.startDate:obj.endDate;
    end
     
end
