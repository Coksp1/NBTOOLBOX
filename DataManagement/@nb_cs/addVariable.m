function obj = addVariable(obj,Types,Data,variable)
% Syntax:
%
% obj = addVariable(obj,Types,Data,variable)
%
% Description:
%
% Add a new variable to the datasets (including all pages)
% 
% Input:
% 
% - obj      : An object of class nb_cs
% 
% - Types    : The types of the data of the added variable. 
%              Must be a cellstr.
% 
% - Data     : The data of the added variable. Must match the 
%              number of types given.
% 
% - Variable : A string with the added variable name. Cannot
%              be the same as a existing variable. (Use 
%              setValue instead)
%                     
% Output:
% 
% - obj : An nb_cs object with the added variable
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = obj.addVariable({'First'},2,'Var3')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: All inputs must be given to this function, i.e. addVariable(obj,types,Data,Variable)'])
    end

    if sum(strcmp(variable,obj.variables))
       error([mfilename ' :: The variable ''' variable ''' already exists. Use setValue.']) 
    end

    if size(Data,2) > 1 && size(Data,1) == 1
        Data = Data';
    end

    if isempty(obj)

        % Makes it possible to add a variable to a empty nb_cs 
        % object 
        obj = nb_cs(Data,'Database1',Types,{variable});

    else

        if ischar(Types)
            Types = cellstr(Types);
        end

        % Assign the added variable
        try
            locations = nb_cs.locateStrings(Types,obj.types);
        catch Err

            if strcmp(Err.identifier,'nb_cs:locateStrings:NotFound')
                message = strrep(Err.message,'string','type');
                error(message);
            else
                rethrow(Err);
            end

        end

        newData = nan(obj.numberOfTypes,1,obj.numberOfDatasets);
        try
            newData(locations,:,:) = Data;
        catch Err

            if strcmp(Err.identifier,'MATLAB:index_assign_element_count_mismatch') || strcmp(Err.identifier,'MATLAB:subsassigndimmismatch')
                sizeTypes = size(locations,1);
                dim1      = size(Data,1);
                dim2      = size(Data,2);
                dim3      = size(Data,3);
                if sizeTypes ~= dim1
                    error([mfilename ':: number of the data values given (' int2str(dim1) ') doesn''t match the number of types given (' int2str(sizeTypes) ').']) 
                elseif dim2 ~= 1
                    error([mfilename ':: You are only giving data to one variable. The data values has a second dimension with size lager then one (' int2str(dim2) ')'])
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
        if obj.sorted
            obj.variables = sort([obj.variables, variable]);
            varInd        = find(strcmp(variable,obj.variables));
            obj.data      = [obj.data(:,1:varInd-1,:), newData, obj.data(:,varInd:end,:)];
        else
            obj.variables = [obj.variables, variable];
            obj.data      = [obj.data,newData];
        end

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addVariable,{Types,Data,variable});
        
    end

end
