classdef (ConstructOnLoad) nb_keyEvent < event.EventData
% Description:
%
% The data that get sent when the nb_figure events keyPressed and 
% keyReleased are triggered.
%
% Superclasses:
% event.EventData
%
% See also: 
% nb_figure
%
% Written by Kenneth Sæterhagen Paulsen  
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties

        Character = '';

        Modifier  = {};

        Key       = '';

    end

    methods

        function set.Character(obj,value)
            if ~nb_isOneLineChar(value) && ~isempty(value)
                error([mfilename ':: The Character property must ' ...
                    'be given as a char.'])
            end
            obj.Character = value;
        end

        function set.Modifier(obj,value)
            if ~iscell(value)
                error([mfilename ':: The Modifier property must ' ...
                    'be given as a cell.'])
            end
            obj.Modifier = value;
        end

        function set.Key(obj,value)
            if ~nb_isOneLineChar(value) && ~isempty(value)
                error([mfilename ':: The Key property must ' ...
                    'be given as a char.'])
            end
            obj.Key = value;
        end

        function eventData = nb_keyEvent(Character,Modifier,Key)

            eventData.Character = Character;
            eventData.Modifier  = Modifier;
            eventData.Key       = Key;

        end
    end
end

