function obj = round(obj,value,startDate,endDate,pages)
% Syntax:
%
% obj = round(obj,value,startDate,endDate,pages)
%
% Description:
%
% Round to closes value. I.e. if value is 0.25 it will round to the closes
% 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_math_ts object
% 
% - value     : The rounding value. As a double. Default is 1.
%
% - startDate : The start date of the rounding. As a date string or a
%               nb_date object. Can be empty. Default is the start date
%               of the data.
%
% - endDate   : The end date of the rounding. As a date string or a
%               nb_date object. Can be empty. Default is the end date
%               of the data.
%
% - variables : The variables to round. Can be empty. Default is to round
%               all variables.
% 
% Output:
% 
% - obj       : A nb_math_ts object with the rounded numbers.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            endDate = '';
            if nargin < 3
                startDate = '';
                if nargin < 2
                    value = 1;
                end
            end
        end
    end
    
    % Get the window selected
    [~,~,startInd,endInd,pages] = getWindow(obj,startDate,endDate,pages);

    % Round the selected data
    dat = obj.data(startInd:endInd,:,pages);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    obj.data(startInd:endInd,:,pages) = dat;
    
end
