classdef nb_heavyJobInterface < handle
% Description:
%
% An interface for all classes that are taken up heavy work.
%
% Superclasses:
%
% handle
%
% Subclasses:
% nb_importDataGUI, nb_SMARTGUI
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    events 
        
        startHeavyJob
        stopHeavyJob
        
    end
    
    properties

        % Handle to the main figure of this user interface.
        figureHandle
        
    end
    
    methods
        
        function gui = nb_heavyJobInterface()
            if isvalid(gui)
                addlistener(gui,'startHeavyJob',@nb_makeFigureIdle);
                addlistener(gui,'stopHeavyJob',@nb_makeFigureAlive);
            end
        end
        
    end
end

