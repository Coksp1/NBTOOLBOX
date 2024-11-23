function obj = round(obj,value,startObs,endObs,variables,pages)
% Syntax:
%
% obj = round(obj,value,startObs,endObs,variables,pages)
%
% Description:
%
% Round to closes value. I.e. if value is 0.25 it will round to the closes
% 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_data object
% 
% - value     : The rounding value. As a double. Default is 1.
%
% - startObs  : The start obs of the rounding. As an integer. Can be empty. 
%               Default is the start obs of the data.
%
% - endObs    : The end obs of the rounding. As an integer. Can be empty. 
%               Default is the end obs of the data.
%
% - variables : The variables to round. Can be empty. Default is to round
%               all variables.
%
% - pages     : A numerical index of the pages you want to keep.
%                  
% Output:
% 
% - obj       : A nb_data object with the rounded numbers.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        pages = [];
        if nargin < 5
            variables = {};
            if nargin < 4
                endObs = '';
                if nargin < 3
                    startObs = '';
                    if nargin < 2
                        value = 1;
                    end
                end
            end
        end
    end
    
    % Get the window selected
    [~,~,~,startInd,endInd,variablesInd,pages] = getWindow(obj,startObs,endObs,variables,pages);

    % Round the selected data
    dat = obj.data(startInd:endInd,variablesInd,pages);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    obj.data(startInd:endInd,variablesInd,pages) = dat;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@round,{value,startObs,endObs,variables,pages});
        
    end
    
end
