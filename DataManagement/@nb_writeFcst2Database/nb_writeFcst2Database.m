classdef (Abstract) nb_writeFcst2Database < handle
% Description:
%
% A superclass for the classes that can be used to write forecast from the
% nb_model_forecast_vintages to a database.
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
% nb_model_forecast_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
       
        % The variables saved to the wanted database. If empty, all
        % variables are saved to the database.
        variables2Write = {};
        
    end

    properties (Access=protected)
       
        % Indicator if this is the first time the data is put into a
        % database, or not.
        first   = true;
        
    end

    methods (Abstract)
        
        % Syntax:
        %
        % model = initialize(obj,model,inputs)
        %
        % Description:
        %
        % Initialize model and database for writing.
        % 
        % Input:
        % 
        % - obj    : An object of class nb_writeFcst2Database.
        %
        % - model  : An object of class nb_model_forecast_vintages.
        %
        % - inputs : A struct with logging information.
        %
        % Output:
        %
        % - model : An object of class nb_model_forecast_vintages.
        %
        % Written by Kenneth Sæterhagen Paulsen
        model = initialize(obj,model,inputs)
        
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
        % write(obj,fcst,start)
        %
        % Description:
        %
        % Write forecast to database.
        % 
        % Input:
        % 
        % - obj   : An object of class nb_writeFcst2Database.
        % 
        % - fcst  : The forecast to save to the database, as a nb_data
        %           object with size nHor x nRuns, where nRuns is the 
        %           number contexts the model has ran over. The variables  
        %           property must contain elements on the format  
        %           'yyyymmdd', i.e. the run/context dates. If the 
        %           database has already written forecast at a set of 
        %           contexts found in data, these are not updated! The
        %           dataNames property must be a 1 x 1 cellstr with the
        %           variable name. I.e. the object can only have one page!
        %
        % - start : The start dates of the forecast provided by the data
        %           input. As a nb_date vector.
        %
        % Written by Kenneth Sæterhagen Paulsen
        write(obj,fcst,start)
         
        % Syntax:
        %
        % runDates = getRunDatesAsString(obj)
        % runDates = getRunDatesAsString(obj,format)
        %
        % Description:
        %
        % Get the run dates as cellstr of the model.
        % 
        % Input:
        % 
        % - obj      : An object of class nb_SMARTModel.
        % 
        % - format   : > 'vintage' : 'yyyymmdd'
        %              > 'default' : 'yyyy-mm-dd'
        %
        % Output:
        % 
        % - runDates : A cellstr array with the run dates.
        %
        % Written by Kenneth Sæterhagen Paulsen
        runDates = getRunDatesAsString(obj)
        
    end
    
    methods 
        
        function first = getFirst(obj)
            first = obj.first;
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
        % - model : An object of class nb_model_forecast_vintages.
        %
        % Written by Kenneth S. Paulsen   
            
            if ~isa(model,'nb_model_forecast_vintages')
                error('The model input must be an object of class nb_model_forecast_vintages.')
            end
            
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
        
    end
    
    methods (Access=protected)
        
        function checkInputs(obj,fcst,start)
            
            if fcst.numberOfDatasets ~= 1
                error('The fcst input can only have one page.')
            end
            if ~isa(start,'nb_date')
                error('The start input must be of class nb_date')
            end
            if ~nb_sizeEqual(start,[1,fcst.numberOfVariables])
                error(['The start input does not match the fcst input. Must be a 1x'...
                    int2str(fcst.numberOfVariables) ', but is ' int2str(size(start,1)) 'x',...
                    int2str(size(start,2))])
            end
            if ~isempty(obj.variables2Write)
                test = ismember(fcst.dataNames,obj.variables2Write);
                if any(~test)
                    error([mfilename ':: The variable of the input fcst (' fcst.dataNames{1} ') are not ',...
                        'in the list of written variables; ' toString(obj.variables2Write)])
                end
            end
            nb_writeFcst2Database.checkDataNames(fcst.variables);
            
        end
           
    end
    
    methods (Static=true)
        
        vararout = getSubClasses(varargin);
        
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_writeFcst2Database.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            obj = nb_writeFcst2Database.unstruct(s);
            
        end
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_writeFcst2Database.unstruct(s)
        %
        % Description:
        %
        % Convert object from struct.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if isa(s,'nb_writeFcst2Database')
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
            if ~any(size(contexts,2) == [8,12,14])
                error([mfilename ':: The dataNames of the fcst written to the database must be on the format ''yyyymmdd'', ''yyyymmddhhnn'' or ''yyyymmddhhnnss''.'])
            end
            contextsD = str2num(contexts); %#ok<ST2NM>
            if isempty(contextsD)
                error([mfilename ':: The dataNames of the fcst written to the database must be on the format ''yyyymmdd'', ''yyyymmddhhnn'' or ''yyyymmddhhnnss''.'])
            end
            
        end
        
    end
    
end

