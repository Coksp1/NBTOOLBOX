classdef (ConstructOnLoad) nb_mouseOverObjectEvent < event.EventData
% Description:
%
% The data that get sent when a mouseOverObject event is triggered by
% an object of class nb_notifiesMouseOverObject.
%
% Superclasses:
% event.EventData
%
% See also: 
% nb_notifiesMouseOverObject
%
% Written by Kenneth Sæterhagen Paulsen  
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Current point in axes data units. As a 1x2 double.
        currentPoint = [];
        
        % The value of the data point the mouse is over. As a scalar double
        value        = [];
        
        % The children index, as an integer
        h            = [];
        
        % The x-data index, as an integer.
        x            = [];
        
        % The y-data index, as an integer.
        y            = [];
        
    end
    
    methods
        
        function eventData = nb_mouseOverObjectEvent(x,y,h,value,currentPoint)
            
            eventData.x            = x;
            eventData.y            = y;
            eventData.h            = h;
            eventData.value        = value;
            eventData.currentPoint = currentPoint;
            
        end
        
    end

end

