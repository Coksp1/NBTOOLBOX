classdef (Abstract) nb_store2Database < handle
% Description:
%
% A superclass for the classes that can be used to save results from the
% nb_calculate_vintages to a database.
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   This class is abstract, and no constructor exist.
% 
% See also: 
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
       
        % Set the names of the calculated variables when stored to the
        % database.
        aliases   = {};    
        
        % The variables saved to the wanted database.
        variables = {};
        
    end

    properties (Access=protected)
       
        % Indicator if this is the first time the data is put into a
        % database, or not.
        first   = true;
        
    end
    
    methods
        
        function set.variables(obj,variables)      
            if ~iscellstr(variables)
                error('The variables property must be set to a cellstr')
            end
            obj.variables = variables;
        end
        
        function set.aliases(obj,aliases)      
            if ~iscellstr(aliases)
                error('The aliases property must be set to a cellstr')
            end
            obj.aliases = aliases;
        end
        
        function first = getFirst(obj)
            first = obj.first;
        end
        
        function s = saveobj(obj)
        % Syntax:
        %
        % s = saveobj(obj)
        %
        % Description:
        %
        % Save object to .mat. Called by the save method.
        % 
        % Written by Kenneth S. Paulsen   
        
             s = struct(obj);
             
        end
        
        function updateStatus(~,valid)
        % Syntax:
        %
        % updateStatus(obj,valid)
        %
        % Description:
        %
        % Update the status
        %
        % Input:
        %
        % - valid : A scalar logical.
        % 
        % Written by Kenneth S. Paulsen   
            
            if ~nb_isScalarLogical(valid)
                error('The valid input must be a scalar logical (true/false)')
            end
            
        end
        
        function updateSettings(~,model)
        % Syntax:
        %
        % updateSettings(obj,model)
        %
        % Description:
        %
        % Update the settings
        % 
        % Input:
        %
        % - model : An object of class nb_calculate_vintages.
        %
        % Written by Kenneth S. Paulsen   
            
            if ~isa(model,'nb_calculate_vintages')
                error('The model input must be an object of class nb_calculate_vintages.')
            end
            
        end
        
    end

    methods (Abstract)
        
        % Syntax:
        %
        % model = initialize(obj,model)
        %
        % Description:
        %
        % Initialize model and database for writing.
        % 
        % Input:
        % 
        % - obj : An object of class nb_writeFcst2Database.
        %
        % - model : An object of class nb_calculate_vintages.
        %
        % Output:
        %
        % - model : An object of class nb_calculate_vintages.
        %
        % Written by Kenneth Sæterhagen Paulsen
        model = initialize(obj,model)
        
        % Syntax:
        %
        % s = struct(obj)
        %
        % Description:
        %
        % Convert object to a struct.
        %
        % Written by Kenneth Sæterhagen Paulsen
        s = struct(obj)
        
        % Syntax:
        %
        % put(obj,data)
        %
        % Description:
        %
        % Put time-series into database.
        % 
        % Input:
        % 
        % - obj  : An object of class nb_store2Database.
        % 
        % - data : The time-series to save to the database, as a nb_ts
        %          object. The dataNames property must contain elements 
        %          on the format 'yyyymmdd'. I.e. the context dates.
        %
        % Written by Kenneth Sæterhagen Paulsen
        put(obj,data)
        
        % Syntax:
        %
        % runDates = getRunDatesAsString(obj)
        %
        % Description:
        %
        % Get run dates of the forecast written to the database. 
        %
        % Written by Kenneth Sæterhagen Paulsen
        runDates = getRunDatesAsString(obj)
        
    end
    
    methods (Access=protected)
        
        function data = checkInputs(obj,data)
            
            test = ismember(obj.variables,data.variables);
            if any(~test)
                error([mfilename ':: The following variables are not in the provided dataset; ' toString(obj.variables(~test))])
            end
            test2 = ismember(data.variables,obj.variables);
            if any(~test2)
               data = deleteVariables(data,data.variables(~test2)); 
            end
            nb_store2Database.checkDataNames(data.dataNames);
            
        end
        
        function doAtFirstTime(obj,data)
            
            if isempty(obj.variables)
                obj.variables = data.variables;
            end
            nb_store2Database.checkDataNames(data.dataNames);
            
        end
        
        function names = getNames(obj)
        
            if isempty(obj.aliases)
                names = obj.variables;
            else
                names = obj.aliases;
            end
            
        end
            
    end
    
    methods (Static=true)
        
        vararout = getSubClasses(varargin);
        
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_store2Database.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            obj = nb_store2Database.unstruct(s);
            
        end
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_store2Database.unstruct(s)
        %
        % Description:
        %
        % Convert object from struct.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if isa(s,'nb_store2Database')
                % Add support for old cases.
                obj = s;
                return
            end
            if ~isstruct(s)
                error([mfilename ':: Load failed. Input must be a struct.'])
            end
            if isfield(s,'class')
                unstructFunc = str2func([s.class '.unstruct']);
            else
                error([mfilename ':: Load failed. No field class found.'])
            end
            obj = unstructFunc(s);
            
        end
        
    end
    
    methods (Access=protected,Static=true)
        
        function checkDataNames(dataNames)
           
            contexts = char(dataNames');
            if size(contexts,2) ~= 8
                error([mfilename ':: The dataNames of the data put to the database must be on the format ''yyyymmdd''.'])
            end
            contextsD = str2num(contexts); %#ok<ST2NM>
            if isempty(contextsD)
                error([mfilename ':: The dataNames of the data put to the database must be on the format ''yyyymmdd''.'])
            end
            
        end
        
    end
    
end

