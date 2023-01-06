classdef (ConstructOnLoad) nb_eventData < event.EventData
% Description:
%
% A class to send an event with some generic data.
%
% Superclasses:
%
% event.EventData
%
% Constructor:
%
%   eventData = nb_eventData(data)
% 
%   Input:
%
%   - data      : The data to send.
% 
%   Output:
% 
%   - eventData : The nb_eventData object to send.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

   properties
      Data
   end
   
   methods
      function event = nb_eventData(data)
          event.Data = data;
      end
   end
   
end
