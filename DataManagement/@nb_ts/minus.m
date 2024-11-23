function obj = minus(obj,DBOrNum)
% Syntax:
%
% obj = minus(obj,DBOrNum)
%
% Description:
%
% Binary subtraction (-). 
%
% Caution: Will substract the data of the corresponding variables 
% from the two objects. All the variables not in common will result 
% in series with nan values.
%
% When one of the inputs are a scalar this function will substract
% each element of the data by this number or each element of the 
% data will be substracted from the scalar.
% 
% Input:
% 
% - a         : An object of class nb_ts or a scalar
% 
% - b         : An object of class nb_ts or a scalar
% 
% Output:
% 
% - obj       : An nb_ts object where all the variables are from 
%               the first object are substracted from the other.
%
%               Or
%
%               An nb_ts object where the scalar are substracted
%               from all the elements of the input object
%
%               Or 
%
%               An nb_ts object where all the elements of the input 
%               object are substracted from scalar.
% 
% Examples:
%
% obj = obj - anotherObj;
% obj = obj - 2;
% obj = 2 - obj;
% 
% See also:
% nb_ts.plus, nb_ts.callop, nb_ts.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(DBOrNum,'nb_ts') && ~isscalar(DBOrNum)
        error([mfilename,':: It is not possible to substract an object of class ' class(DBOrNum) ' from an object of class ' class(obj)])
    end

    if isa(obj,'nb_ts') 

        if ~isempty(obj) % If it is empty, then return a empty object

            if isscalar(DBOrNum)

                % Makes also expressions like obj-2 work.
                numMatrix = repmat(DBOrNum,[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]);
                obj.data  = obj.data - numMatrix;

            else
                [isOK,~] = checkConformity(obj,DBOrNum);

                if isOK
                    obj.data = obj.data - DBOrNum.data;
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
                    obj.data      = temp1.data(:,:,1:dataPages) - temp1.data(:,:,dataPages + 1:dataPages + dataPages);
                    obj.variables = temp1.variables;
                    obj.startDate = temp1.startDate;
                    obj.endDate   = temp1.endDate;

                end
                
            end
            
        end

    elseif isscalar(obj)

        % Makes also expressions like 2-obj work.
        numMatrix    = repmat(obj,[DBOrNum.numberOfObservations,DBOrNum.numberOfVariables,DBOrNum.numberOfDatasets]);
        DBOrNum.data = numMatrix - DBOrNum.data;
        obj          = DBOrNum;
        
    else
        
        error([mfilename,':: It is not possible to substract an object of class ' class(DBOrNum) ' from an object of class ' class(obj)])

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@minus,{DBOrNum});
        
    end

end
