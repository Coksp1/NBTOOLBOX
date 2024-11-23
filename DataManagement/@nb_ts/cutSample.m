function obj = cutSample(obj,tolerate)
% Syntax:
%
% obj = cutSample(obj)
%
% Description:
%
% Remove leading and trailing nan values, will give an error if the sample
% still includes nan values.
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - tolerate  : Tolerate number of trailing nan. An integer greater than or
%               equal to 0.
%
% Output: 
% 
% - obj       : An object of class nb_ts
% 
% Examples:
%
% out = cutSample(in);
%
% See also
% nb_ts.shrinkSample
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        tolerate = 0;
    end

    realStartDate = obj.getRealStartDate('nb_date','all');
    realEndDate   = obj.getRealEndDate('nb_date','all');
    
    indS = realStartDate - obj.startDate + 1;
    indE = realEndDate - obj.startDate + 1 + tolerate;
    
    obj.data      = obj.data(indS:indE,:,:);
    obj.startDate = realStartDate;
    obj.endDate   = realEndDate + tolerate;
    
    if tolerate < 1
        isOK = isfinite(obj.data);
        isOK = isOK(:);
        if any(~isOK)
            error([mfilename ':: The data still contain missing observations or inf.'])
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cutSample,{tolerate});
        
    end
    
end
