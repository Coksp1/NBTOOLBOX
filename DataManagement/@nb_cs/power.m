function obj = power(obj,DBOrNum)
% Syntax:
%
% obj = power(a,b)
%
% Description:
%
% Element-wise power (.^). 
%
% If both inputs are nb_cs objects this method will raise the data
% of the first object with the data from the second object. This 
% will only be done for the variables which are found to be in both 
% nb_cs objects. The rest of the variables will get nan values.
% 
% Input:
% 
% - obj       : An object of class nb_cs or a scalar
% 
% - DBOrNum   : An object of class nb_cs or a scalar
% 
% Output:
% 
% - obj       : An nb_cs object where the data from th one object 
%               are raised with the data from the other object
%
%               or
%
%               An nb_cs object where all the elements are 
%               raised by the scalar DBOrNum. 
%
%               or
%
%               An nb_cs object where the scalar obj are raised by
%               all the elements of the object DBOrNum.                
% 
% Examples:
%
% obj = a.^b;
% obj = a.^2;
% obj = 2.^a;
%
% See also:
% nb_cs.mpower, nb_cs.callop, nb_cs.callfun
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(DBOrNum,'nb_cs') && ~(isnumeric(DBOrNum) && size(DBOrNum,1) == 1 && size(DBOrNum,2) == 1)
        error([mfilename,':: It is not possible to raise an object of class ' class(DBOrNum) ' with an object of class ' class(obj)])
    end

    if isa(obj,'nb_cs') 

        if isnumeric(DBOrNum)

            obj.data  = obj.data.^DBOrNum;

        else
            [isOK,~] = checkConformity(obj,DBOrNum);

            if isOK
                obj.data = obj.data.^DBOrNum.data;
            else
                % Force the datasets to have the same variables and types.
                % The result will be NAN values for all the missing
                % observations in the two datasets. Must have the same
                % number of datasets (pages)

                if obj.numberOfDatasets ~= DBOrNum.numberOfDatasets
                    nb_cs.errorConformity(4);
                end

                dataPages     = obj.numberOfDatasets;
                temp1         = obj;
                temp1         = temp1.addDataset(DBOrNum.data,'',DBOrNum.types,DBOrNum.variables);
                obj.data      = temp1.data(:,:,1:dataPages).^temp1.data(:,:,dataPages + 1:dataPages + dataPages);
                obj.variables = temp1.variables;
                obj.types     = temp1.types;
                
            end
        end

    elseif isscalar(obj)

        % Makes also expressions like c.^obj work.
        numMatrix    = repmat(obj,[DBOrNum.numberOfTypes,DBOrNum.numberOfVariables,DBOrNum.numberOfDatasets]);
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
