function obj = hdi(obj,limits)
% Syntax:
%
% obj = hdi(obj,perc)
%
% Description:
%
% Calculate the highest density interval (hdi) over the third dimension 
% of the data of the object.
% 
% Input:
% 
% - obj    : An object of class nb_data
%
% - limits : A double with the wanted mass of the hdi of the data. E.g.
%            0.9, or [0.10,0.20].
% 
% Output:
% 
% - obj : A nb_data object with the limits of the hdis stored as different 
%         pages of the object. See the dataNames property for the ordering.
%
%         Be aware that the hdis may not be overlapping!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets < length(limits)
        error([mfilename ':: The number of datasets (pages) of the object must be at least greater than the number of calculated percentiles!'])
    end
    
    [obj.data,obj.dataNames] = nb_hdi(obj.data,limits,3);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@hdi,{limits});
        
    end
    
    
end
