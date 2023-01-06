function [calendar,ind] = shrinkCalendar(calendar,start,finish)
% Syntax:
%
% [calendar,ind] = nb_calendar.shrinkCalendar(calendar,start,finish)
%
% Description:
%
% Shrink calendar to a provided window.
% 
% Input:
% 
% - calendar : Full calendar as a N x 1 double.
%
% - start    : A nb_day object, or empty.
%
% - finish   : A nb_day object, or empty.
% 
% Output:
% 
% - calendar : The calendar of the provided window.
%
% - ind      : A logical of size N x 1. True for each elements kept.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    indS = [];
    if ~isempty(start)
        start    = nb_date.format2string(start,'yyyymmdd');
        start    = char(start);
        start    = str2double(start);
        indS     = start <= calendar;
        calendar = calendar(indS); 
    end
    indE = [];
    if ~isempty(finish)
        finish = nb_date.format2string(finish,'yyyymmdd');
        finish = char(finish);
        finish = str2double(finish);
        indEL  = find(finish < calendar,1);
        indE   = false(size(calendar,1),1);
        if ~isempty(indEL)
            if indEL < size(calendar,1)
                indEL    = indEL - 1;
                calendar = calendar(1:indEL); 
            else
                indEL = size(calendar,1);
            end
        else
            indEL = size(calendar,1);
        end
        indE(1:indEL) = true;
    end
    if nargout > 1
        if isempty(indE) && isempty(indS)
            ind = true(size(calendar,1),1);
        elseif isempty(indE)
            ind = indS;
        elseif isempty(indS)
            ind = indE;
        else
            ind = indS & indE;
        end
    end

end
