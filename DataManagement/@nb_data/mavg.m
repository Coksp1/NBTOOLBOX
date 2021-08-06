function obj = mavg(obj,backward,forward)
% Syntax:
%
% obj = mavg(obj,backward,forward)
%
% Description:
%
% Taking moving avarage of all the series of the nb_data object
% 
% Input:
% 
% - obj      : An object of class nb_data
% 
% - backward : Number of periods backward in time to calculate the 
%              moving average
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving average
% 
% Output:
% 
% - obj      : An nb_data object storing the calculated moving 
%              average
% 
% Examples: 
% 
% data = nb_data(rand(50,2)*3,'',1,{'Var1','Var2'});
% 
% mAvg10 = mavg(data,9,0); % (10 year moving average)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d = obj.data;
    n = nan(size(d));
    for ii = 1 + backward: size(d,1) - forward
        
        n(ii,:,:) = mean(d(ii - backward:ii + forward,:,:));
        
    end
    
    obj.data = n;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mavg,{backward,forward});
        
    end
    
end
