function obj = meanGrowth(obj)
% Syntax:
%
% obj = meanGrowth(obj)
%
% Description:
%
% Construct level variables that has the mean growth for each period.
% 
% Input:
% 
% - obj : An object of class nb_data
% 
% Output:
% 
% - obj : A nb_data object where the data has been updated. 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data     = obj.data;
    dataD    = growth(data,1);
    dataM    = nanmean(dataD,1);
    dataM    = dataM(ones(1,obj.numberOfObservations),:,:);
    obj.data = igrowth(dataM,data,1);
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@meanGrowth);
    end

end
