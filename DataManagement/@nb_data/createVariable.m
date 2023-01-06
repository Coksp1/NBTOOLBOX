function obj = createVariable(obj,nameOfNewVariable,expression,parameters,varargin)
% Syntax:
%
% obj = createVariable(obj,nameOfNewVariable,expression)
% obj = createVariable(obj,nameOfNewVariable,expression,parameters,varargin)
%
% Description:
%
% Create variable(s) and add them to the nb_data object dataset(s)
% 
% Caution : 
% 
% 
% - This function only support methods of the class nb_math_ts for
%   the expressions. 
%
% Input:
% 
% - obj               : An object of class nb_data
% 
% - nameOfNewVariable : The created variable names as a cell array 
%                       or a string.
% 
%                       Must have the same size as the 
%                       'expressions' input.
% 
% - expression        : The expressions of how to create the data 
%                       of all the created variables.  
%
%                       As a cell array or a string.
% 
%                       Must have the same size as the
%                       'nameOfNewVariables' input.
% 
% - parameters        : A struct with the parameters that can be used in
%                       the expressions. Caution: They will be added as
%                       series, so you need to use elementwise operators
%                       (.*,./,.^)!
%
% Optional input:
%
% - 'overwrite'       : true or false. Set to true to allow for overwriting
%                       of variables already in the data of the object.
%                       Default is false.
%
% - 'warning'         : true or false. Set to true to give warning if
%                       expressions fail (instead of error). Will
%                       result in series having all nan value, when warning
%                       is thrown.
%
% Output:
% 
% - obj : An nb_data object with the created variable(s) added.
%
% Examples: 
% 
% obj = obj.createVariable('var3','var1./var2');
% 
% obj = obj.createVariable({'var3','var4',...},...
%       {'var1./var2','var2./var1',...});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4   
        parameters = [];
    end
    
    % Parse the arguments 
    default = {'overwrite',     false,     @nb_isScalarLogical;
               'warning',       false,     @nb_isScalarLogical};
    if nargin > 4
        [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
        if ~isempty(message)
            error(message)
        end
    else
        inputNames   = default(:,1);
        inputValues  = default(:,2);
        inputs       = cell2struct(inputValues,inputNames);
    end

    if ischar(expression)
        expression = cellstr(expression);
    end

    if ischar(nameOfNewVariable)
        nameOfNewVariable = cellstr(nameOfNewVariable);
    end

    if length(nameOfNewVariable) ~= length(expression)
        error([mfilename ':: You must provide as many new variable names as the number of expressions you give'])
    end

    % Cannot add the addVariable command to the link
    updateState    = obj.updateable;
    obj.updateable = 0; 
    
    % Get the data that can be used
    vars = obj.variables;
    dat  = obj.data;
    if ~nb_isempty(parameters)
        [dat,vars] = nb_dataSource.mergeDataAndParameters(dat,vars,parameters); 
    end
    
    % Evaluate expressions
    for ii = 1:length(expression)

        if inputs.warning
            try
                newData = nb_eval(expression{ii},vars,dat);
            catch Err
                warning('nb_forecast:createReportedVariables:couldNotEvaluate','%s',Err.message);
                newData =  nan(obj.numberOfObservations,1,obj.numberOfDatasets);
            end
        else
            newData = nb_eval(expression{ii},vars,dat);
        end
        if size(newData,2) > 1
            error([mfilename ':: The evaluation of the given expression resulted in non column vector. Rember you are working with vectors.'])
        elseif size(newData,1) ~= obj.numberOfObservations
            error([mfilename ':: The evaluation of the given expression resulted in column vector with wrong number of elements. '...
                'Is ' int2str(size(newData,1)) ' should be '  int2str(obj.numberOfObservations) '.'])  
        end

        % Add the newly created variable
        if inputs.overwrite
            
            % To make it possible to use newly created variables in the 
            % expressions to come, we must append it in this way
            found = strcmp(nameOfNewVariable{ii},vars);
            if ~any(found)
                dat  = [dat,newData]; %#ok<AGROW>
                vars = [vars,nameOfNewVariable{ii}]; %#ok<AGROW>
            else
                dat(:,found,:) = newData;
            end
            
        else
            try
                obj = obj.addVariable(obj.startObs, double(newData), nameOfNewVariable{ii});       
            catch Err

                if strcmp(Err.message,'addVariable:: The input ''Variable'' must be a string.')
                    error([mfilename ':: The input ''nameOfNewVariable'' must be a string.'])
                elseif strcmp(Err.message,['addVariable :: The variable ''' nameOfNewVariable{ii} ''' already exists. Use setValue.'])
                    error([mfilename ':: The variable ''' nameOfNewVariable{ii} ''' already exists.'])
                else
                    rethrow(Err)
                end

            end
        end

    end
    obj.updateable = updateState;
    
    if inputs.overwrite
        obj.data      = dat;
        obj.variables = vars;
        if obj.sorted
            [obj.variables,ind] = sort(obj.variables);
            obj.data            = obj.data(:,ind,:);
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@createVariable,{nameOfNewVariable,expression});
        
    end

end
