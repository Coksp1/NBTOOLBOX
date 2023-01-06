function obj = addType(obj,type,addedData,vars)
% Syntax:
%
% obj = addType(obj,type,addedData,vars)
%
% Description:
%
% Add a new type to the datasets (including all pages)
% 
% Input:
% 
% - obj       : An object of class nb_cs
% 
% - type      : The type to add. As a string. Cannot be the same as
%               a existing type. Use setValue instead.
% 
% - addedData : The data of the added type. Must match the 
%               number of variables given. I.e. a double with size
%               1 x number of variables given in the cellstr 
%               variables.
% 
% - vars      : A cellstr of the variables of the added type.
%                     
% Output:
% 
% - obj : An nb_cs object with the added type
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = obj.addVariable('Second',[2,2],{'Var1','Var2'})
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: All inputs must be given to this function, i.e. addType(obj,type,addedData,vars)'])
    end

    if sum(strcmp(type,obj.types))
       error([mfilename ' :: The type ''' variable ''' already exists. Use setValue.']) 
    end

    if size(addedData,1) > 1 && size(addedData,2) == 1
        addedData = addedData';
    end

    if isempty(obj)

        % Makes it possible to add a variable to a empty nb_cs 
        % object 
        obj = nb_cs(addedData,'Database1',{type},vars);

    else

        if ischar(vars)
            vars = cellstr(vars);
        end

        % Assign the added type
        try
            locations = nb_cs.locateStrings(vars,obj.variables);
        catch Err

            if strcmp(Err.identifier,'nb_cs:locateStrings:NotFound')
                message = strrep(Err.message,'string','variable');
                error(message);
            else
                rethrow(Err);
            end

        end

        newData = nan(1,obj.numberOfVariables,obj.numberOfDatasets);
        try
            newData(:,locations,:) = addedData;
        catch Err

            if strcmp(Err.identifier,'MATLAB:index_assign_element_count_mismatch') || strcmp(Err.identifier,'MATLAB:subsassigndimmismatch')
                sizeVars = size(locations,1);
                dim1     = size(addedData,1);
                dim2     = size(addedData,2);
                dim3     = size(addedData,3);
                if sizeVars ~= dim2
                    error([mfilename ':: number of the data values given (' int2str(dim2) ') doesn''t match the number of variables given (' int2str(sizeVars) ').']) 
                elseif dim2 ~= 1
                    error([mfilename ':: You are only giving data to one variable. The data values has a first dimension with size lager then one (' int2str(dim1) ')'])
                elseif dim3 ~= obj.numberOfDatasets
                    error([mfilename ':: the third dimension of the data values given (' int2str(dim3) ') doesn''t match the number of pages (datasets) of the object (' int2str(obj.numberOfDatasets) ').'])
                else
                   rethrow(Err); 
                end
            else
                rethrow(Err);   
            end

        end

        % Assign properties
        obj.types         = [obj.types ,type];
        obj.data          = [obj.data; newData];

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addType,{type,addedData,vars});
        
    end

end
