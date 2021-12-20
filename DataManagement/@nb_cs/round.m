function obj = round(obj,value,types,variables,pages)
% Syntax:
%
% obj = round(obj,value,types,variables)
%
% Description:
%
% Round to closes value. I.e. if value is 0.25 it will round to the closes
% 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_cs object
% 
% - value     : The rounding value. As a double. Default is 1.
%
% - types     : The types to round. Can be empty. Default is to round
%               all types.
%
% - variables : The variables to round. Can be empty. Default is to round
%               all variables.
% 
% - pages     : A numerical index of the pages you want to keep.
% 
% Output:
% 
% - obj       : A nb_cs object with the rounded numbers.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = [];
        if nargin < 4
            variables = {};
            if nargin < 3
                types = {};
                if nargin < 2
                    value = 1;
                end
            end
        end
    end
    
    % Get the window selected
    [~,~,typesInd,variablesInd,pages] = getWindow(obj,types,variables,pages);

    % Round the selected data
    dat = obj.data(typesInd,variablesInd,pages);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    obj.data(startInd:endInd,variablesInd,pages) = dat;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@round,{value,types,variables,pages});
        
    end
    
end
