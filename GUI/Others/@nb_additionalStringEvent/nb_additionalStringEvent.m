classdef (ConstructOnLoad) nb_additionalStringEvent < event.EventData
% Description:
%
% A class to send an event with a string as data.
%
% Superclasses:
%
% event.EventData
%
% Constructor:
%
%   eventData = nb_additionalStringEvent(string)
% 
%   Input:
%
%   - string : The string to send.
% 
%   Output:
% 
%   - eventData : The nb_additionalStringEvent object to send.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    properties
        
        % Extra information as a string
        string = '';
        
    end
    
    methods
        
        function eventData = nb_additionalStringEvent(string)
            
            if ~ischar(string)
                error([mfilename ':: Unsupported input of class ' class(string) '.'])
            end
            eventData.string = string;
        end
        
    end

end

