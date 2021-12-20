classdef (Abstract) nb_connector < handle
% Description:
%
% A abstract class of all the classes that can be assign to the source
% property of the nb_modelDataSource class.
%
% Constructor:
%
%   None as it is a abstract class.
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods (Abstract)
       
        % Syntax:
        %
        % data            = getTS(obj,date)
        % [data,vintages] = getTS(obj,date,variables,calendar)
        %
        % Description:
        %
        % Get the time-series of a set of variables at different contexts. 
        % Each context (vintage) will be added as a separate page.
        % 
        % Input:
        % 
        % - obj       : An object of class nb_connector.
        %
        % - date      : One of the following:
        %               > A one line char on the format 'yyyymmdd' or 
        %               'yyyymmddhhnnss'. If a date is provided only the   
        %               contexts after the provided date will be returned, 
        %               otherwise all contexts are returned.
        %               > A cellstr with the dates that has already been
        %               fetched. Each element on the same format as for the
        %               one line char case.
        %               
        % - variables : A cellstr with the variables to fetch.
        %
        % - calendar  : A nb_calendar object. Only the contexts matching
        %               the calendar is returned.
        % 
        % Output:
        % 
        % - data      : A nb_ts object. Each context/vintage of the
        %               variables are added as a separate page. 
        %
        %               The dataNames property of this nb_ts object must
        %               store the context date/vintage tag as a date on the
        %               format 'dd.mm.yyyy' or 'yyyymmdd'.
        %
        % - vintages  : A 1 nVars cell array, each element storing the
        %               vintage tags of each variable.               
        %
        % Written by Kenneth Sæterhagen Paulsen
        [data,vintages] = getTS(obj,date,variables,calendar)
        
        % Syntax:
        %
        % data = getFirstContext(obj)
        %
        % Description:
        %
        % Get the time-series of a set of variables at the first contexts.
        % 
        % Input:
        % 
        % - obj : An object of class nb_connector.
        % 
        % Output:
        % 
        % - data : A nb_ts object. 
        %
        %          The dataNames property of this nb_ts object must
        %          store the first context date as a date on the
        %          format 'dd.mm.yyyy' or 'yyyymmdd'.
        %
        % Written by Kenneth Sæterhagen Paulsen
        data = getFirstContext(obj)
        
        % Syntax:
        %
        % data = getLastContext(obj)
        % data = getLastContext(obj,variables)
        %
        % Description:
        %
        % Get the time-series of a set of variables at the last contexts.
        % 
        % Input:
        % 
        % - obj       : An object of class nb_connector.
        %
        % - variables : A cellstr with the variables to get fetch.
        % 
        % Output:
        % 
        % - data      : A nb_ts object. 
        %
        %               The dataNames property of this nb_ts object must
        %               store the last context date as a date on the
        %               format 'dd.mm.yyyy' or 'yyyymmdd'.
        %
        % Written by Kenneth Sæterhagen Paulsen
        data = getLastContext(obj,variables)
        
        % Syntax:
        %
        % lastContextDate = getLastContextDate(obj)
        %
        % Description:
        %
        % Get last context date from the data source.
        % 
        % Input:
        % 
        % - obj  : An object of class nb_connector.
        % 
        % Output:
        % 
        % - lastContextDate : A one line char with the last context date.
        %                     One the format 'yyyymmdd' or 
        %                     'yyyymmddhhnnss'.
        %
        % Written by Kenneth Sæterhagen Paulsen    
        lastContextDate = getLastContextDate(obj)
        
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
        % ret = hasConditionalInfo(obj)
        %
        % Description:
        %
        % Has the data source conditional information?
        % 
        % Input:
        % 
        % - obj : An object of class nb_modelDataSource.
        % 
        % Output:
        % 
        % - ret : 1 (yes) or 0 (no) or -1 (must be checked).
        %
        % Written by Kenneth Sæterhagen Paulsen

        % Copyright (c) 2021, Kenneth Sæterhagen Paulsen
        ret = hasConditionalInfo(obj)
         
        % Syntax:
        %
        % vars = getLevel(obj)
        %
        % Description:
        %
        % Get level based on source.
        %
        % Written by Kenneth Sæterhagen Paulsen
        value = getLevel(obj)
        
    end
    
    methods
    
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
    
    methods (Static=true)
        
        function obj = unstruct(s) 
        % Syntax:
        %
        % obj = nb_connector.unstruct(s)
        %
        % Description:
        %
        % Convert struct to a object.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
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
        
        
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_connector.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            obj = nb_connector.unstruct(s);
            
        end
        
    end

end
    
