classdef (ConstructOnLoad) nb_additionalCellstrEvent < event.EventData
% Description:
%
% A class to send an event with a cellstr as data.
%
% Superclasses:
%
% event.EventData
%
% Constructor:
%
%   eventData = nb_additionalCellstrEvent(c)
% 
%   Input:
%
%   - string : The cellstr to send.
% 
%   Output:
% 
%   - eventData : The nb_additionalCellstrEvent object to send.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Extra information as a string
        c = {};
        
    end
    
    methods
        
        function eventData = nb_additionalCellstrEvent(c)
            
            if ~iscellstr(c)
                error(['Unsupported input of class ' class(c) '.'])
            end
            eventData.c = c;
        end
        
    end

end

