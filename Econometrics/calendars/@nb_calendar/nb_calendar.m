classdef nb_calendar
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
% nb_SMARTVariableCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen    
    
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
        %                 nb_model_forecast_vintages.
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
       
        varargout = doOneModel(varargin)
        varargout = getContextIndex(varargin)
        varargout = getDefaultStart(varargin)
        varargout = getStartOfCalendar(varargin)
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
    
end
