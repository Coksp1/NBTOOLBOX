function obj = mstd(obj,backward,forward)
% Syntax:
%
% obj = mstd(obj,backward,forward)
%
% Description:
%
% Taking moving standard deviation of all the timeseries of the 
% nb_ts class
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - backward : Number of periods backward in time to calculate the 
%              moving std
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving std
% 
% Output:
% 
% - obj      : An nb_ts object storing the calculated moving 
%              standard deviation
% 
% Examples: 
% 
% data = nb_ts(rand(50,2)*3,'','2011Q1',{'Var1','Var2'});
% 
% mstd10 = mstd(data,9,0); % (10 year moving std)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d = obj.data;
    n = nan(size(d));
    for ii = 1 + backward: size(d,1) - forward     
        n(ii,:,:) = nanstd(d(ii - backward:ii + forward,:,:),0);
    end
    obj.data = n;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mstd,{backward,forward});
        
    end
    
end
