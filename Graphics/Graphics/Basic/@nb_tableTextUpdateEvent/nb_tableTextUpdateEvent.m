classdef (ConstructOnLoad) nb_tableTextUpdateEvent < event.EventData
% Description:
%
% The data that get sent when the updatedTableText event is notified.
%
% Superclasses:
% event.EventData
%
% See also: 
% nb_table
%
% Written by Kenneth Sæterhagen Paulsen  
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % A char with the string property of the edited cell of the
        % nb_table object
        String    = '';
        
        % The index of the edited cell of the nb_table object.
        Index     = [];
        
    end
    
   methods
       
       function set.String(obj,value)
           if ~nb_isOneLineChar(value) && ~isempty(value)
               error([mfilename ':: The string property must be given'...
                     ' as a one line char.'])
           end
           obj.String = value;
        end

        function set.Index(obj,value)
            if ~isa(value,'double')
                error([mfilename ':: The index property must be given'...
                       ' as a double.'])
            end
            obj.Index = value;
        end 

        function eventData = nb_tableTextUpdateEvent(String,Index)
            
            eventData.String = String;
            eventData.Index  = Index;
            
        end
        
    end

end

