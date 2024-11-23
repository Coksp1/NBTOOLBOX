classdef nb_calendar < matlab.mixin.Heterogeneous
% Description:
%
% A superclass of the different calendars that can be used to construct 
% time dependent averaging of models in 
% nb_model_group_vintages.constructWeights.
%
% See also: 
% nb_model_group_vintages.constructWeights, 
% nb_model_group_vintages.combineForecast
% nb_allCalendar
% nb_currentCalendar
% nb_lastCalendar
% nb_manualCalendar
% nb_MPRCalendar
% nb_MPRCutoffCalendar
% nb_numDaysCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen   

    properties (Dependent=true)

        % Set if the calendar should be closed or open ended, i.e. if the 
        % endDate input to the getCalendar or getCalendarSec should return 
        % the calendar dates so that endDate is less than or equal to the 
        % last calendar date (closed == false), or so that the last 
        % calendar date is less than or equal to the endDate input 
        % (closed == true).
        closed

    end

    properties (Access=protected)

        closedInternal = false;

    end
    
    methods (Abstract=true)
        
        % Syntax:
        %
        % calendar = getCalendar(obj,start,finish,modelGroup,doRecursive)
        %
        % Description:
        %
        % Get calendar.
        % 
        % Input:
        % 
        % - obj         : An object of a subclass of the nb_calendar class.
        %  
        % - start       : Start date of calendar window, as a nb_day 
        %                 object.
        %
        % - finish      : End date of calendar window, as a nb_day object.
        %
        % - modelGroup  : A vector of objects of class 
        %                 nb_model_forecast_vintages or a cellstr where
        %                 each element is on the format 'yyyymmdd' or
        %                 'yyyymmddhhnnss'.
        %
        % - doRecursive : If the modelGroup input is a scalar 
        %                 nb_model_group_vintages object you may want to 
        %                 get the calender of the children instead of the 
        %                 object itself. In this case this input must be 
        %                 set to true. Default is true.
        %
        % - fromResults : Give true to take the contexts from results
        %                 property instead of the forecastOutput property.
        %
        %                 This is only supported when modelGroup is an
        %                 array of nb_model_vintages objects.
        %
        % Output:
        % 
        % - calendar : The calendar for the selected window, as a  
        %              N x 1 double.
        %
        % Written by Kenneth Sæterhagen Paulsen
        calendar = getCalendar(obj,start,finish,modelGroup,doRecursive,fromResults);
        
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
        % name = getName(obj)
        %
        % Description:
        %
        % Get calendar name as one line char
        %
        % Written by Kenneth Sæterhagen Paulsen
        name = getName(obj)
        
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

        function obj = set.closed(obj,value)
            obj = setClosedInternal(obj,value);
        end

        function value = get.closed(obj)
            value = getClosedInternal(obj);
        end

        function value = getClosedInternal(obj)
            value = obj.closedInternal;
        end

        function obj = setClosedInternal(obj,value)
            obj.closedInternal = value;
        end
        
    end
    
    methods (Static=true)
       
        varargout = doOneModel(varargin)
        varargout = getContextIndex(varargin)
        varargout = getDefaultStart(varargin)
        varargout = getStartOfCalendar(varargin)
        vararout  = getSubClasses(varargin)
        varargout = shrinkCalendar(varargin)
        
        function obj = unstruct(s) 
        % Syntax:
        %
        % obj = nb_calendar.unstruct(s)
        %
        % Description:
        %
        % Convert struct to a object.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            if isa(s,'nb_calendar')
                obj = s; % backward compatibility
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
        
        
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_calendar.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            obj = nb_calendar.unstruct(s);
            
        end
        
    end

    methods (Static,Sealed,Access=protected)

      function default_object = getDefaultScalarElement
         default_object = nb_allCalendar;
      end
      
   end
    
end
