classdef nb_currentCalendar < nb_calendar
% Description:
%
% An object that will provide the current calendar.
%
% Superclasses:
% nb_calendar
%
% Constructor:
%
%   obj = nb_currentCalendar(frequency)
% 
% Input:
%
% - frequency : The frequency of the provided kalendar. 
%               > 1 : Yearly, i.e. current date each year back in time.
%               > 2 : Semi-annually, i.e. add to each half-year back in 
%                     time the current number of days since the start of 
%                     the current half-year implied by todays date. 
%               > 4 : Quarterly, i.e. same as for semi-annually, but for
%                     quarters instead.
%               > 12: Monthly, i.e. same as for semi-annually, but for
%                     months instead.
%               Default is yearly (1).
%
% See also: 
% nb_MPRCalendar, nb_numDaysCalendar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
        
        % The frequency of the current calendar.
        frequency = 1;

    end
    
    methods 
        
        function obj = nb_currentCalendar(frequency)
            if nargin < 1
                return
            end
            if ~ismember(frequency,[1,2,4,12])
                error([mfilename ':: The frequency input must be 1, 2, 4 or 12.'])
            end
            obj.frequency = frequency;
        end
         
        function s = struct(obj)
           s = struct('class',class(obj),'frequency',obj.frequency); 
        end
        
    end
    
    methods (Static=true)
       
        function obj = unstruct(s)
            obj = nb_currentCalendar(s.frequency);
        end
        
    end

end
