function obj = times(obj,DB)
% Syntax:
%
% obj = times(obj,DB)
%
% Description:
% 
% Element-wise multiplication (.*)
% 
% Caution : Will only multiply the data of corresponding variables
%           of the two objects. I.e. variable not found to be in
%           both object will result in timeseries with all nan 
%           values.
%
% Input:
% 
% - obj       : An object of class nb_ts
% 
% - DB        : An object of class nb_ts
% 
% Output:
% 
% - obj       : An nb_ts object the data results from element-wise 
%               multiplication of the data of the input objects.
% 
% Examples:
%
% obj = obj.*DB;
% 
% See also:
% nb_ts.mtimes, nb_ts.callop, nb_ts.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(DB,'nb_cs')
        obj = timesCS(obj,DB);
        return
    end
        
    if ~isa(obj,'nb_ts') || ~isa(DB,'nb_ts')
        error([mfilename,':: You can only multiply element-wise a object of class nb_ts with another object of class nb_ts or nb_cs'])
    end

    if isempty(obj) || isempty(DB)
        erro([mfilename ':: You cannot multiply a object with another if one of them is (or both are) empty.'])
    end

    [isOK,~] = checkConformity(obj,DB);

    if isOK
        obj.data = obj.data.*DB.data;
    else
        % Force the datasets to have the same variables and dates.
        % The result will be NAN values for all the missing
        % observations in the two datasets. Must have the same
        % number of datasets (pages)

        if obj.numberOfDatasets ~= DB.numberOfDatasets
            nb_ts.errorConformity(4);
        end

        dataPages     = obj.numberOfDatasets;
        temp1         = obj;
        temp1         = temp1.addDataset(DB.data,'',DB.startDate,DB.variables);
        obj.data      = temp1.data(:,:,1:dataPages).*temp1.data(:,:,dataPages + 1:dataPages + dataPages);
        obj.variables = temp1.variables;
        obj.startDate = temp1.startDate;
        obj.endDate   = temp1.endDate;
    end
    
    if obj.isUpdateable() 
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@times,{DB});
        
    end

end
