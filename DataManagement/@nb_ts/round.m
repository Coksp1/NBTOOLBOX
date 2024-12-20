function obj = round(obj,value,startDate,endDate,variables,pages)
% Syntax:
%
% obj = round(obj,value,startDate,endDate,variables)
%
% Description:
%
% Round to closes value. I.e. if value is 0.25 it will round to the closes
% 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_ts object
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
% - obj       : A nb_ts object with the rounded numbers.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        pages = [];
        if nargin < 5
            variables = {};
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
    end
    
    % Get the window selected
    [~,~,~,startInd,endInd,variablesInd,pagesInd] = getWindow(obj,startDate,endDate,variables,pages);

    % Round the selected data
    dat = obj.data(startInd:endInd,variablesInd,pagesInd);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    obj.data(startInd:endInd,variablesInd,pagesInd) = dat;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@round,{value,startDate,endDate,variables,pages});
        
    end
    
end
