function obj = plus(obj,DBOrNum)
% Syntax:
%
% obj = plus(obj,DBOrNum)
%
% Description:
%
% Binary addition (+). 
%
% Caution: Will add the data of the corresponding variables from 
% the two objects. All the variables not in common will result 
% in series with nan values.
%
% When one of the inputs are a scalar this function will add
% each element of the data by this number.
% 
% Input:
% 
% - a         : An object of class nb_ts or a scalar
% 
% - b         : An object of class nb_ts or a scalar
% 
% Output:
% 
% - obj       : An nb_ts object where all the variables from the
%               two objects are added.
%
%               Or
%
%               An nb_ts object where the scalar are added to all
%               elements of the given nb_ts object
% 
% Examples:
%
% obj = obj + anotherObj;
% obj = obj + 2;
% obj = 2 + obj;
% 
% See also:
% nb_ts.minus, nb_ts.callop, nb_ts.callfun
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(DBOrNum,'nb_ts') && ~(isnumeric(DBOrNum) && size(DBOrNum,1) == 1 && size(DBOrNum,2) == 1)
        error([mfilename,':: You can only add an object of class nb_ts with an object of class nb_ts.'])
    end

    if isa(obj,'nb_ts') 

        if ~isempty(obj) % If it is empty, then return a empty object

            if isnumeric(DBOrNum)

                numMatrix = repmat(DBOrNum,[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]);
                obj.data  = obj.data + numMatrix;

            else
                [isOK,~] = checkConformity(obj,DBOrNum);

                if isOK
                    obj.data = obj.data + DBOrNum.data;
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
                    obj.data      = temp1.data(:,:,1:dataPages) + temp1.data(:,:,dataPages + 1:dataPages + dataPages);
                    obj.variables = temp1.variables;
                    obj.startDate = temp1.startDate;
                    obj.endDate   = temp1.endDate;

                end
            end
        end
        
        if obj.isUpdateable()
        
            % Add operation to the link property, so when the object 
            % is updated the operation will be done on the updated 
            % object
            obj = obj.addOperation(@plus,{DBOrNum});

        end

    else

        % Makes also expressions like c+obj work.
        obj = plus(DBOrNum,obj); 

    end

end
