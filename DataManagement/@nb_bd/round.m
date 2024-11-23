function obj = round(obj,value,startDate,endDate,variables,pages)
% Syntax:
%
% obj = round(obj,value,startDate,endDate,variables)
%
% Description:
%
% Round to closest value. I.e. if value is 0.25 it will round to the
% closest 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_bd object
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
% - obj       : A nb_bd object with the rounded data.
%
% Examples:
%
% obj = nb_bd([2.6923;4.1234;9.9987],'','2012Q1','Var',[0;0;1;0],0);
% obj = round(obj,0.25)
%
% obj = 
%
%    'Time'      'Var'   
%    '2012Q1'    [2.7500]
%    '2012Q2'    [     4]
%    '2012Q3'    [   NaN]
%    '2012Q4'    [    10]
%    'Time'      'Var'    
%
% Written by Per Bjarne Bye
    
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
    
    % Get data in the full representation
    fullData = getFullRep(obj);
    
    % Round the selected data
    dat = fullData(startInd:endInd,variablesInd,pagesInd);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    fullData(startInd:endInd,variablesInd,pagesInd) = dat;
    
    % Assign properties
    [loc,ind,dataOut] = nb_bd.getLocInd(fullData);
    obj.locations     = loc;
    obj.indicator     = ind;
    obj.data          = dataOut;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@round,{value,startDate,endDate,variables,pages});
        
    end
    
end
