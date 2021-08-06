function obj = q2y(obj)
% Syntax:
%
% obj = q2y(obj)
%
% Description:
%
% Will for each quarter calculate the cumulative sum over the last 
% 4 quarter (Including the present). The frequency of the return 
% object will be quarterly. 
% 
% Input:
% 
% - obj     : An object of class nb_ts
% 
% Output:
% 
% - obj     : An nb_ts object where the data are the sum over 
%             the last 4 quarters.
% 
% Examples:
%
% obj = q2y(obj)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.startDate.frequency == 4
        
        xin  = obj.data;
        xout = obj.data;
        for j = 2:4
            xout = xout + [nan(j-1,obj.numberOfVariables,obj.numberOfDatasets); xin(1:end-j+1,:,:)];
        end
        obj.data = xout;
        
    else
        
        error([mfilename ':: The method q2y are only defined for nb_ts object with frequency 4 (Quarterly).'])
        
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@q2y);
        
    end

end
