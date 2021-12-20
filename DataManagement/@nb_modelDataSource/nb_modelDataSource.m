classdef nb_modelDataSource
% Description:
%
% A data source that can be given to the nb_model_vintages class.
%
% Constructor:
%
%   obj = nb_modelDataSource(source,variables)
%   obj = nb_modelDataSource(source,calendar)
%   obj = nb_modelDataSource(source,variables,calendar)
% 
%   Input:
%
%   - source    : An object that subclass the nb_connector class.
% 
%   - variables : The set of variables you want to fetch from the source.
%
%   - calendar  : An object of a subclass of the nb_calendar class.
%
%   Output:
% 
%   - obj       : An object of class nb_modelDataSource.
% 
% See also: 
% nb_connector, nb_ts, nb_model_vintages
%
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The user data related to the object. Can be of any class.
        userData            = [];
        
    end

    properties (SetAccess=protected)
        
        % Restrict the fetched vintages to a specific calendar, i.e. only
        % select the latest contexts that is before the selected calendar.
        % This can be utilized so to reduce the number of contexts to
        % estimate the model over during testing of a model. Must be empty
        % or an object of a subclass of the nb_calendar class.
        calendar            = [];
        
        % A cell matrix with the release data.
        releaseData         = {};
        
        % An object that fetches the data. The object needs to be of a
        % subclass of the nb_connector class.
        source              = [];
        
        % A cellstr with the variables to fetch from the source/database.
        variables           = {};
        
        % A 1 x nVars cell array, each element storing the vintage tags of 
        % each variable.
        vintages            = {}; 
        
    end
    
    properties (Access=protected,Hidden=true)
       
        % An object of class nb_ts.
        data                = nb_ts;
        
        % Store data
        storeData           = true;
        
        
    end
    
    methods
       
        function obj = nb_modelDataSource(source,input1,input2)
           
            if nargin == 0
                return
            end
            if nargin < 3
                input2 = [];
                if nargin < 2
                    input1 = {};
                end
            end
            if ~isa(source,'nb_connector')
                error([mfilename ':: The source input must be an object that subclass the nb_connector class.'])
            end
            obj.source    = source;
            if isa(input1,'nb_calendar')
                obj.calendar  = input1;
                obj.variables = {};
            else
                obj.variables = input1;
                obj.calendar  = input2;
            end
            
        end
        
        function dispData(obj)
        % Syntax:
        %
        % dispData(obj)
        %
        % Description:
        %
        % Display objects data (In the command window)
        % 
        % Input:
        %
        % - obj : An object of class nb_modelDataSource.
        %
        % Output:
        %
        % The dataset displayed in the command window.
        %
        % Written by Kenneth S. Paulsen
            disp(obj.data);
        end
        
        function ret = isempty(obj)
        % Syntax:
        %
        % ret = isempty(obj)
        %
        % Description:
        %
        % Test if a nb_modelDataSource object is empty. Return 1 if true, 
        % otherwise 0.
        % 
        % Input:
        % 
        % - obj : An object of class nb_modelDataSource.
        % 
        % Output:
        % 
        % - ret : True (1) if the series isempty, false (0) if not
        % 
        % Written by Kenneth S. Paulsen    
            
            ret = isempty(obj.data);
            
        end
        
        function s = struct(obj)
        % Syntax:
        %
        % s = struct(obj)
        %
        % Description:
        %
        % Convert object to struct.
        % 
        % Written by Kenneth S. Paulsen    
            
             s       = struct();
             s.class = 'nb_modelDataSource';
             if obj.storeData
                s.data     = struct(obj.data);
                s.vintages = obj.vintages;
             else
                s.vintages    = {};
             end
             s.storeData   = obj.storeData;
             s.source      = struct(obj.source);
             s.variables   = obj.variables;
             s.calendar    = struct(obj.calendar);
             s.releaseData = obj.releaseData;
             
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
           
        function obj = setReleaseData(obj,releaseDataNew)
        % Syntax:
        %
        % obj = setReleaseData(obj,releaseDataNew)
        %
        % Description:
        %
        % Assign release data to object. If set, this info is used when
        % nb_model_forecast_vintages.getRelease is called.
        %
        % Written by Kenneth Sæterhagen Paulsen     
        
            if ~iscell(releaseDataNew)
                error('The releaseData must be a cell.')
            end
            if size(releaseDataNew,1) ~= 3
                error('The releaseData must have 3 rows.')
            end
            if isempty(obj.releaseData)
                obj.releaseData = releaseDataNew;
            else
                for ii = 1:size(obj.releaseData,2)
                    
                   dates     = [obj.releaseData{2,ii}{1};releaseDataNew{2,ii}{1}]; %#ok<*AGROW>
                   relData   = [obj.releaseData{2,ii}{2};releaseDataNew{2,ii}{2}];
                   [dates,i] = unique(dates);
                   relData   = relData(i);
                   
                   obj.releaseData{2,ii}{1} = dates;
                   obj.releaseData{2,ii}{2} = relData;
                   
                end
            end
            
        end
        
        function obj = setCalendar(obj,calendar)
        % Syntax:
        %
        % obj = setCalendar(obj,calendar)
        %
        % Description:
        %
        % Assign a new calendar to the calendar property. This means
        % that you need to run update on the object again!
        %
        % Input:
        %
        % - calendar : An object of class nb_calendar or empty.
        %
        % Written by Kenneth Sæterhagen Paulsen     
           
            if not(isa(calendar,'nb_calendar') || isempty(calendar))
                error('The calendar property must be set to empty or an object of class nb_calendar')
            end
            obj.calendar = calendar;
            obj.data     = []; % Update is needed!
            
        end
        
        function release = getReleaseFromReleaseData(obj,var,releaseNr)
            
            indV = strcmp(var,obj.releaseData(1,:));
            if releaseNr ~= obj.releaseData{3,indV}
                error('The release you asked for is not been stored, and can therfore not be fetched.')
            end
            dates      = obj.releaseData{2,indV}{1};
            relData    = obj.releaseData{2,indV}{2};
            start      = nb_date.date2freq(dates{1});
            finish     = nb_date.date2freq(dates{end});
            allDates   = start:finish;
            i          = ismember(allDates,dates);
            allData    = nan(size(allDates,1),1);
            allData(i) = relData;
            release    = nb_ts(allData,['Release',int2str(releaseNr)],start,var);
            
        end
        
        function vars = getVariables(obj)
        % Syntax:
        %
        % vars = getVariables(obj)
        %
        % Description:
        %
        % Get the fetched variables.
        %
        % Written by Kenneth Sæterhagen Paulsen  
        
            if isempty(obj.variables)
                if isprop(obj.source,'variableNames')
                    vars = obj.source.variableNames';
                else
                    vars = get(obj.data,'variables');
                end
            else
                vars = obj.variables;
            end
            
        end
        
        function value = getStoreData(obj)
        % Syntax:
        %
        % vars = getStoreData(obj)
        %
        % Description:
        %
        % Get the storeData property.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            value = obj.storeData;
            
        end
        
        function value = getLevel(obj)
        % Syntax:
        %
        % vars = getLevel(obj)
        %
        % Description:
        %
        % Get level based on source.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            value = getLevel(obj.source);
            
        end
            
    end
    
    methods (Hidden=true)
       
        function obj = setData(obj,data)
            obj.data = data;
        end
            
    end
    
    methods (Static=true)
       
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_modelDataSource.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if ~isstruct(s)
                error([mfilename ':: Load failed. Input must be a struct.'])
            end
            obj = nb_modelDataSource.unstruct(s);
            
        end
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_modelDataSource.unstruct(s)
        %
        % Description:
        %
        % Convert object from struct.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if ~isstruct(s)
                error([mfilename ':: Load failed. Input must be a struct.'])
            end
            obj = nb_modelDataSource();
            if isfield(s,'storeData')
                obj.storeData = s.storeData;
            else
                obj.storeData = true; 
            end
            if obj.storeData
                obj.data     = nb_ts.unstruct(s.data);
                obj.vintages = s.vintages;
            end
            obj.source    = nb_connector.unstruct(s.source);
            obj.variables = s.variables;
            
            if isfield(s,'calendar')
                if ~isempty(s.calendar)
                    obj.calendar = nb_calendar.unstruct(s.calendar);
                end
            end
            if isfield(s,'releaseData')
                obj.releaseData = s.releaseData;
            end
            
        end
        
    end
    
end
