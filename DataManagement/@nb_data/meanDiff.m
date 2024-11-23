function obj = meanDiff(obj)
% Syntax:
%
% obj = meanDiff(obj)
%
% Description:
%
% Construct level variables that has the mean change for each period.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    data     = obj.data;
    dataD    = nb_diff(data,1);
    dataM    = mean(dataD,1,'omitnan');
    dataM    = dataM(ones(1,obj.numberOfObservations),:,:);
    obj.data = nb_undiff(dataM,data,1);
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@meanDiff);
    end

end
