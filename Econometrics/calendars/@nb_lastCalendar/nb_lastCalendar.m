classdef nb_lastCalendar < nb_calendar
% Description:
%
% An object that will provide last calendar, i.e. return the last runs of 
% a model (group).
%
% Superclasses:
%
% nb_calendar
%
% Constructor:
%
%   obj = nb_lastCalendar()
% 
% See also: 
% nb_currentCalendar, nb_MPRCalendar, nb_allCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    methods 
        
        function s = struct(obj)
           s = struct('class',class(obj)); 
        end
        
        function name = getName(~)
           name = 'Last'; 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(~)
            obj = nb_lastCalendar();
        end
        
    end
      
end
