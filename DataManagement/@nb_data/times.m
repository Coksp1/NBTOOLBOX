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
%           both object will result in series with all values set to nan.
%           
%
% Input:
% 
% - a         : An object of class nb_data
% 
% - b         : An object of class nb_data
% 
% Output:
% 
% - obj       : An nb_data object the data results from element-wise 
%               multiplication of the data of the input objects.
% 
% Examples:
%
% obj = obj.*DB;
% 
% See also:
% nb_data.mtimes, nb_data.callop, nb_data.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_data') || ~isa(DB,'nb_data')
        error([mfilename,':: You can only multiply element-wise a object of class with another object of class nb_data'])
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
            nb_data.errorConformity(4);
        end

        dataPages     = obj.numberOfDatasets;
        temp1         = obj;
        temp1         = temp1.addDataset(DB.data,'',DB.startObs,DB.variables);
        obj.data      = temp1.data(:,:,1:dataPages).*temp1.data(:,:,dataPages + 1:dataPages + dataPages);
        obj.variables = temp1.variables;
        obj.startObs  = temp1.startObs;
        obj.endObs    = temp1.endObs;
    end
    
    if obj.isUpdateable() 
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@times,{DB});
        
    end

end
