function [dayNum,dayName] = weekday(obj,language)
% Syntax:
%
% [dayNum,dayName] = weekday(obj)
%
% Description:
%
% Get weekday of daily date.
% 
% Input:
% 
% - obj      : An object of class nb_day.
% 
% - language : 'english' (default) or 'norwegian'.
%
% Output:
% 
% - dayNum   : As an integer. Sun: 1, Mon: 2, Tue: 3, Wed: 4,  
%              Thu: 5, Fri: 6, Sat: 7
%
% - dayName  : As a string. (A cellstr if numel(obj) > 1)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        language = 'english';
    end

    dayNum              = rem(7 + [obj.dayNr] - 1,7);
    dayNum(dayNum == 0) = 7;
    dayNum(dayNum < 0)  = 7 + dayNum(dayNum < 0);
    
    if nargout > 1
        
        [s1,s2,s3] = size(dayNum);
        dayNum     = dayNum(:);
        dayName    = cell(s1*s2*s3,1);
        switch lower(language)
            case {'norsk','norwegian'}
                
                for ii = 1:s1*s2*s3
                    dayName{ii} = getWeekDayAsStringNor(dayNum(ii));
                end
               
            otherwise

                for ii = 1:s1*s2*s3
                    dayName{ii} = getWeekDayAsStringEng(dayNum(ii));
                end

        end
        
        if s1*s2*s3 == 1
            dayName = dayName{1};
        else
            dayName = reshape(dayName,[s1,s2,s3]);
        end
        
    end
    
end

%==========================================================================
function dayName = getWeekDayAsStringNor(dayNum)


    switch dayNum
        case 2
            dayName = 'Mandag';
        case 3
            dayName = 'Tirsdag';
        case 4
            dayName = 'Onsdag';
        case 5
            dayName = 'Torsdag';
        case 6
            dayName = 'Fredag';
        case 7
            dayName = 'Lørdag';
        otherwise
            dayName = 'Søndag';
    end
    
end

function dayName = getWeekDayAsStringEng(dayNum)

    switch dayNum
        case 2
            dayName = 'Monday';
        case 3
            dayName = 'Tuesday';
        case 4
            dayName = 'Wednesday';
        case 5
            dayName = 'Thursday';
        case 6
            dayName = 'Friday';
        case 7
            dayName = 'Saturday';
        otherwise
            dayName = 'Sunday';
    end

    
end
