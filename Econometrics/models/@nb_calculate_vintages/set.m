function obj = set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties of the nb_calculate_vintages objects. 
%
% Caution : It will set the fields of the options property of the object.
% 
% Input:
% 
% - obj : A vector of nb_calculate_vintages objects.
%
% Optional input:
%
% If number of inputs equals 1:
% 
% - varargin{1} : A structure of fields to be set. See the 
%                 nb_calculate_vintages.template method for more.
%
% Else:
%
% - varargin    : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set all fields of some properties
%                 of the object. (options)
%
% Output:
%
% - obj : A vector of nb_calculate_vintages objects.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        return
    end

    if nargin == 2
        if isstruct(varargin{1})
            varargin = nb_struct2cellarray(varargin{1});
        else
           error([mfilename ':: Inputs must come in pairs.']) 
        end
    end

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot set properties of a empty vector of nb_calculate_vintages objects.')
    else
       
        names = getModelNames(obj);
        for ii = 1:nobj
            
            numberOfInputs = size(varargin,2);
            if rem(numberOfInputs,2) ~= 0
                error('The optional input must come in pairs.')
            end
            
            fields = [fieldnames(obj(ii).options); 'shift'];
            for jj = 1:2:numberOfInputs
                
                inputName  = varargin{jj};
                inputValue = varargin{jj + 1};
                
                switch lower(inputName)
                     
                    case 'datasource'
                    
                        if ~isempty(obj(ii).options.dataSource)
                            error([mfilename ':: Cannot reset the dataSource option.'])
                        end
                        if ~isa(inputValue,'nb_modelDataSource')
                            error([mfilename ':: The dataSource property must be assign a nb_modelDataSource object.'])
                        end
                        obj.options.dataSource = inputValue;
                        data                   = getData(obj.options.dataSource);
                        obj.contexts2Run       = data.dataNames;
                         
                    case 'folder'
                             
                        if ischar(inputValue) 
                            if numel(obj) > 1 
                                inputValue = cellstr(inputValue);
                                inputValue = inputValue(1,ones(1,nobj));
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).folder = inputValue{ii};
                        catch %#ok<CTCH>
                            error([mfilename ':: The value given to the property ''folder'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_vintages objects.'])
                        end       
                        
                    case 'model'
                    
                        if ~isempty(obj(ii).options.model)
                            warning('nb_calculate_vintages:set:reset',[mfilename ':: When setting the model options all results are reset, i.e. removed.'])
                            obj(ii)    = reset(obj(ii));
                            inputValue = setResults(inputValue,struct());
                        end
                        if ~isa(inputValue,'nb_calculate_generic')
                            error([mfilename ':: The model property must be assign a nb_calculate_generic object.'])
                        end
                        obj(ii).options.model = inputValue;
                        obj(ii).options.model = set(obj(ii).options.model,'name',obj(ii).name,'userData',obj(ii).userData);
                        
                    case 'name'
                             
                        if ischar(inputValue) 
                            if numel(obj) > 1 
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).name = inputValue{ii};
                        catch %#ok<CTCH>
                            error([mfilename ':: The value given to the property ''name'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_vintages objects.'])
                        end
                        if isa(obj(ii).options.model,'nb_calculate_generic')
                            obj(ii).options.model = set(obj(ii).options.model,'name',inputValue{ii});
                        end
                        
                    case 'path'
                             
                        if ischar(inputValue) 
                            if numel(obj) > 1 
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).path = inputValue{ii};
                        catch %#ok<CTCH>
                            error([mfilename ':: The value given to the property ''path'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_vintages objects.'])
                        end   
                        
                    case 'userdata'
                        
                        if ischar(inputValue) 
                            if numel(obj) > 1 
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).userData = inputValue{ii};
                        catch %#ok<CTCH>
                            error([mfilename ':: The value given to the property ''userData'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_vintages objects.'])
                        end
                        if isa(obj(ii).options.model,'nb_calculate_generic')
                            obj(ii).options.model = set(obj(ii).options.model,'userData',inputValue{ii});
                        end
                        
                    case 'reporting'
                        
                        if iscell(inputValue) && size(inputValue,2) == 3
                            obj(ii).reporting = inputValue;
                        elseif isempty(inputValue)
                            obj(ii).reporting = {};
                        else
                            error([mfilename ':: The property reporting must be assign a Nx3 cell matrix.'])
                        end
                          
                    case 'transformations'
                        
                        if iscell(inputValue) && size(inputValue,2) == 4
                            obj(ii).transformations = inputValue;
                        elseif isempty(inputValue)
                            obj(ii).transformations = {};    
                        else
                            error([mfilename ':: The property transformations must be assign a Nx4 cell matrix.'])
                        end
                        
                    otherwise
                        
                        ind = find(strcmpi(inputName,fields),1);
                        if isempty(ind)
                            if isempty(obj(ii).model)
                                error([mfilename ':: ' names{ii} ' has not been assign any nb_model_generic object'])
                            end
                            % Set properties of the underlying model
                            obj(ii).model = set(obj(ii).model,inputName,inputValue);
                        else
                            obj(ii).options.(fields{ind}) = inputValue;
                        end
                         
                end
                
            end
            
        end
        
    end

end
