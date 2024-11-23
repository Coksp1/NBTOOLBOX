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
% two nb_data objects. If some variables are not found to be in both
% objects, the resulting object will have series with nan values 
% only for these variables.
% 
% Input:
% 
% - a         : An object of class nb_data
% 
% - b         : An object of class nb_data
% 
% Output:
% 
% - obj       : An object of class nb_data, where the data are the 
%               result of the element-wise division.
% 
% Examples:
%
% obj = obj./DB;
% 
% See also:
% nb_data.mldivide, nb_data.mrdivide, nb_data.callop, nb_data.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_data') || ~isa(DB,'nb_data')
        error([mfilename,':: You can only divide element-wise an object of class nb_data with another object of class nb_data'])
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
            nb_data.errorConformity(4);
        end

        dataPages     = obj.numberOfDatasets;
        temp1         = obj;
        temp1         = temp1.addDataset(DB.data,'',DB.startObs,DB.variables);
        obj.data      = temp1.data(:,:,1:dataPages)./temp1.data(:,:,dataPages + 1:dataPages + dataPages);
        obj.variables = temp1.variables;
        obj.startObs  = temp1.startObs;
        obj.endObs    = temp1.endObs;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@rdivide,{DB});
        
    end

end
