classdef (Abstract) nb_model_name
% Description:
%
% An abstract superclass for all model objects having a name.
%
% See also:
% nb_calculate_only, nb_model_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)

        % Name of model. If not assign a name a generic name will be
        % provided. See the implementation of nb_model_name.createName
        % for different subclasses.
        name
        
    end
    
    properties (Access = public)
        
        % Add automatic name (first) to default name in getName. Default is 
        % false.
        addAutoName         = false;
        
        % Add automatic name (first) to local name in getName. Default is 
        % false.
        addAutoNameIfLocal  = false;
        
        % Add identifier to local name in getName. Default is false.
        addIDIfLocal        = false;
        
        % Add identifier to default name in getName. Default is false.
        addID               = false;
        
    end
    
    properties (Access = protected)    
        
        % Stores the user set name of the object. If empty, the name will
        % be provided.
        nameLocal       = '';
        
        % A unit identifier associated with this object upon construction
        % of the object.
        identifier      = 0;
        
    end
        
    methods

        function obj = set.name(obj,inputValue)

            if isempty(inputValue)
                obj.nameLocal = '';
                return
            end
            if ischar(inputValue)
                obj.nameLocal = inputValue;
            elseif iscellstr(inputValue)
                obj.nameLocal = inputValue{1};
            else
                error([mfilename ':: The value given to the property ''name'' must be a string or a 1x1 cellstr '...
                    'when setting a single nb_model_name object.'])
            end

        end
        
        function name = get.name(obj)
            name = getName(obj);
        end
            
    end
    
    methods(Hidden)
        
        function name = getName(obj)
            if ~isempty(obj.nameLocal)
                name = obj.nameLocal;
                if obj.addIDIfLocal
                    name = appendIdentifier(obj,name);
                end
                if obj.addAutoNameIfLocal
                    name = [createName(obj),'_',name];
                end
            else
                if obj.addAutoName
                    name = createName(obj);
                else
                    name = '';
                end
                if obj.addID
                    name = appendIdentifier(obj,name);
                end
            end
        end
        function addAutoName = getAddAutoName(obj)
            addAutoName = obj.addAutoName;
        end
        function addAutoNameIfLocal = getAddAutoNameIfLocal(obj)
            addAutoNameIfLocal = obj.addAutoNameIfLocal;
        end
        function addID = getAddID(obj)
            addID = obj.addID;
        end
        function addIDIfLocal = getAddIDIfLocal(obj)
            addIDIfLocal = obj.addIDIfLocal;
        end
        function nameLocal = getNameLocal(obj)
            nameLocal = obj.nameLocal;
        end
        function identifier = getIdentifier(obj)
            identifier = obj.identifier;
        end
        function obj = setAddAutoName(obj,value)
            [obj(:).addAutoName] = deal(value);
        end
        function obj = setAddAutoNameIfLocal(obj,value)
            [obj(:).addAutoNameIfLocal] = deal(value);
        end
        function obj = setAddIDIfLocal(obj,value)
            [obj(:).addIDIfLocal] = deal(value);
        end
        function obj = setAddID(obj,value)
            [obj(:).addID] = deal(value);
        end
        
    end
        
    methods (Abstract=true,Hidden=true)

        name = createName(obj);

    end
    
    methods (Sealed = true)
       
        varargout = getModelNames(varargin);
        
    end
    
    methods (Access=protected)
        
        function name = appendIdentifier(obj,name)
            if isempty(name)
                name = obj.identifier;
            else
                name = [ name, '_', obj.identifier];
            end
        end
        
    end
    
    methods (Static=true, Access=protected)
       
        function ID = findIdentifier()
            ID = nb_clock('vintagemilliseconds');
        end
            
    end
   
end
