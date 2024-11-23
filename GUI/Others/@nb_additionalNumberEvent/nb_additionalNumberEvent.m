classdef (ConstructOnLoad) nb_additionalNumberEvent < event.EventData
% Description:
%
% A class to send an event with a number as data.
%
% Superclasses:
%
% event.EventData
%
% Constructor:
%
%   eventData = nb_additionalNumberEvent(number)
% 
%   Input:
%
%   - number : The number to send.
% 
%   Output:
% 
%   - eventData : The nb_additionalNumberEvent object to send.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Extra information as a number
        number = [];
        
    end
    
    methods
        
        function eventData = nb_additionalNumberEvent(number)
            
            if ~isnumeric(number)
                error([mfilename ':: Unsupported input of class ' class(number) '.'])
            end
            eventData.number = number;
        end
        
    end

end
