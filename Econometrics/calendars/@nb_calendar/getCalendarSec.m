function calendar = getCalendarSec(obj,start,finish,modelGroup,doRecursive,fromResults) 
% Syntax:
%
% calendar = getCalendarSec(obj,start,finish,modelGroup,doRecursive,...
%   fromResults)
%
% Description:
%
% Get calendar in seconds.
% 
% Input:
% 
% - obj         : An object of class nb_SMARTDynamicCalendar.
%  
% - start       : Start date of calendar window, as a nb_day 
%                 object.
%
% - finish      : End date of calendar window, as a nb_day object.
%
% - modelGroup  : A vector of objects of class 
%                 nb_model_forecast_vintages or a cellstr where
%                 each element is on the format 'yyyymmdd' or
%                 'yyyymmddhhnnss'.
%
% - doRecursive : If the modelGroup input is a scalar 
%                 nb_model_group_vintages object you may want to 
%                 get the calender of the children instead of the 
%                 object itself. In this case this input must be 
%                 set to true. Default is true.
%
% - fromResults : Give true to take the contexts from results
%                 property instead of the forecastOutput property.
%
%                 This is only supported when modelGroup is an
%                 array of nb_model_vintages objects.
%
% Output:
% 
% - calendar : The calendar for the selected window, as a  
%              N x 1 double.
%
% Written by Kenneth Sæterhagen Paulsen

    if nargin < 6
        fromResults = false;
        if nargin < 5
            doRecursive = false;
            if nargin < 4
                modelGroup = [];
                if nargin < 3
                    finish = [];
                    if nargin < 2
                        start = [];
                    end
                end
            end
        end
    end

    calendar    = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults);
    calendarStr = num2str(calendar);
    calendarStr = strcat(calendarStr,'235959');
    calendar    = str2num(calendarStr);
    
end
