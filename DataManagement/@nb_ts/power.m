function obj = power(obj,DBOrNum)
% Syntax:
%
% obj = power(a,b)
%
% Description:
%
% Element-wise power (.^). 
%
% If both inputs are nb_ts objects this method will raise the data
% of the first object with the data from the second object. This 
% will only be done for the variables which are found to be in both 
% nb_ts objects. The rest of the variables will get nan values.
% 
% Input:
% 
% - obj       : An object of class nb_ts or a scalar
% 
% - DBOrNum   : An object of class nb_ts or a scalar
% 
% Output:
% 
% - obj       : An nb_ts object where the data from th one object 
%               are raised with the data from the other object
%
%               or
%
%               An nb_ts object where all the elements are 
%               raised by the scalar DBOrNum. 
%
%               or
%
%               An nb_ts object where the scalar obj are raised by
%               all the elements of the object DBOrNum.                
% 
% Examples:
%
% obj = a.^b;
% obj = a.^2;
% obj = 2.^a;
%
% See also:
% nb_ts.mpower, nb_ts.callop, nb_ts.callfun
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isa(DBOrNum,'nb_ts') && ~(isnumeric(DBOrNum) && size(DBOrNum,1) == 1 && size(DBOrNum,2) == 1)
        error([mfilename,':: It is not possible to raise an object of class ' class(DBOrNum) ' with an object of class ' class(obj)])
    end

    if isa(obj,'nb_ts') 

        if isnumeric(DBOrNum)

            obj.data  = obj.data.^DBOrNum;

        else
            [isOK,~] = checkConformity(obj,DBOrNum);

            if isOK
                obj.data = obj.data.^DBOrNum.data;
            else
                % Force the datasets to have the same variables and dates.
                % The result will be NAN values for all the missing
                % observations in the two datasets. Must have the same
                % number of datasets (pages)

                if obj.numberOfDatasets ~= DBOrNum.numberOfDatasets
                    nb_ts.errorConformity(4);
                end

                dataPages     = obj.numberOfDatasets;
                temp1         = obj;
                temp1         = temp1.addDataset(DBOrNum.data,'',DBOrNum.startDate,DBOrNum.variables);
                obj.data      = temp1.data(:,:,1:dataPages).^temp1.data(:,:,dataPages + 1:dataPages + dataPages);
                obj.variables = temp1.variables;
                obj.startDate = temp1.startDate;
                obj.endDate   = temp1.endDate;
                
            end
        end

    elseif isscalar(obj)

        % Makes also expressions like c.^obj work.
        numMatrix    = repmat(obj,[DBOrNum.numberOfObservations,DBOrNum.numberOfVariables,DBOrNum.numberOfDatasets]);
        DBOrNum.data = numMatrix.^DBOrNum.data;
        obj          = DBOrNum;
        
    else
        
        error([mfilename,':: It is not possible to raise an object of class ' class(DBOrNum) ' with an object of class ' class(obj)])

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@power,{DBOrNum});
        
    end

end
