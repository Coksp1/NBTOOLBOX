function obj = setValue(obj,VarName,Value,Types,pages)
% Syntax:
%
% obj = setValue(obj,VarName,Value,Types,pages)
%
% Description:
%
% Set some values of the dataset(s). (Only one variable.)
% 
% Input:
% 
% - obj     : An object of class nb_cs
% 
% - VarName : The variable name of the variable you want to set 
%             some values of. As a string
% 
% - Value   : The values you want to assign to a variable. Must be 
%             a numerical vector (with the same number of pages as 
%             given by pages or as the number of dataset the object 
%             consists of.) Must have the same length as the input
%             given by Types. (If this is not provided this input
%             must of same length as the number of existing types 
%             of the object)
% 
% - Types   : A cellstr of the type names to set.
% 
% - pages   : At which pages you want to set the values of a
%             variable. Must be a numerical index of the pages you 
%             want to set.
%             E.g. if you want to set the values of the 3 first 
%             datasets (pages of the data) of the object. And the 
%             number of datasets of the object is larger then 3. 
%             You can use; 1:3. If empty all pages must be set.
% 
% Output:
% 
% - obj : An nb_cs object with the added variable
% 
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = obj.setValue('Var2',3);
% obj = obj.setValue('Var2',4,{'First'},1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<5
        pages = 1:obj.numberOfDatasets;
        if nargin<4
            Types = {};
            if nargin<3
                error([mfilename,':: All but the two last inputs must be provided. I.e. setValue(obj,VarName,Value)'])
            end
        end
    end

    if isempty(obj.variables)
        error([mfilename,':: cannot set a value for a dataset which has no variables'])
    end

    if ~isempty(pages)
        m = max(pages);
        if m > obj.numberOfDatasets
            error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to set '
                             'values for the dataset ' int2str(m) ', which is not possible.'])
        end 
    else
        error([mfilename ':: You cannot set the values of no pages at all!'])
    end

    % Get the index of the types to set
    Types = cellstr(Types);
    if size(Types,1) == 1
        Types = Types';
    end

    if ~isempty(Types)

        Types = cellstr(Types);

        typesInd = zeros(1,max(size(obj.types)));
        for ii = 1:max(size(Types))
            var_id = strcmp(Types{ii},obj.types);
            typesInd = typesInd + var_id;
            if sum(var_id)==0
                warning('nb_cs:window:TypeNotFound',[mfilename ':: Type ''' Types{ii} ''' not found.']) 
            end
        end

        typesInd = logical(typesInd);

    else

        typesInd = 1:size(obj.types,2); % To ensure that we set all the types

    end

    if size(Value,2)>1
        error([mfilename,':: data must be a vertical vector of numbers (double)'])
    end

    Var_id = find(strcmp(VarName,obj.variables),1);
    if isempty(Var_id)
        error([mfilename,':: variable ',VarName,' do not exist in the dataset'])
    end

    try
        obj.data(typesInd,Var_id,pages) = Value;
    catch Err
        if size(Types,1) ~= size(Value,1)
            error([mfilename,':: Number of types (' int2str(size(Types,1)) ') should be equal to the number of values (' int2str(size(Value,1)) ')'])
        elseif obj.numberOfDatasets ~= size(Value,3)
            error([mfilename ':: the third dimension of the data values given (' int2str(size(Value,3)) ') doesn''t match the number of pages (datasets) of the object (' int2str(obj.numberOfDatasets) ').'])
        else
            rethrow(Err)
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@setValue,{VarName,Value,Types,pages});
        
    end

end
