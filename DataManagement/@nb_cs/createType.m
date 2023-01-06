function obj = createType(obj,nameOfNewType,expression)
% Syntax:
%
% obj = createType(obj,nameOfNewType,expression)
%
% Description:
%
% Create type(s) and add them to the nb_cs object dataset(s)
% 
% Caution : 
% 
% - This function does not allow the type names to include 
%   mathematical operators (defined in matlab) as for example - + 
%   / . ( ) !
% 
% - This function only support methods of the class double for
%   the expressions. I.e. all the types of the nb_ts object are 
%   dumped as doubles, which you can use to create a new type
%
% Input:
% 
% - obj           : An object of class nb_cs
% 
% - nameOfNewType : The created types names as a cell array 
%                   or a string.
% 
%                   Must have the same size as the 'expressions'
%                   input.
% 
% - expression    : The expressions of how to create the data 
%                   of all the created variables.  
%
%                   As a cell array or a string.
% 
%                   Must have the same size as the 'nameOfNewType' 
%                   input.
% 
% Output:
% 
% - obj : An nb_cs object with the created types(s) added.
%
% Examples: 
% 
% obj = obj.createType('type1','type1./type2');
% 
% obj = obj.createType({'var3','var4',...},...
%       {'type1./type2','type2./type1',...});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ischar(expression)
        expression = cellstr(expression);
    end

    if ischar(nameOfNewType)
        nameOfNewType = cellstr(nameOfNewType);
    end

    if length(nameOfNewType) ~= length(expression)
        error([mfilename ':: You must provide as many new types names as the number of expressions you give'])
    end

    % Cannot add the addVariable command to the link
    updateState    = obj.updateable;
    obj.updateable = 0; 
    
    % Evaluate expressions
    for ii = 1:length(expression)

        newData = nb_eval(expression{ii},obj.types,obj.data');
        newData = newData';
        if size(newData,1) > 1
            error([mfilename ':: The evaluation of the given expression resulted in non row vector. Rember you are working with vectors.'])
        elseif size(newData,2) ~= obj.numberOfVariables
            error([mfilename ':: The evaluation of the given expression resulted in row vector with wrong number of elements. '...
                'Is ' int2str(size(newData,2)) ' should be '  int2str(obj.numberOfVariables) '.'])
        end

        % Add the newly created type
        try
            obj = obj.addType(nameOfNewType{ii}, double(newData), obj.variables);
        catch Err

            if ~ischar(nameOfNewType{ii})
                error([mfilename ':: The input ''nameOfNewType'' must be a string or a cellstr.'])
            elseif strcmp(Err.message,['nb_cs :: The variable ''' nameOfNewType{ii} ''' already exists. Use setValue.'])
                error([mfilename ':: The variable ''' nameOfNewType{ii} ''' already exists.'])
            else
                rethrow(Err)
            end

        end

    end
    obj.updateable = updateState;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@createType,{nameOfNewType,expression});
        
    end

end
