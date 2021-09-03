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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    methods 
        
        function s = struct(obj)
           s = struct('class',class(obj)); 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(s)
            obj = nb_allCalendar();
        end
        
    end
      
end