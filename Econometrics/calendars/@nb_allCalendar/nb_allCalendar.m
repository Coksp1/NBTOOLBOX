classdef nb_allCalendar < nb_calendar
% Description:
%
% An object that will provide the all calendar, i.e. return all runs of
% a model.
%
% Superclasses:
%
% nb_calendar
%
% Constructor:
%
%   obj = nb_allCalendar()
% 
% See also: 
% nb_currentCalendar, nb_MPRCalendar, nb_lastCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    methods 
        
        function s = struct(obj)
           s = struct('class',class(obj)); 
        end
        
        function name = getName(~)
           name = 'All'; 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(s)
            obj = nb_allCalendar();
        end
        
    end
      
end
