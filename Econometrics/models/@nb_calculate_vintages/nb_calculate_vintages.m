classdef nb_calculate_vintages < nb_model_update_vintages & nb_modelData
% Description:
%
% A class for doing calculation of a generic problem on real-time data 
% that does not necessary is recursively balanced, i.e. that each page does
% not give rise to a new observation for all variables.
%
% Superclasses:
%
% nb_model_update_vintages, nb_modelData
%
% Constructor:
%
%   obj = nb_calculate_vintages(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_calculate_vintages.set)
% 
%   Output:
% 
%   - obj : An nb_calculate_vintages object.
% 
% See also:
% nb_calculate_vintages.set, nb_calculate_generic 
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
   
    properties (SetAccess=protected)
       
        % Stores the contexts that need to be used for estimation, as a
        % cellstr.
        contexts2Run
         
    end
    
    properties (Dependent=true,SetAccess=protected)
       
        % An object of class nb_calculate_generic.
        model
        
    end
    
    properties (SetAccess=protected)
       
        % A struct storing all the results of the calculations.
        %
        % See the help on the results property of the nb_calculate_generic
        % class.
        results   
        
    end
    
    properties (Hidden=true)
       
        giveErrorEstimation = false;
        
    end

    methods
        
        function obj = nb_calculate_vintages(varargin)
        % Constructor

            % Create identifier for this object
            obj.identifier         = nb_model_name.findIdentifier();
            obj.addAutoName        = true;
            obj.addAutoNameIfLocal = true;
            obj.addID              = true;
            obj.addIDIfLocal       = true;
        
            temp        = nb_calculate_vintages.template();
            obj.options = temp;
            if nargin == 0
                return
            end
            if nargin == 1 && isstruct(varargin{1})
                if isfield(varargin{1},'model')
                    if numel(varargin{1}.model) > 1
                        
                        % Get the names of each model
                        s = size(varargin{1}.model);
                        if isstruct(varargin{1})
                            if isfield(varargin{1},'name')
                                if iscellstr(varargin{1}.name)
                                    names = varargin{1}.name;
                                else
                                    if isempty(varargin{1}.name)
                                        names = repmat({''},1,prod(s));
                                    else
                                        names = nb_appendIndexes(varargin{1}.name,1:prod(s));
                                    end
                                end
                            end
                        end
                        
                        % Create nb_calculate_vintages array 
                        models   = varargin{1}.model(:);
                        n        = prod(s);
                        obj(n,1) = nb_calculate_vintages();
                        for ii = 1:prod(s)
                            varargin{1}.model = models(ii);
                            varargin{1}.name  = names{ii};
                            obj(ii)           = set(obj(ii),varargin{1});
                            obj(ii).level     = 0;
                        end
                        obj = reshape(obj,s);
                        return
                    end
                end
            end               
            obj       = set(obj,varargin{:});
            obj.level = 0;
            
        end
        
        function model = get.model(obj)
           model = obj.options.model; 
        end
        
        function obj = set.model(obj,model)
            if isa(model,'nb_calculate_generic')
                obj.options.model = model;
            else
                error([mfilename ':: The element assign to the model property must be a nb_calculate_generic object.'])
            end
        end
        
        function s = saveobj(obj)
            s = struct(obj);
        end
        
        varargout = store2Database(varargin)
        
    end
    
    methods (Hidden=true)
        
        function obj = updateLevel(obj)
            
           obj.level = getLevel(obj.options.dataSource.source) + 1; 
            
        end
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            if numel(obj.model) == 0
                name = '';
            else
                obj.model = setAddIDIfLocal(obj.model,obj.addIDIfLocal);
                obj.model = set(obj.model,'name',obj.nameLocal);
                name      = createName(obj.model);
            end
            
        end
        
        function obj = setProperty(obj,property,value)
            obj.(property) = value;
        end
        
        function obj = resetContexts(obj)
            if ~nb_isempty(obj.results) 
                obj.contexts2Run = obj.results.data.dataNames;
            end
        end
        
        function obj = setResults(obj,results)
            obj.results = results;
        end
        
    end
    
    methods(Access=protected)
         
        varargout = getCalcFromResults(varargin)
        
    end
    
    methods(Static=true)
        
        varargout = help(varargin)
        varargout = template(varargin)
        varargout = unstruct(varargin)
        
        function models = initialize(dim1,dim2)
            models(dim1,dim2) = nb_calculate_vintages();
        end
        
        function obj = loadobj(s)
            obj = nb_calculate_vintages.unstruct(s);
        end
        
        
        
    end
    
    methods(Static=true,Access=protected)
        
    end
         
end

