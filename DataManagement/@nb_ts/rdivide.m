function obj = rdivide(obj,DB)
% Syntax:
%
% obj = rdivide(obj,DB)
%
% Description:
%
% Right element-wise division (./)
%
% Do right element-wise division of the matching variables of the 
% two nb_ts objects. If some variables are not found to be in both
% objects, the resulting object will have timeseries with nan
% values only for these variables.
% 
% Input:
% 
% - a         : An object of class nb_ts
% 
% - b         : An object of class nb_ts
% 
% Output:
% 
% - obj       : An object of class nb_ts, where the data are the 
%               result of the element-wise division.
% 
% Examples:
%
% obj = obj./DB;
% 
% See also:
% nb_ts.mldivide, nb_ts.mrdivide, nb_ts.callop, nb_ts.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_ts') || ~isa(DB,'nb_ts')
        error([mfilename,':: You can only divide element-wise an object of class nb_ts with another object of class nb_ts'])
    end

    if isempty(obj) || isempty(DB)
        error([mfilename ':: You cannot divide a object with another if one of them is (or both are) empty.'])
    end

    [isOK,~] = checkConformity(obj,DB);

    if isOK
        obj.data = obj.data./DB.data;
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
        obj.data      = temp1.data(:,:,1:dataPages)./temp1.data(:,:,dataPages + 1:dataPages + dataPages);
        obj.variables = temp1.variables;
        obj.startDate = temp1.startDate;
        obj.endDate   = temp1.endDate;

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@rdivide,{DB});
        
    end

end
