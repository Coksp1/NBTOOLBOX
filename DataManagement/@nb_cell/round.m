function obj = round(obj,value,pages)
% Syntax:
%
% obj = round(obj,value)
%
% Description:
%
% Round to closes value. I.e. if value is 0.25 it will round to the closes
% 0.25. E.g. 0.67 will be rounded to 0.75.
% 
% Input:
%
% - obj       : A nb_cell object
% 
% - value     : The rounding value. As a double. Default is 1.
% 
% - pages     : A numerical index of the pages you want to keep.
% 
% Output:
% 
% - obj       : A nb_cell object with the rounded numbers (only numerical 
%               values).
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pages = 1:size(obj.data,3);
        if nargin < 2
            value = 1;
        end
    end
    
    % Round the selected data
    dat = obj.data(:,:,pages);
    val = 1/value;
    dat = round(dat*val)/val;
    
    % Assign output
    obj.data(:,:,pages) = dat;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@round,{value,pages});
        
    end
    
end
