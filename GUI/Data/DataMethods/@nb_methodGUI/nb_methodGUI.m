classdef (Abstract) nb_methodGUI < handle
% Description:
%
% Abstarct class for all the GUIs to do data transformations.
%
% Written by Kenneth S�terhagen Paulsen
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    properties
        
        % The transformed data as an nb_ts or nb_cs object.
        data
        
        % The parent as an nb_GUI object, or empty.
        parent      = [];
        
    end
    
    events
        
        methodFinished
        
    end
    
    methods
        
        function gui = nb_methodGUI(parent,data)
        % Constructor
            
            gui.data   = data;
            gui.parent = parent;
            
        end
        
    end
    
    methods (Access=protected,Abstract=true)
        
        makeGUI(gui)
        
    end
    
end
